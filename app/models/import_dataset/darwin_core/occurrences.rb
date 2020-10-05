class ImportDataset::DarwinCore::Occurrences < ImportDataset::DarwinCore

  has_many :core_records, foreign_key: 'import_dataset_id', class_name: 'DatasetRecord::DarwinCore::Occurrence'
  has_many :extension_records, foreign_key: 'import_dataset_id', class_name: 'DatasetRecord::DarwinCore::Extension'

  MINIMUM_FIELD_SET = ["occurrenceID", "scientificName", "basisOfRecord"]

  validate :source, :check_field_set

  # Stages core (Occurrence) records and all extension records.
  def perform_staging
    records, headers = get_records(source)

    update!(metadata: {
      core_headers: headers[:core],
      extensions_headers: headers[:extensions],
      nomenclature_code: "ICZN",
      catalog_numbers_namespaces: []
    })

    parse_results = Biodiversity::Parser.parse_ary(records[:core].map { |r| r["scientificName"] || "" })

    core_records = records[:core].each_with_index.map do |record, index|
      {
        parse_results: parse_results[index],
        src_data: record,
        basisOfRecord: record["basisOfRecord"]
      }
    end

    core_records.each do |record|
      parse_results = record[:parse_results]

      record[:invalid] = "scientificName could not be parsed" if not parse_results[:details]
    end

    catalog_numbers_namespaces = Set[]

    core_records.each do |record|
      dwc_occurrence = DatasetRecord::DarwinCore::Occurrence.new(import_dataset: self)
      dwc_occurrence.initialize_data_fields(record[:src_data].map { |k, v| v })

      catalog_numbers_namespaces << [
        [
          dwc_occurrence.get_field_value(:institutionCode),
          dwc_occurrence.get_field_value(:collectionCode)
        ],
        nil # User will select namespace through UI. TODO: Should we attempt guessing here?
      ]

      dwc_occurrence.status = !record[:invalid] ? "Ready" : "NotReady"
      dwc_occurrence.status = "Unsupported" unless "PreservedSpecimen".casecmp(record[:basisOfRecord]) == 0
      record.delete(:src_data)
      dwc_occurrence.metadata = record

      dwc_occurrence.save!
    end

    records[:extensions].each do |extension_type, records|
      records.each do |record|
        dwc_extension = DatasetRecord::DarwinCore::Extension.new(import_dataset: self)
        dwc_extension.initialize_data_fields(record.map { |k, v| v })
        dwc_extension.status = "Unsupported"
        dwc_extension.metadata = { "type" => extension_type }

        dwc_extension.save!
      end
    end

    update!(metadata: self.metadata.merge!(catalog_numbers_namespaces: catalog_numbers_namespaces))
  end

  # @return [Hash]
  # Returns a hash with the record counts grouped by status
  def progress
    core_records.group(:status).count
  end

  def check_field_set
    if source.staged?
      if ["application/zip", "application/octet-stream"].include? source.content_type
        headers = get_dwc_headers(::DarwinCore.new(source.staged_path).core)
      else
        headers = CSV.read(source.staged_path, col_sep: "\t", quote_char: nil).first
      end

      missing_headers = MINIMUM_FIELD_SET - headers

      missing_headers.each do |header|
        errors.add(:source, "required field #{header} missing.")
      end
    end
  end

  def update_catalog_number_namespace(institution_code, collection_code, namespace_id)
    mapping = self.metadata["catalog_numbers_namespaces"].detect { |m| m[0] == [institution_code, collection_code] }
    mapping[1] = namespace_id
    save!
  end
end