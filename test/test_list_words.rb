require 'helper'

class TestListWords < TestHelper
  context 'Scratch::ListWords' do
    %w([ length item).each do |method|
      should "define '#{method}'" do
        assert Scratch::ListWords.instance_methods(false).include?( method )
      end
    end
  end

  context '[ method' do
    should "work"
  end

  context 'length method' do
    should "work"

    should "raise StackTooSmall error when called with an empty stack" do
      assert_equal [], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "length"
      end
    end
  end

  context 'item method' do
    should "work"

    should "raise StackTooSmall error when called with an empty stack" do
      assert_equal [], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "item"
      end
    end

    should "raise StackTooSmall error when called with one element in the stack" do
      terp.run '1'
      assert_equal [1], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "item"
      end
    end
  end
end
