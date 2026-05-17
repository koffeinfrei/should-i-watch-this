require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "#format_quote" do
    assert_dom_equal(
    %(<blockquote class="quote">“ <span class="quote-dialog">Striker:</span> Surely you can't be serious.<br><span class="quote-dialog">Rumack:</span> I am serious … and don't call me Shirley. ”</blockquote>),
      format_quote("Striker: Surely you can't be serious.\nRumack: I am serious … and don't call me Shirley.")
    )

    assert_dom_equal(
      %(<blockquote class="quote">“ You've got to ask yourself one question: 'Do I feel lucky?' Well, do ya, punk? ”</blockquote>),
      format_quote("You've got to ask yourself one question: 'Do I feel lucky?' Well, do ya, punk?")
    )
  end
end
