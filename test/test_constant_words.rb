require 'helper'

class TestConstantWords < TestHelper

  context 'Scratch::ConstantWords' do
    should "define" do
      assert Scratch::ConstantWords.instance_methods(false).include?( 'const' )
    end
  end

  context "const method" do
    should "work" do
      assert !terp.respond_to?( :Q )
      terp.run "5 const Q"
      assert_equal 5, terp.Q
    end

    should "error when trying to re-assign a constant" do
      assert !terp.respond_to?( :P )
      terp.run "5 const P"
      assert_equal 5, terp.P
      assert_raise Scratch::ConstantReDefine do
        terp.run "9 const P"
      end
    end

    should "raise UnexpectedEOI error when called without a const name" do
      assert_equal [], terp.stack
      assert_raise Scratch::UnexpectedEOI do
        terp.run "10 const"
      end
    end

    should "raise StackTooSmall error when called with an empty stack" do
      assert_equal [], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "const"
      end
    end
  end
end
