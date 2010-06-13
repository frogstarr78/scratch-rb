require 'helper'

class TestArrayClass < TestHelper
  should ":is_array? is true" do
    assert_equal true, [].is_array?
  end
end
