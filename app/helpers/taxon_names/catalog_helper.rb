# Methods to generate catog entries
# Each history_ method must generate a span
module TaxonNames::CatalogHelper

  def nomenclature_catalog_li_tag(nomenclature_catalog_item, reference_taxon_name, target = :browse_nomenclature_task_path)
    content_tag(:li, nomenclature_line_tag(nomenclature_catalog_item, reference_taxon_name, target), class: :history__record)
  end

  def nomenclature_line_tag(nomenclature_catalog_item, reference_taxon_name, target = :browse_nomenclature_task_path)
    i = nomenclature_catalog_item
    t = i.taxon_name
    c = i.citation
    r = reference_taxon_name

    [  
      history_taxon_name(t, r, c, target),        # the subject, or protonym
      history_author_year(t, c),                  # author year of the subject, or protonym
                                                 
      history_subject_original_citation(i),      
      history_statuses(i),                        # TaxonNameClassification summary
                                                 
      history_other_name(i, r),                   # The TaxonNameRelaltionship
      history_in(t, c),                           #  citation for related name 
      history_pages(c),                           #  pages for citation of related name
                                                 
      history_citation_notes(c),                  # Notes on the citation 
      history_topics(c),                          # Topics on the citation
      history_type_material(t, i.is_subsequent?), # Type material reference 
    ].compact.join.html_safe
  end

  def history_taxon_name(taxon_name, r, c, target = nil)
    name = original_taxon_name_tag(taxon_name)
    body = nil
    css = nil
    soft_validation = nil

    if target
      body = link_to(name, send(target, taxon_name) )
    else
      body = name 
    end

    if taxon_name == r
      css = 'history__reference_taxon_name'
    else
      css = 'history__related_taxon_name' 
      soft_validation = soft_validation_alert_tag(taxon_name)
    end

    content_tag(:span, body + soft_validation.to_s, class: [css, original_citation_css(taxon_name, c), :history__taxon_name ]) 
  end

  # @return [String]
  #   the name, or citation author year, prioritized by original/new with punctuation
  def history_author_year(taxon_name, citation) 
    return content_tag(:span, ' Source is verbatim, requires parsing', class: :warning) if citation.try(:source).try(:type) == 'Source::Verbatim'
    str =  history_author_year_tag(taxon_name) 
    str.blank? ? nil : 
      content_tag(:span, ' ' + str, class: [:history_author_year])
  end

  # @return [String, nil]
  #   variably return the author year for taxon name in question
  #   !! NO span, is used in comparison !!
  def history_author_year_tag(taxon_name)
    return nil if taxon_name.nil? || taxon_name.cached_author_year.nil?
   
    body =  case taxon_name.type
    when 'Combination'
      current_author_year(taxon_name)
    when 'Protonym'
      original_author_year(taxon_name)
    else
      'HYBRID NOT YET HANDLED'
    end
  end

  # @return [String, nil]
  #   any Notes on the citation in question 
  def history_citation_notes(citation)
    return nil if citation.nil? || !citation.notes.any?
    content_tag(:span, citation.notes.collect{|n| n.text}.join, class: 'history__citation_notes') if citation.notes?
  end

  # @return [String, nil]
  #   a parenthesized line item containing relationship and related name
  def history_other_name(catalog_item, reference_taxon_name)
    if catalog_item.from_relationship? 
      content_tag(:span, " (#{catalog_item.object.subject_status.to_s + catalog_item.object.subject_status_connector_to_object.to_s} #{full_original_taxon_name_tag(catalog_item.other_name)})#{soft_validation_alert_tag(catalog_item.object)}".html_safe, class: [:history__other_name])
    end
  end

  # @return [String, nil]
  #    pages from the citation, with prefixed :
  def history_pages(citation)
    return nil if citation.nil?
    content_tag(:span, ": #{citation.pages}.", class: 'history__pages') if citation.pages
  end

  # @return [String, nil]
  #   A brief summary of the validity of the name (e.g. 'Valid')
  #     ... think this has to be refined, it doesn't quite make sense to show multiple status per relationship
  def history_statuses(i)
    s = i.taxon_name.taxon_name_classifications_for_statuses
    return nil if (s.empty? || i.is_subsequent?)
    return nil if !i.from_relationship?

    content_tag(:span, class: [:history__statuses]) do
      (' (' +
       s.collect{|tnc|
        content_tag(:span, (tnc.classification_label + soft_validation_alert_tag(tnc).to_s).html_safe, class: ['history__status'])
      }.join(', ')
      ).html_safe +
      ')'
    end
  end

  # @return [String, nil]
  #   the taxon name author year for the citation in question
  #   if the same as the author/year for the catalog_item taxon name then this
  #   only renders the pages in that citation
  def history_subject_original_citation(catalog_item)
    return nil if !catalog_item.from_relationship? || catalog_item.object.subject_taxon_name.origin_citation.blank?
    t = catalog_item.object.subject_taxon_name
    c = t.origin_citation

    a = history_author_year_tag(t) 
    b = citation_author_year_tag(c)

    body =  [
      (a != b ?  ': ' + citation_author_year_tag(c) : nil),
      history_pages(c)
    ].compact.join.html_safe

    content_tag(:span, body, class: :history__subject_original_citation) unless body.blank?
  end

  # @return [String, nil]
  #    return the citation author/year if differeing from the taxon name author year 
  #   !! USED ?! 
  def history_in(t, c)
    if c
      a = history_author_year_tag(t) 
      b = citation_author_year_tag(c)
      if a != b
        content_tag(:span,  ": #{b}", class: [:history__in])
      end
    end
  end

  def history_topics(citation)
    return nil if citation.nil?
    content_tag(:span, nil_wrap(' [', citation.citation_topics.collect{|t| t.topic.name}.join(", "), ']'), class: 'history__citation_topics')
  end

  def history_type_material(taxon_name, is_subsequent)
    return nil if taxon_name.type == 'Combination' || is_subsequent
    content_tag(:span, ' '.html_safe + type_taxon_name_relationship_tag(taxon_name.type_taxon_name_relationship), class: 'history__type_information')
  end

  protected

  # @return [String, nil]
  #    a computed css class, when provided indicates that the citation is the original citation for the taxon name provided
  def original_citation_css(taxon_name, citation)
    return nil if citation.nil?
    'history__original_description' if citation.is_original? && taxon_name == citation.citation_object
  end

end
