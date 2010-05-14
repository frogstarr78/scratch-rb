require 'helper'

class TestNilClass < Test::Unit::TestCase
  should "be blank?" do
    assert nil.blank?, "nil unexpectedly not blank"
  end
end
