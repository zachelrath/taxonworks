module LugsHelper

  def lug_tag(lug)
    return nil if lug.nil?
    lug.text 
  end

  def lug_link(lug)
    return nil if lug.nil?
    link_to(lug_tag(lug).html_safe, lug)
  end

end
