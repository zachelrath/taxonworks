class TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::AlternativeName < TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic.to_s] +
        [TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::Isonym.to_s] +
        [TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::OrthographicVariant.to_s]
  end

  def self.assignment_method
    # aus.icn_alternative_name = bus
    :icn_alternative_name
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_icn_alternative_name_of(aus)
    :set_as_icn_alternative_name_of
  end

end