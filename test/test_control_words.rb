require 'helper'

class TestControlWords < TestHelper
  context 'Scratch::ControlWords' do
    %w(exec times is_true? is_false? if_else? break? loop).each do |method|
      should "define :'#{method}'" do
        assert Scratch::ControlWords.instance_methods(false).include?( method )
      end
    end
    should "define :continue?"

    context 'exec method' do
      should "work" do
        terp.run '[ 2 3 + ] exec'
        assert_equal_stack [5], terp.stack
      end

      should "raise StackTooSmall error when called with empty stack" do
        assert_raise Scratch::StackTooSmall do
          terp.run 'exec'
        end
      end
      should "raise MissingListExpectation error the stack doesn't have a list" do
        assert_raise Scratch::MissingListExpectation do
          terp.run '2 3 + exec'
        end
      end
    end

    context 'times method' do
      should "work" do
        terp.run '[ 2 3 + ] 5 times'
        assert_equal_stack [5, 5, 5, 5, 5], terp.stack
      end

      should "raise StackTooSmall error when called with empty stack" do
        assert_raise Scratch::StackTooSmall do
          terp.run 'times'
        end
      end
      should "raise StackTooSmall error when called with one element in the stack" do
        terp.run '[ 3 2 + ]'
        assert_raise Scratch::StackTooSmall do
          terp.run 'times'
        end

        terp.stack.clear
        terp.run '3'
        assert_raise Scratch::StackTooSmall do
          terp.run 'times'
        end
      end

      should "raise MissingListExpectation error when the first element in the stack isn't a list" do
        terp.run '3 3'
        assert_raise Scratch::MissingListExpectation do
          terp.run 'times'
        end
      end
    end

    context 'is_true? method' do
      should "work when true" do
        terp.run 'true [ 3 dup ] is_true?'
        assert_equal_stack [3, 3], terp.stack
      end

      should "work when not true" do
        terp.run 'false [ 4 dup ] is_true?'
        assert_equal_stack [], terp.stack
      end

      should "raise StackTooSmall error when called with empty stack" do
        assert_equal_stack [], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run 'is_true?'
        end
      end

      should "raise StackTooSmall error when called with one element in the stack" do
        terp.run 'true'
        assert_raise Scratch::StackTooSmall do
          terp.run 'is_true?'
        end

        terp.stack.clear
        terp.run '[ 1 4 + ]'
        assert_raise Scratch::StackTooSmall do
          terp.run 'is_true?'
        end
      end

      should "raise MissingListExpectation error when the second element in the stack isn't a list" do
        terp.run 'true 3'
        assert_raise Scratch::MissingListExpectation do
          terp.run 'is_true?'
        end
      end
    end

    context 'is_false? method' do
      should "work when true" do
        terp.run 'true [ 2 1 - ] is_false?'
        assert_equal_stack [], terp.stack
      end

      should "work when false" do
        terp.run 'false [ 9 1 - ] is_false?'
        assert_equal_stack [8], terp.stack
      end

      should "raise StackTooSmall error when called with empty stack" do
        assert_equal_stack [], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run 'is_false?'
        end
      end

      should "raise StackTooSmall error when called with one element in the stack" do
        terp.run 'false'
        assert_raise Scratch::StackTooSmall do
          terp.run 'is_false?'
        end

        terp.stack.clear
        terp.run '[ 1 9 + ]'
        assert_raise Scratch::StackTooSmall do
          terp.run 'is_false?'
        end
      end

      should "raise MissingListExpectation error when the first element in the stack isn't a list" do
        terp.run 'false 3'
        assert_raise Scratch::MissingListExpectation do
          terp.run 'is_false?'
        end
      end
    end

    context 'if_else? method' do
      should "work when true" do
        terp.run 'true [ 3 dup ] [ 4 dup ] if_else?'
        assert_equal_stack [3, 3], terp.stack
      end

      should "work when false" do
        terp.run 'false [ 3 dup ] [ 4 dup ] if_else?'
        assert_equal_stack [4, 4], terp.stack
      end

      should "raise StackTooSmall error when called with empty stack" do
        assert_equal_stack [], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run 'if_else?'
        end
      end

      should "raise StackTooSmall error when called with one element in the stack" do
        terp.run 'true'
        assert_raise Scratch::StackTooSmall do
          terp.run 'if_else?'
        end

        terp.stack.clear
        terp.run '[ 5 dup ]'
        assert_raise Scratch::StackTooSmall do
          terp.run 'if_else?'
        end
      end

      should "raise StackTooSmall error when called with two elements in the stack" do
        terp.run 'true [ 5 dup ]'
        assert_raise Scratch::StackTooSmall do
          terp.run 'if_else?'
        end

        terp.stack.clear
        terp.run '[ 5 dup ] [ 3 dup ]'
        assert_raise Scratch::StackTooSmall do
          terp.run 'if_else?'
        end
      end

      should "raise MissingListExpectation error when the second element in the stack isn't a list" do
        terp.run '5 [ 3 dup ]'
        assert_raise Scratch::MissingListExpectation do
          terp.run 'if_else?'
        end
      end

      should "raise MissingListExpectation error when the third element in the stack isn't a list" do
        terp.run 'true [ 3 dup ] 5'
        assert_raise Scratch::MissingListExpectation do
          terp.run 'if_else?'
        end
      end
    end

    context 'continue? method' do
      should "work"
      should "raise StackTooSmall error when called with empty stack" #do
#        assert_equal [], terp.stack
#        assert_raise Scratch::StackTooSmall do
#          terp.run 'continue?'
#        end
#      end
    end

    context 'break? method' do
      should "work when true" do
        terp.expects(:break_state=).with true
        terp.run 'true break?'
      end

      should "work when false" do
        terp.expects(:break_state=).with(true).never
        terp.run 'false break?'
      end

      should "raise StackTooSmall error when called with empty stack" do
        assert_equal_stack [], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run 'break?'
        end
      end
    end

    context 'loop method' do
      should "work" do
        terp.run '1 [ dup 3 == break? dup 1 + ] loop'
        assert_equal_stack [1, 2, 3, 4], terp.stack
      end

      should "raise StackTooSmall error when called with empty stack" do
        assert_equal_stack [], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run 'loop'
        end
      end

      should "raise MissingListExpectation error when the first element in the stack isn't a list" do
        terp.run 'dup'
        assert_raise Scratch::MissingListExpectation do
          terp.run 'loop'
        end
      end
    end
  end
end
