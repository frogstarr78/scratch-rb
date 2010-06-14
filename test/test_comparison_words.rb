require 'helper'

class TestComparisonWords < TestHelper
  context 'Scratch::ComparisonWords' do
    %w(< <= == >= >).each do |method|
      should "define '#{method}'" do
        assert Scratch::ComparisonWords.instance_methods(false).include?( method )
      end
    end

    should "correctly compare last two stack items using <=" do
      terp.run "1 2 <"
      assert_equal_stack [true], terp.stack

      terp.stack.clear

      terp.run "2 1 <"
      assert_equal_stack [false], terp.stack
      terp.stack.clear

      terp.run "2 2 <"
      assert_equal_stack [false], terp.stack
    end

    should "correctly compare last two stack items using <=" do
      terp.run "1 2 <="
      assert_equal_stack [true], terp.stack

      terp.stack.clear

      terp.run "2 1 <="
      assert_equal_stack [false], terp.stack

      terp.stack.clear

      terp.run "2 2 <="
      assert_equal_stack [true], terp.stack
    end

    should "correctly compare last two stack items using ==" do
      terp.run "1 2 =="
      assert_equal_stack [false], terp.stack

      terp.stack.clear

      terp.run "2 1 =="
      assert_equal_stack [false], terp.stack

      terp.stack.clear

      terp.run "2 2 =="
      assert_equal_stack [true], terp.stack
    end

    should "correctly compare last two stack items using >=" do
      terp.run "1 2 >="
      assert_equal_stack [false], terp.stack

      terp.stack.clear

      terp.run "2 1 >="
      assert_equal_stack [true], terp.stack

      terp.stack.clear

      terp.run "2 2 >="
      assert_equal_stack [true], terp.stack
    end

    should "correctly compare last two stack items using >" do
      terp.run "1 2 >"
      assert_equal_stack [false], terp.stack

      terp.stack.clear

      terp.run "2 1 >"
      assert_equal_stack [true], terp.stack
      terp.stack.clear

      terp.run "2 2 >"
      assert_equal_stack [false], terp.stack
    end
  end
end
