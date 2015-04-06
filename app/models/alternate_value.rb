# AlternateValue(s) are annotations on an object or object attribute. Use only when the annotations are related
#   to the same thing. (e.g. Hernán vs. Hernan, NOT Bean Books (publisher1) vs. Dell Books(publisher2))
#
# @!attribute attribute_subject_id
#   the ID of the thing being annotated
#
# @!attribute attribute_subject_type
#   the kind of thing being annotated
#
# @!attribute value
#   the annotated value
#
# @!attribute controlled_vocabulary_term_id
#   the ID of the controlled vocabulary term - used only for InternalAttribute
#   Use InternalAttributes when you can precisely define what the alternate value is (e.g. note, MX_ID)
#
# @!attribute import_predicate
#   a string describing the data that has been imported from elsewhere that TW does not have a precise definition for.
#   Used only with ImportAttribute - use when importing outside data and you don't have a definition of the field.
#   (e.g. verbatim_notebook_field_6)
#
class AlternateValue < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData
  include Shared::DualAnnotator
  include Shared::AttributeAnnotations

  belongs_to :language
  belongs_to :alternate_value_object, polymorphic: true

  validates :language, presence: true, allow_blank: true
  validates_presence_of :type, :value, :alternate_value_object_attribute
  validates :alternate_value_object, presence: true

  def type_name
    r = self.type.to_s
    ALTERNATE_VALUE_CLASS_NAMES.include?(r) ? r : nil
  end

  def type_class=(value)
    write_attribute(:type, value.to_s)
  end

  def type_class
    r = read_attribute(:type).to_s
    r = ALTERNATE_VALUE_CLASS_NAMES.include?(r) ? r.safe_constantize : nil
    r
  end

  def self.class_name
    self.name.demodulize.underscore.humanize.downcase
  end

  def self.find_for_autocomplete(params)
    where('value LIKE ?', "%#{params[:term]}%").with_project_id(params[:project_id])
  end

  def klass_name
    self.class.class_name
  end

  # @return [NoteObject]
  #   alias to simplify reference across classes 
  def annotated_object
    alternate_value_object 
  end

  # @return [Symbol]
  #   the column name containing the attribute name being annotated
  def self.annotated_attribute_column
    :alternate_value_object_attribute
  end

  def self.annotation_value_column
    :value
  end

  def self.generate_download(scope)
    CSV.generate do |csv|
      csv << column_names
      scope.order(id: :asc).each do |o|
        csv << o.attributes.values_at(*column_names).collect { |i|
          i.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
        }
      end
    end
  end

end
