require 'caracal'

module Export

  # Exports an OTU to the MS Word .docx format
  # using [caracal](https://github.com/urvin-compliance/caracal) library to generate the docx
  module Docx

    FILETYPES = %w{Description Name Synonym VernacularName}.freeze

    # @return [Scope]
    #   Should return the full set of Otus that are to be sent.
    def self.otus(otu_id)
      o = ::Otu.find(otu_id)
      return ::Otu.none if o.taxon_name_id.nil?
      
      a = o.taxon_name.self_and_descendants
      ::Otu.joins(:taxon_name).where(taxon_name: a)
    end

    def self.build_doc(doc, otus)

        # page 1
        doc.h1 'Page 1'
        doc.hr
        doc.p
        doc.h2 'Section 1'
        doc.p  'Raw dump'
        doc.p
        # doc.table otus, border_size: 4 do
        #   cell_style rows[0], background: 'cccccc', bold: true
        # end
      
        # page 2
        doc.page
        doc.h1 'Formatted stuffs'
        doc.hr
        doc.p
        doc.h2 'OTU List'
        doc.ul do
            otus.each do |otu|
                li "OTU: #{otu.inspect()}"
            end
        end
        # doc.p
        # doc.img 'https://www.example.com/logo.png', width: 500, height: 300

    end

    def self.export(otu_id)
      otus = otus(otu_id)

      # source_id => [csv_array]
    #   ref_csv = {}

      # TODO: This will likely have to change, it is renamed on serving the file.
      export_file_path = "/tmp/_#{SecureRandom.hex(8)}_.docx"

      Caracal::Document.save export_file_path do |doc|
        build_doc(doc, otus)
      end

    #   Zip::File.open(export_file_path, Zip::File::CREATE) do |zipfile|
    #     (FILETYPES - ['Name']).each do |ft|
    #       m = "Export::Coldp::Files::#{ft}".safe_constantize
    #       zipfile.get_output_stream("#{ft}.csv") { |f| f.write m.generate(otus, ref_csv) }
    #     end

    #     zipfile.get_output_stream('Name.csv') { |f| f.write Export::Coldp::Files::Name.generate( Otu.find(otu_id), ref_csv) }
    #     zipfile.get_output_stream('Taxon.csv') { |f| f.write Export::Coldp::Files::Taxon.generate( otus, otu_id, ref_csv) }


    #     # Sort the refs by full citation string
    #     sorted_refs = ref_csv.values.sort{|a,b| a[1] <=> b[1]}

    #     d = CSV.generate(col_sep: "\t") do |csv|
    #       csv << %w{ID citation	doi} # author year source details
    #       sorted_refs.each do |r|
    #         csv << r 
    #       end
    #     end

    #     zipfile.get_output_stream('References.csv') { |f| f.write d }

    #   end

      export_file_path
    end

    def self.download(otu, request = nil)
      file_path = ::Export::Docx.export(otu.id)
      name = "docx_otu_id_#{otu.id}_#{DateTime.now}.docx"

      ::Download.create!(
        name: "docx download for #{otu.otu_name} on #{Time.now}.",
        description: 'A docx export of an OTU',
        filename: name,
        source_file_path: file_path,
        request: request,
        expires: 2.days.from_now
      )
    end

    # def self.download_async(otu, request = nil)
    #   download = ::Download.create!(
    #     name: "ColDP Download for #{otu.otu_name} on #{Time.now}.",
    #     description: 'A zip file containing CoLDP formatted data.',
    #     filename: "coldp_otu_id_#{otu.id}_#{DateTime.now}.docx",
    #     request: request,
    #     expires: 2.days.from_now
    #   )

    #   ColdpCreateDownloadJob.perform_later(otu, download)

    #   download
    # end

    # TODO - perhaps a utilities file --

    # @return [Boolean]
    #   true if no parens in cached_author_year
    #   false if parens in cached_author_year
    def self.original_field(taxon_name)
      (taxon_name.type == 'Protonym') && taxon_name.is_original_name?
    end

    # There are suite of issues with TaxonWorks model
    # all tied to the fact that we do not treat original combinations (lower case)
    # as Combinations (model).  All these problems go away if/when we remodel the original Combination.
    # These problems include:
    #     * inablity to site historical usages of the protonym that are properly latinized (e.g. var or f. names as subspecies)
    #     * providing unique IDs for form/var names
    # @param taxon_name [an invalid Protonym]
    def self.reified_id(taxon_name)
      if taxon_name.original_combination_relationships.any?
        taxon_name.id.to_s + '/' + Digest::MD5.hexdigest(taxon_name.cached_original_combination)
      else
        # there is no need to MD5 the name, as it hasn't been potentially altered by original combination assertions
        taxon_name.id.to_s
      end
    end

    # @param taxon_name [a valid Protonym or a Combination]
    #   see also exclusion of OTUs/Names based on Ranks not handled 
    def self.basionym_id(taxon_name)
      if taxon_name.type == 'Protonym'
        taxon_name.id
      elsif taxon_name.type == 'Combination'
        taxon_name.protonyms.last.id
      else
        nil # shouldn't be hit
      end
    end

  end
end
