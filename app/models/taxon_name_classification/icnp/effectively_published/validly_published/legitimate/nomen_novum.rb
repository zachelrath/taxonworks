class TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Legitimate::NomenNovum < TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Legitimate

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000089'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Legitimate)
  end

  def self.gbif_status
    'novum'
  end

  def sv_not_specific_classes
    true
  end
end
