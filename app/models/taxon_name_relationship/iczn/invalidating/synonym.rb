class TaxonNameRelationship::Iczn::Invalidating::Synonym < TaxonNameRelationship::Iczn::Invalidating

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000276'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_to_s(TaxonNameRelationship::Iczn::Invalidating::Usage) +
            [TaxonNameRelationship::Iczn::Invalidating.to_s]
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Available::Invalid)
  end

  def object_status
    'senior synonym'
  end

  def subject_status
    'synonym'
  end

  def subject_status_connector_to_object
    ' of'
  end

  def object_status_connector_to_subject
    ' of'
  end

  def self.assignment_method
    # bus.set_as_iczn_synonym_of(aus)
    :iczn_set_as_synonym_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.iczn_synonym = bus
    :iczn_synonym
  end

  def sv_synonym_relationship
    if self.source
      date1 = self.source.cached_nomenclature_date.to_time
      date2 = self.subject_taxon_name.nomenclature_date
      if !!date1 && !!date2
        soft_validations.add(:base, "#{self.subject_taxon_name.cached_html_name_and_author_year} was not described at the time of citation (#{date1}") if date2 > date1
      end
    else
      soft_validations.add(:base, 'The original publication is not selected')
    end
  end

  def sv_not_specific_relationship
    soft_validations.add(:type, 'Please specify if this is a objective or subjective synonym',
                         fix: :sv_fix_specify_synonymy_type, success_message: 'Synonym updated to being objective or subjective')
  end

  def sv_fix_specify_synonymy_type
    s = self.subject_taxon_name
    o = self.object_taxon_name
    subject_type = s.type_taxon_name
    object_type = o.type_taxon_name
    new_relationship_name = self.type_name
    if (subject_type == object_type && !subject_type.nil? ) || (!s.get_primary_type.empty? && s.has_same_primary_type(o) )
      new_relationship_name = 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective'
    elsif (subject_type != object_type && !subject_type.nil? ) || (!s.get_primary_type.empty? && !o.get_primary_type.empty? && !s.has_same_primary_type(o))
      new_relationship_name = 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective'
    end
    if self.type_name != new_relationship_name
      self.type = new_relationship_name
      begin
        TaxonNameRelationship.transaction do
          self.save
          return true
        end
      rescue
      end
    end

    false
  end
end
