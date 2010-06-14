require 'helper'

class TestLogicWords < TestHelper
  context 'Scratch::LogicWords' do
    %w(true false and or not).each do |method|
      should "define '#{method}'" do
        assert Scratch::LogicWords.instance_methods(false).include?( method )
      end
    end

    should "push actual true value onto stack" do
      terp.run "true"
      assert_equal_stack [true], terp.stack
    end

    should "push actual false value onto stack" do
      terp.run "false"
      assert_equal_stack [false], terp.stack
    end

    should "correctly 'and' last two items in stack" do
      terp.run "true true and"
      assert_equal_stack [true], terp.stack

      terp.stack.clear

      terp.run "true false and"
      assert_equal_stack [false], terp.stack

      terp.stack.clear

      terp.run "false false and"
      assert_equal_stack [false], terp.stack
    end

    should "correctly 'or' last two items in stack" do
      terp.run "true true or"
      assert_equal_stack [true], terp.stack

      terp.stack.clear

      terp.run "true false or"
      assert_equal_stack [true], terp.stack

      terp.stack.clear

      terp.run "false false or"
      assert_equal_stack [false], terp.stack
    end

    should "correctly 'not' last item in stack" do
      terp.run "true not"
      assert_equal_stack [false], terp.stack

      terp.stack.clear

      terp.run "false not"
      assert_equal_stack [true], terp.stack
    end
  end
end
