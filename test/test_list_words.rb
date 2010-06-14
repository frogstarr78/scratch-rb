require 'helper'

class TestListWords < TestHelper
  context 'Scratch::ListWords' do
    %w([ length item).each do |method|
      should "define '#{method}'" do
        assert Scratch::ListWords.instance_methods(false).include?( method )
      end
    end

    context '[ method' do
      should "work" do
        terp.run "[ 41 42 44 ]"
        assert_equal_stack [[41,42,44]], terp.stack
      end

      should "raise UnexpectedEOI error when ] isn't found" do
        assert_equal_stack [], terp.stack
        assert_raise Scratch::UnexpectedEOI do
          terp.run "[ 1 2 3 "
        end
      end
    end

    should "return correct lenght of stack array item" do
      terp.run '[ 1 2 3 ] length'
      assert_equal_stack [3], terp.stack
    end

    should "return indexed item from stack when item called" do
      terp.run '[ 9 3 6 ] 0 item' 
      assert_equal_stack [9], terp.stack

      terp.stack.clear 
      terp.run '[ 9 3 6 ] 1 item' 
      assert_equal_stack [3], terp.stack

      terp.stack.clear 
      terp.run '[ 9 3 6 ] 2 item' 
      assert_equal_stack [6], terp.stack
    end
  end
end
