require 'helper'

class TestStringExt < TestHelper
  context "blank?" do
    should "be true when ''" do
      assert ''.blank?, "'' unexpectedly not blank"
    end

    should "be false when not ''" do
      assert !' '.blank?, "' ' unexpectedly blank"
    end

    context "is_numeric?" do
      should "be numeric when the whole string is a number" do
        assert "1234".is_numeric?, "'1234'.is_numeric? was unexpectedly false"
      end

      should "not be numeric when the string starts with a non-numeric" do
        assert !"a1234".is_numeric?, "'a1234'.is_numeric? was unexpectedly true"
      end

      should "not be a numeric when the string ends with a non-numeric" do
        assert !"1234a".is_numeric?, "'1234a'.is_numeric? was unexpectedly true"
      end

      should "not be numeric when there is a non-numeric in the middle of the string" do
        assert !"12.34".is_numeric?, "'1234'.is_numeric? was unexpectedly true"
      end
    end

    context "is_whitespace?" do
      should 'be false with non-whitespace character' do
        assert !"a".is_whitespace?, '"a".is_whitespace? was unexpectedly true'
      end

      should 'be false with "\b" character' do
        assert !"\b".is_whitespace?, '"\b".is_whitespace? was unexpectedly true'
      end

      should 'be true with ""' do
        assert "".is_whitespace?, '"".is_whitespace? was unexpectedly false'
      end
      should 'be true with " "' do
        assert " ".is_whitespace?, '" ".is_whitespace? was unexpectedly false'
      end
      should 'be true with "\t"' do
        assert "\t".is_whitespace?, '"\t".is_whitespace? was unexpectedly false'
      end
      should 'be true with "\r"' do
        assert "\r".is_whitespace?, '"\r".is_whitespace? was unexpectedly false'
      end
      should 'be true with "\n"' do
        assert "\n".is_whitespace?, '"\n".is_whitespace? was unexpectedly false'
      end
      should 'be true with "\v"' do
        assert "\v".is_whitespace?, '"\v".is_whitespace? was unexpectedly false'
      end
    end
  end
end
