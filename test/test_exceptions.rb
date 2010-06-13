require 'helper'

class TestExceptions < TestHelper
  context 'Scratch::Exceptions' do
    should "have correct message for UnexpectedEOI" do
      exception = Scratch::UnexpectedEOI.new
      assert_equal "Unexpected end of input", exception.message
    end

    should "have correct message for ConstantReDefine" do
      exception = Scratch::ConstantReDefine.new Array
      assert_equal "Unable to redefine constant Array", exception.message
    end

    should "have correct message for InvalidType" do
      exception = Scratch::InvalidType.new Array, Fixnum
      assert_equal "Expecting a(n) 'Array' class, but received a(n) 'Fixnum' class instead.", exception.message
    end
  end
end
