require 'helper'

class TestMathWords < TestHelper
  context 'Scratch::StackWords' do
    %w(dup drop swap over rot).each do |meth|
      should "define #{meth}"do
        assert Scratch::StackWords.instance_methods(false).include?( meth )
      end
    end

    should "duplicate last item when dup called" do
      terp.run '0 1'
      assert_equal_stack [0, 1], terp.stack
      terp.run "dup"
      assert_equal_stack [0, 1, 1], terp.stack
    end

    should "drop last itme when drop called" do
      terp.run '2 3'
      assert_equal_stack [2, 3], terp.stack
      terp.run "drop"
      assert_equal_stack [2], terp.stack
    end

    should "switch last two items on stack when swap is called" do
      terp.run '4 3'
      assert_equal_stack [4, 3], terp.stack
      terp.run "swap"
      assert_equal_stack [3, 4], terp.stack
    end

    should "appends the second to last item onto the end when over is called" do
      terp.run '5 4'
      assert_equal_stack [5, 4], terp.stack
      terp.run "over"
      assert_equal_stack [5, 4, 5], terp.stack
    end

    should "rotate last three stack items when rot is called" do
      terp.run '6 4 5'
      assert_equal_stack [6, 4, 5], terp.stack
      terp.run "rot"
      assert_equal_stack [4, 5, 6], terp.stack
    end
  end
end
