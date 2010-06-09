require 'helper'

class TestPrintingWords < TestHelper
  context 'Scratch::PrintingWords' do
    %w(print puts pstack).each do |meth|
      should "define #{meth}"do
        assert Scratch::PrintingWords.instance_methods(false).include?( meth )
      end
    end

    should "'puts' an element from the stack" do
      terp.expects(:puts)
      terp.run '4'
      assert_equal_stack [4], terp.stack
      terp.run "puts"
    end

    should "raise StackTooSmall error when 'puts' is called with an empty stack" do
      assert_equal_stack [], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "puts"
      end
    end

    should "puts stack when 'pstack' is called" do
      terp.expects(:pstack)
      terp.run '5'
      assert_equal_stack [5], terp.stack
      terp.run "pstack"
    end
  end
end
