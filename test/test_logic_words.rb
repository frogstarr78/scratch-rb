require 'helper'

class TestLogicWords < TestHelper
  context 'Scratch::LogicWords' do
    %w(true false and or not).each do |method|
      should "define '#{method}'" do
        assert Scratch::LogicWords.instance_methods(false).include?( method )
      end
    end
  end

  context 'true method' do
    should "work" do
      terp.run "true"
      assert_equal [true], terp.stack
    end
  end

  context 'false method' do
    should "work" do
      terp.run "false"
      assert_equal [false], terp.stack
    end
  end

  context 'and method' do
    should "work" do
      terp.run "true true and"
      assert_equal [true], terp.stack

      terp.stack.clear

      terp.run "true false and"
      assert_equal [false], terp.stack

      terp.stack.clear

      terp.run "false false and"
      assert_equal [false], terp.stack
    end

    should "raise StackTooSmall error when called with an empty stack" do
      assert_equal [], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "and"
      end
    end

    should "raise StackTooSmall error when called with one element in the stack" do
      terp.run 'true'
      assert_equal [true], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "and"
      end
    end
  end

  context 'or method' do
    should "work" do
      terp.run "true true or"
      assert_equal [true], terp.stack

      terp.stack.clear

      terp.run "true false or"
      assert_equal [true], terp.stack

      terp.stack.clear

      terp.run "false false or"
      assert_equal [false], terp.stack
    end

    should "raise StackTooSmall error when called with an empty stack" do
      assert_equal [], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "and"
      end
    end

    should "raise StackTooSmall error when called with one element in the stack" do
      terp.run 'true'
      assert_equal [true], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "and"
      end
    end
  end

  context 'not method' do
    should "work" do
      terp.run "true not"
      assert_equal [false], terp.stack

      terp.stack.clear

      terp.run "false not"
      assert_equal [true], terp.stack
    end

    should "raise StackTooSmall error when called with an empty stack" do
      assert_equal [], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "not"
      end
    end
  end
end
