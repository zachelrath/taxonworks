module TaxonWorks
  module Vendor
    require 'gnparser'
    module Gnparser 
      HOST = 'parser-rpc.globalnames.org'

      class Parser 
        attr_accessor :client

        def initialize
          @client = ::GNparser::Client.new(host = TaxonWorks::Vendor::Gnparser::HOST, port = 80)
        end
      end
    end
  end
end 
