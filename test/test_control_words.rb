require 'helper'

class TestControlWords < TestHelper
  context 'Scratch::ControlWords' do
    %w(exec times is_true? is_false? if_else? break? loop).each do |method|
      should "define :'#{method}'" do
        assert Scratch::ControlWords.instance_methods(false).include?( method )
      end
    end
    should "define :continue?"

    should "exec a list on the stack" do
      terp.run '[ 2 3 + ] exec'
      assert_equal_stack [5], terp.stack
    end

    context 'times method' do
      should "work" do
        terp.run '[ 2 3 + ] 5 times'
        assert_equal_stack [5, 5, 5, 5, 5], terp.stack
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
    end

    context 'continue? method' do
      should "work"
      should "raise StackTooSmall error when called with empty stack"
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
    end

    should "loop when calling loop method" do
      terp.run '1 [ dup 3 == break? dup 1 + ] loop'
      assert_equal_stack [1, 2, 3, 4], terp.stack
    end
  end
end
