require 'helper'

class TestObjectClass < TestHelper
  should ":is_array? is false" do
    assert_equal false, Object.new.is_array?
  end
end
