module TaxonWorks
  module Vendor
    require 'gnfinder'
    module Gnfinder
      HOST = 'finder-rpc.globalnames.org'

      class Finder
        attr_accessor :client

        def initialize
          @client = ::Gnfinder::Client.new(host = TaxonWorks::Vendor::Gnfinder::HOST, port = 80)
        end
      end
    end
  end
end 
