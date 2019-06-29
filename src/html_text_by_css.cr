def html_text_by_css(html, expression)
  elements = html.css(expression)

  return nil if elements.size == 0

  elements.first.inner_text.strip
end
