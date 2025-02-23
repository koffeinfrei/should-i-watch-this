require "json"

class HtmlExtractor
  def self.json_content(html, css_selector)
    first_element(html, css_selector) do |element|
      JSON.parse(element.inner_text.strip).as_h
    end || {} of String => JSON::Any
  end

  private def self.first_element(html, css_selector, &)
    elements = html.css(css_selector)

    if elements.size > 0
      yield elements.first
    end
  end
end
