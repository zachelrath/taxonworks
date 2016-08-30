# TODO: THIS IS A GENERATED STUB, it does not function
module BatchLoad
  class Import::CollectionObjects::SpecimensInterpreter < BatchLoad::Import

    def initialize(**args)
      @collection_objects = {}
      super(args)
    end

    # TODO: update this
    def build_collection_objects
      # Castor            CTR
      # Morphbank         MBK
      # DRMLabVoucher     DRMLV
      # DRMFieldVoucher   DRMFV
      namespace_castor = Namespace.find_by(name: 'Castor')
      namespace_morphbank = Namespace.find_by(name: 'Morphbank')
      namespace_drm_lab_voucher = Namespace.find_by(name: 'DRMLabVoucher')
      namespace_drm_field_voucher = Namespace.find_by(name: 'DRMFieldVoucher')

      i = 1
      # loop throw rows
      csv.each do |row|
        # Only accept records from DRM to keep things simple for now
        next if row['locality_database'] != "DRM"

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:collection_object] = []

        @processed_rows[i] = parse_result

        begin # processing
          # use a BatchLoad::ColumnResolver or other method to match row data to TW 
          #  ...

          # Text for identifiers
          co_identifier_castor_text = row['guid']
          co_identifier_morphbank_text = row['morphbank_specimen_id']
          co_identifier_drm_field_voucher_text = row['specimen_number']
          co_identifier_drm_lab_voucher_text = "#{row['voucher_number_prefix']}#{row['voucher_number_stirng']}"

          # Identifiers
          co_identifier_castor = { namespace: namespace_castor,
                                   type: 'Identifier::Local::CollectionObject',
                                   identifier: co_identifier_castor_text }

          co_identifier_morphbank = { namespace: namespace_morphbank,
                                      type: 'Identifier::Local::CollectionObject',
                                      identifier: co_identifier_morphbank_text }
                                          
          co_identifier_drm_field_voucher = { namespace: namespace_drm_field_voucher,
                                              type: 'Identifier::Local::CollectionObject',
                                              identifier: co_identifier_drm_field_voucher_text }
                                                  
          co_identifier_drm_lab_voucher = { namespace: namespace_drm_lab_voucher,
                                            type: 'Identifier::Local::CollectionObject',
                                            identifier: co_identifier_drm_lab_voucher_text }                                     

          # Collection object
          co_identifiers = Array.new
          co_identifiers.push(co_identifier_castor)             if !co_identifier_castor_text.blank?
          co_identifiers.push(co_identifier_morphbank)          if !co_identifier_morphbank_text.blank?
          co_identifiers.push(co_identifier_drm_field_voucher)  if !co_identifier_drm_field_voucher_text.blank?
          co_identifiers.push(co_identifier_drm_lab_voucher)    if !co_identifier_drm_lab_voucher_text.blank?

          co_attributes = { type: 'Specimen', total: 1, identifiers_attributes: co_identifiers }
          co = CollectionObject.new(co_attributes)

          # Collecting event that this collection object corresponds to
          ces = CollectingEvent.with_namespaced_identifier('Castor', row['collecting_event_guid'])
          ce = nil
          ce = ces.first if ces.any?
          co.collecting_event = ce if !ce.nil?

          parse_result.objects[:collection_object].push(co);
        #rescue
           # ....
           # puts "SOMETHING WENT WRONG WITH COLLECTION OBJECT SPECIMENS INTERPRETER BATCH LOAD"
        end
        i += 1
      end
    end

    def build
      if valid?
        build_collection_objects
        @processed = true
      end
    end

  end
end
