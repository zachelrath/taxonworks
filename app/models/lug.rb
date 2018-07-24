# A Lug is one side of taxonomic key couplet.  A lug without a parent is an entry point to a key.
#
# @!attribute text 
#   @return [String]
#     The couplets text, or, when parent is null, the name of the key.
#
# @!attribute otu_id 
#   @return [Integer, nil]
#     the target endpoint for this couplet 
#
# @!attribute otu_id 
#   @return [Integer, nil]
#     the exiting endpoint (taxon) for this side of the couplet
#
# @!attribute parent_id 
#   @return [Integer, nil]
#     when nil, the Lug defines the overal key, when present defines the enclosing couplet 
#
# @!attribute redirect_id 
#   @return [Integer, nil]
#     when provided redirects to a non-child node in the key 
#
# @!attribute position 
#   @return [Integer]
#     sort the Lug from left (low position), to right (high position) 
#
# @!attribute description 
#   @return [text, nil]
#     A (public) description of the Key or couplet, describing intent or scope 
#
# @!attribute label 
#   @return [text, nil]
#     a user defined label (prefix) for the couplet, like `1` or `1a`  
#
# @!attribute external_url
#   @return [text, nil]
#     provide an external endpoint 
#
# @!attribute external_url_text
#   @return [text, nil]
#     user readable text for the external url 
#
# @!attribute is_public 
#   @return [Boolean]
#     if true then key is public 
#
class Lug < ApplicationRecord

  has_closure_tree

  include Housekeeping
  include Shared::Tags
  include Shared::Notes
  include Shared::Depictions
  include Shared::Citations
  include Shared::Confidences
  include Shared::AlternateValues
  include Shared::HasPapertrail
  include SoftValidation
  include Shared::IsData

  acts_as_list scope: [:parent_id, :project_id]

  belongs_to :otu
  belongs_to :redirect, class_name: 'Lug'

end
