require 'helper'

class TestPrintingWords < TestHelper
  context 'Scratch::PrintingWords' do
    %w(print puts pstack).each do |meth|
      should "define #{meth}"do
        assert Scratch::PrintingWords.instance_methods(false).include?( meth )
      end
    end

    should "puts stack items when calling #puts" do
      Kernel.expects(:puts).with 4
      terp.run '4'
      assert_equal_stack [4], terp.stack
      terp.run "puts"
    end

    should "print stack items when calling #print" do
      terp.run '6'
      Kernel.expects(:print).with 6
      assert_equal_stack [6], terp.stack
      terp.run 'print'
    end

    should "puts stack when 'pstack' is called" do
      terp.run '5'
      Kernel.expects(:puts).with terp.stack.stack
      assert_equal_stack [5], terp.stack
      terp.run "pstack"
    end
  end
end
