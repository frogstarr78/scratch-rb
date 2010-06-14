require 'helper'

class TestMathWords < TestHelper
  context 'Scratch::MathWords' do
    %w(+ - * / √).each do |op|
      should "define #{op}"do
        assert Scratch::MathWords.instance_methods(false).include?( op )
      end
    end

    should "add last two stack items when + method is called" do
      terp.run '9 3'
      assert_equal_stack [9, 3], terp.stack
      terp.run "+"
      assert_equal_stack [12], terp.stack
    end

    should "subtract last two stack items when - method is called" do
      terp.run '8 3'
      assert_equal_stack [8, 3], terp.stack
      terp.run "-"
      assert_equal_stack [5], terp.stack
    end

    should "multiply last two stack items when * method is called" do
      terp.run '3 6'
      assert_equal_stack [3, 6], terp.stack
      terp.run "*"
      assert_equal_stack [18], terp.stack
    end

    should "divide last two stack items when / method is called" do
      terp.run '8 2'
      assert_equal_stack [8, 2], terp.stack
      terp.run "/"
      assert_equal_stack [4], terp.stack
    end

    should "square root last stack item when √ method is called" do
      terp.run '25'
      assert_equal_stack [25], terp.stack
      terp.run "√"
      assert_equal_stack [5], terp.stack
    end
  end
end
