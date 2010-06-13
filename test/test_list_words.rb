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

    context 'length method' do
      should "work" do
        terp.run '[ 1 2 3 ] length'
        assert_equal_stack [3], terp.stack
      end

      should "raise StackTooSmall error when called with an empty stack" do
        assert_equal_stack [], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "length"
        end
      end

      should "raise MissingListExpectation error when first element on the stack isn't an array" do
        terp.run '1'
        assert_equal_stack [1], terp.stack
        assert_raise Scratch::MissingListExpectation do
          terp.run "length"
        end
      end
    end

    context 'item method' do
      should "work" do
        terp.run '[ 9 3 6 ] 0 item' 
        assert_equal_stack [9], terp.stack

        terp.stack.clear 
        terp.run '[ 9 3 6 ] 1 item' 
        assert_equal_stack [3], terp.stack

        terp.stack.clear 
        terp.run '[ 9 3 6 ] 2 item' 
        assert_equal_stack [6], terp.stack
      end

      should "raise StackTooSmall error when called with an empty stack" do
        assert_equal_stack [], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "item"
        end
      end

      should "raise StackTooSmall error when called with one element in the stack" do
        terp.run '[ 1 2 3 ]'
        assert_equal_stack [[1,2,3]], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "item"
        end

        terp.stack.clear
        terp.run '3'
        assert_equal_stack [3], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "item"
        end
      end

      should "raise MissingListExpectation error when first element on the stack isn't an array" do
        terp.run '1 1'
        assert_equal_stack [1, 1], terp.stack
        assert_raise Scratch::MissingListExpectation do
          terp.run "item"
        end
      end
    end
  end
end
