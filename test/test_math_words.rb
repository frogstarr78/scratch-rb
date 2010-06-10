require 'helper'

class TestMathWords < TestHelper
  context 'Scratch::MathWords' do
    %w(+ - * / rt).each do |op|
      should "define #{op}"do
        assert Scratch::MathWords.instance_methods(false).include?( op )
      end
    end

    context "+ op" do
      should "works" do
        terp.run '1 1'
        assert_equal_stack [1, 1], terp.stack
        terp.run "+"
        assert_equal_stack [2], terp.stack
      end

      should "raise StackTooSmall error when called with an empty stack" do
        assert_equal_stack [], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "+"
        end
      end

      should "raise StackTooSmall error when called with one element in the stack" do
        terp.run '1'
        assert_equal_stack [1], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "+"
        end
      end
    end

    context "- op" do
      should "works" do
        terp.run '3 1'
        assert_equal_stack [3, 1], terp.stack
        terp.run "-"
        assert_equal_stack [2], terp.stack
      end

      should "raise StackTooSmall error when called with an empty stack" do
        assert_equal_stack [], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "-"
        end
      end

      should "raise StackTooSmall error when called with one element in the stack" do
        terp.run '1'
        assert_equal_stack [1], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "-"
        end
      end
    end

    context "* op" do
      should "works" do
        terp.run '3 1'
        assert_equal_stack [3, 1], terp.stack
        terp.run "*"
        assert_equal_stack [3], terp.stack
      end

      should "raise StackTooSmall error when called with an empty stack" do
        assert_equal_stack [], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "*"
        end
      end

      should "raise StackTooSmall error when called with one element in the stack" do
        terp.run '1'
        assert_equal_stack [1], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "*"
        end
      end
    end

    context "/ op" do
      should "works" do
        terp.run '8 2'
        assert_equal_stack [8, 2], terp.stack
        terp.run "/"
        assert_equal_stack [4], terp.stack
      end

      should "raise StackTooSmall error when called with an empty stack" do
        assert_equal_stack [], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "/"
        end
      end

      should "raise StackTooSmall error when called with one element in the stack" do
        terp.run '1'
        assert_equal_stack [1], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "/"
        end
      end
    end

    context "rt op" do
      should "works" do
        terp.run '25'
        assert_equal_stack [25], terp.stack
        terp.run "rt"
        assert_equal_stack [5], terp.stack
      end

      should "raise StackTooSmall error when called with an empty stack" do
        assert_equal_stack [], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "rt"
        end
      end
    end
  end
end
