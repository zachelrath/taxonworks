module BatchFileLoad
  class Import::Sequences::GenbankInterpreter < BatchFileLoad::Import
    def initialize(**args)
      super(args)
    end

=begin
    Sequences
    &v = begginning file name
    g, ,f, p, a, n, follow _& 

    V = voucher number ex DRMDNA1408: LINK To Extract with matching CollectionObject identifier namespace DRMDNA
    G = gene code name
    F = gene fragement: ignore 
    P = publication within internal: ignore
    A = accession number, genbank code, IDENTIFIER: ATTACH Sequence identifier namespace GenBank
    N = human readable name: ignore 

    ex
    &vDRMDNA1299_&gCOI_&fCOIBC_&pPUB019_&aKJ624355_&nBembidion obliquulum.fas

    Things to be done with each file
      - Link Sequence to Extract with matching CollectionObject identifier in namespace DRMDNA with OriginRelationship
      - Attach identifier Sequence in namespace GenBank with value of the accession number

      nested attributes!
=end
    def build
      return if !valid?
      @processed = true

      @filenames.each_with_index do |filename, file_index|
        objects_in_file = {}
        objects_in_file[:sequence] = []
        objects_in_file[:origin_relationship] = []

        sequence = create_sequence(filename, @file_contents[file_index])
        objects_in_file[:sequence].push(sequence)

        origin_relationship = create_origin_relationship(filename, sequence)
        objects_in_file[:origin_relationship].push(origin_relationship) if origin_relationship

        @processed_files[:names].push(filename)
        @processed_files[:objects].push(objects_in_file)
      end
    end

    private

    def create_sequence(filename, file_content)
      # GenBank GBK
      namespace_genbank = Namespace.find_by(name: 'GenBank')

      # Sequence attributes
      sequence_attributes = { name: nil, sequence_type: nil, sequence: nil, identifiers_attributes: [] }

      sequence_attributes[:name] = get_taxon_name(filename) + "_" + get_voucher_number(filename) + "_" + get_gene_fragement(filename)
      sequence_attributes[:sequence_type] = get_sequence_type(filename)
      sequence_attributes[:sequence] = get_sequence(file_content)

      # Identifiers for Sequence
      sequence_identifier_genbank_text = get_genbank_text(filename)
      

      sequence_identifier_genbank = { namespace: namespace_genbank,
                                      type: 'Identifier::Local::Sequence',
                                      identifier: sequence_identifier_genbank_text }

      sequence_attributes[:identifiers_attributes].push(sequence_identifier_genbank) if !sequence_identifier_genbank_text.blank?
      sequence = Sequence.new(sequence_attributes)
      sequence
    end

    def create_origin_relationship(filename, sequence)
      # Extract that this sequence came from
      extracts = Extract.with_namespaced_identifier('GenBank', get_voucher_number(filename))  
      extract = nil
      extract = extracts.first if extracts.any?

      # OriginRelationship for Extract(source) and Sequence(target)
      origin_relationship = nil
      
      if !extract.nil?
        origin_relationship_attributes = { old_object: extract, new_object: sequence }
        origin_relationship = OriginRelationship.new(origin_relationship_attributes)
      end

      origin_relationship
    end

    def get_genbank_text(filename)
      # _&aKJ624355_&
      genbank_pattern = "_&a"
      beg_genbank_text_index = filename.index(genbank_pattern)
      
      if beg_genbank_text_index
        beg_genbank_text_index += genbank_pattern.length
        end_genbank_text_index = filename.index("_&", beg_genbank_text_index)
        return filename[beg_genbank_text_index...end_genbank_text_index]
      end

      ""
    end

    def get_sequence(file_content)
      new_line_index = file_content.index("\n") # Double quotes are needed to properly interpret new line character
      file_content[(new_line_index + 1)...(file_content.length - 1)]
    end

    def get_sequence_type(filename)
      "DNA"
    end

    def get_voucher_number(filename)
      # &vDRMDNA2303_&
      voucher_pattern = "&vDRM"
      beg_voucher_text_index = filename.index(voucher_pattern)

      if beg_voucher_text_index
        beg_voucher_text_index += voucher_pattern.length
        end_voucher_text_index = filename.index("_&", beg_voucher_text_index)
        return filename[beg_voucher_text_index...end_voucher_text_index]
      end

      ""
    end

    def get_gene_fragement(filename)
      # _&fCOIBC_&
      gene_fragement_pattern = "_&f"
      beg_gene_fragement_text_index = filename.index(gene_fragement_pattern)

      if beg_gene_fragement_text_index
        beg_gene_fragement_text_index += gene_fragement_pattern.length
        end_gene_fragement_text_index = filename.index("_&", beg_gene_fragement_text_index)
        return filename[beg_gene_fragement_text_index...end_gene_fragement_text_index]
      end

      ""
    end

    def get_taxon_name(filename)
      # _&nBembidion obliquulum.fas
      taxon_name_pattern = "_&n"
      beg_taxon_name_text_index = filename.index(taxon_name_pattern)

      if beg_taxon_name_text_index
        beg_taxon_name_text_index += taxon_name_pattern.length
        end_taxon_name_text_index = filename.index(".fas", beg_taxon_name_text_index)
        taxon_name = filename[beg_taxon_name_text_index...end_taxon_name_text_index]
        taxon_name.tr!(" ", "-")
        return taxon_name
      end

      ""
    end
  end
end