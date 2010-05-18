require 'helper'

class TestNilClass < TestHelper
  should "be blank?" do
    assert nil.blank?, "nil unexpectedly not blank"
  end
end
