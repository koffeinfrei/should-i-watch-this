class HtmlExtractor
  def self.text(html, css_selector)
    first_element(html, css_selector) do |element|
      element.inner_text.strip
    end
  end

  def self.attribute_value(html, css_selector)
    first_element(html, css_selector) do |element|
      element.attribute_by("href")
    end
  end

  private def self.first_element(html, css_selector)
    elements = html.css(css_selector)

    if elements.size > 0
      yield elements.first
    end
  end
end
