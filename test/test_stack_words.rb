require 'helper'

class TestMathWords < TestHelper
  context 'Scratch::StackWords' do
    %w(dup drop swap over rot).each do |meth|
      should "define #{meth}"do
        assert Scratch::StackWords.instance_methods(false).include?( meth )
      end
    end

    context "dup method" do
      should "work" do
        terp.run '0 1'
        assert_equal_stack [0, 1], terp.stack
        terp.run "dup"
        assert_equal_stack [0, 1, 1], terp.stack
      end

      should "raise StackTooSmall error when called with an empty stack" do
        assert_equal_stack [], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "dup"
        end
      end
    end

    context "drop method" do
      should "work" do
        terp.run '2 3'
        assert_equal_stack [2, 3], terp.stack
        terp.run "drop"
        assert_equal_stack [2], terp.stack
      end

      should "raise StackTooSmall error when called with an empty stack" do
        assert_equal_stack [], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "drop"
        end
      end
    end

    context "swap method" do
      should "work" do
        terp.run '4 3'
        assert_equal_stack [4, 3], terp.stack
        terp.run "swap"
        assert_equal_stack [3, 4], terp.stack
      end

      should "raise StackTooSmall error when called with an empty stack" do
        assert_equal_stack [], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "swap"
        end
      end

      should "raise StackTooSmall error when called with stack size of 1" do
        terp.run '3'
        assert_equal_stack [3], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "swap"
        end
      end
    end

    context "over method" do
      should "work" do
        terp.run '5 4'
        assert_equal_stack [5, 4], terp.stack
        terp.run "over"
        assert_equal_stack [5, 4, 5], terp.stack
      end

      should "raise StackTooSmall error when called with an empty stack" do
        assert_equal_stack [], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "over"
        end
      end

      should "raise StackTooSmall error when called with stack size of 1" do
        terp.run '3'
        assert_equal_stack [3], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "over"
        end
      end
    end

    context "rot method" do
      should "work" do
        terp.run '6 4 5'
        assert_equal_stack [6, 4, 5], terp.stack
        terp.run "rot"
        assert_equal_stack [4, 5, 6], terp.stack
      end

      should "raise StackTooSmall error when called with an empty stack" do
        assert_equal_stack [], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "rot"
        end
      end

      should "raise StackTooSmall error when called with stack size of 1" do
        terp.run '3'
        assert_equal_stack [3], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "rot"
        end
      end

      should "raise StackTooSmall error when called with stack size of 2" do
        terp.run '3 2'
        assert_equal_stack [3, 2], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "rot"
        end
      end
    end
  end
end
