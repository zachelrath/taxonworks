module CollectingEventsHelper

  def collecting_event_tag(collecting_event)
    return nil if collecting_event.nil?

    if a = [ collecting_event.verbatim_label,
        collecting_event.print_label,
        collecting_event.document_label ].compact.first
      [ collecting_event_identifiers_tag(collecting_event), a].compact.join('&nbsp;').html_safe
    else
      collecting_event_autocomplete_tag(collecting_event, '; ').html_safe
    end
  end

  def collecting_event_autocomplete_tag(collecting_event, join_string = '<br>')
    return nil if collecting_event.nil?
    [ collecting_event_identifiers_tag(collecting_event),
      collecting_event_geographic_names_tag(collecting_event),
      collecting_event_verbatim_locality_tag(collecting_event),
      collecting_event_dates_tag(collecting_event),
      collecting_event_collectors_tag(collecting_event),
      collecting_event_coordinates_tag(collecting_event),
      collecting_event_method_habitat_tag(collecting_event),
    ].compact.join(join_string).html_safe
  end

  def collecting_event_identifiers_tag(collecting_event)
    return nil if collecting_event.nil?
    if i = collecting_event.identifiers.first
      collecting_event.identifiers.collect{|j|
        content_tag(:span, j.cached, class: [ :feedback, 'feedback-thin', 'feedback-secondary' ])
      }.join
    else
      nil
    end
  end

  def collecting_event_geographic_names_tag(collecting_event)
    return nil if collecting_event.nil?

    a = [collecting_event.cached_level0_geographic_name,
         collecting_event.cached_level1_geographic_name,
         collecting_event.cached_level2_geographic_name
    ].compact
    return nil if a.empty?

    content_tag(:span, a.join(': '))
  end

  def collecting_event_method_habitat_tag(collecting_event)
    return nil if collecting_event.nil? || (collecting_event.verbatim_method.blank? && collecting_event.verbatim_habitat.blank?)
    content_tag(:span, [collecting_event.verbatim_method, collecting_event.verbatim_habitat].compact.join('; '))
  end

  def collecting_event_collectors_tag(collecting_event)
    return nil if collecting_event.nil? || (collecting_event.verbatim_collectors.blank? && !collecting_event.collectors.load.any?)
    a = ''

    a << content_tag(
      :span, Utilities::Strings.authorship_sentence(collecting_event.collectors.collect{|a| a.cached})
    ) if collecting_event.collectors.any?

    a << '&nbsp;'.html_safe + content_tag(:span,  collecting_event.verbatim_collectors, class: [:feedback, 'feedback-thin','feedback-secondary']) if collecting_event.verbatim_collectors
    a
  end

  def collecting_event_coordinates_tag(collecting_event)
    return nil if collecting_event.nil? || collecting_event.map_center_method.nil?
    c = collecting_event.map_center
    content_tag(:span, [c.x.round(4), c.y.round(4)].join('&nbsp;&#8212;&nbsp;').html_safe)
  end

  def collecting_event_dates_tag(collecting_event)
    return nil if collecting_event.nil? || !collecting_event.has_some_date?
    s = collecting_event.date_range.join('&nbsp;&#8212;&nbsp;').html_safe
    a = ''
    a = content_tag(:span, s) if !s.blank?

    a << '&nbsp;'.html_safe + content_tag(:span, collecting_event.verbatim_date, class: [
      :feedback, 'feedback-thin', 'feedback-secondary' ]) if collecting_event.verbatim_date
    a.html_safe
  end

  def collecting_event_verbatim_locality_tag(collecting_event)
    return nil unless !(collecting_event&.verbatim_locality&.blank?)
    content_tag(:span, collecting_event.verbatim_locality)
  end

  def collecting_event_link(collecting_event)
    return nil if collecting_event.nil?
    link_to(collecting_event_tag(collecting_event).html_safe, collecting_event)
  end

  def collecting_events_search_form
    render('/collecting_events/quick_search_form')
  end

  def next_without_georeference_for_google_maps_link(collecting_event)
    if n = collecting_event.next_without_georeference
      link_to('Skip to next CE without georeference', new_georeferences_google_map_path(georeference: {collecting_event_id: n.to_param}), id: :next_without_georeference)
    else
      nil
    end
  end

  # @return [String]
  #   short string of use in autocomplete selects
  def collecting_event_namespace_select_tag
    select_tag(:ce_namespace, options_for_select(Namespace.pluck(:short_name).uniq), prompt: 'Select a namespace')
  end

  # @return [String, nil]
  #   summary of elevation data
  def elevation_tag(collecting_event)
    return nil if collecting_event.nil?
    [
      Utilities::Strings.nil_wrap(nil, [collecting_event.minimum_elevation, collecting_event.maximum_elevation].compact.join('-'), 'm'),
      Utilities::Strings.nil_wrap(' +/-', collecting_event.elevation_precision, nil)
    ].compact.join.html_safe
  end

  # @return [String, nil]
  #   summary of date data
  def date_range_tag(collecting_event)
    return if collecting_event.nil?
    [collecting_event.start_date_string, collecting_event.end_date_string].compact.join(' - ')
  end

  # @return [String, nil]
  #   summary of verbatim gis related data
  def verbatim_gis_tag(collecting_event)
    return if collecting_event.nil?
    [collecting_event.verbatim_latitude,
     collecting_event.verbatim_longitude,
     Utilities::Strings.nil_wrap(' (+/-', collecting_event.verbatim_geolocation_uncertainty, ')'),
     Utilities::Strings.nil_wrap(' [via ', collecting_event.verbatim_datum, ']'),
    ].compact.join(', ')
  end

  # @return [HTML] a pre tag formatting a label
  def collecting_event_label_tag(label_text)
    content_tag(:pre, label_text, class: [:large_type, :word_break] ) # large_type needs to be larger
  end

  # TODO: merge to a general next by identifier class (see also CO
  #
  # @return [link_to]
  #    this may not work for all identifier types, i.e. those with identifiers like `123.34` or `3434.33X` may not increment correctly
  def collecting_event_browse_previous_by_identifier(collecting_event)
    return nil if collecting_event.nil?
    o = collecting_event.previous_by_identifier
    return content_tag(:div, 'None', 'class' => 'navigation-item disable') if o.nil?
    link_text = content_tag(:span, 'Previous by id', 'class' => 'small-icon icon-left', 'data-icon' => 'arrow-left')
    link_to(link_text, browse_collecting_events_task_path(collecting_event_id: o.id), data: {
      arrow: :previous,
      'no-turbolinks' => 'true',
      help: 'Sorts by identifier type, namespace, then an conversion of identifier into integer.  Will not work for all identifier types.'},
      class: 'navigation-item')
  end

  # @return [link_to]
  #   this may not work for all identifier types, i.e. those with identifiers like `123.34` or `3434.33X` may not increment correctly
  def collecting_event_browse_next_by_identifier(collecting_event)
    return nil if collecting_event.nil?
    o = collecting_event.next_by_identifier
    return content_tag(:div, 'None', 'class' => 'navigation-item disable') if o.nil?
    link_text = content_tag(:span, 'Next by id', 'class' => 'small-icon icon-right', 'data-icon' => 'arrow-right')
    link_to(link_text, browse_collecting_events_task_path(collecting_event_id: o.id),
            data: {arrow: :next,
                   'no-turbolinks' => 'false',
                   help: 'Sorts by identifier type, namespace, then an conversion of identifier into integer.  Will not work for all identifier types.'}, class:'navigation-item')
  end


end
