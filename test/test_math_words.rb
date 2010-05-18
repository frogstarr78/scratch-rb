require 'helper'

class TestMathWords < TestHelper

  context 'Scratch::MathWords' do
    %w(+ - * / RT).each do |op|
      should "define #{op}"do
        assert Scratch::MathWords.instance_methods(false).include?( op )
      end
    end

  end

  context "+ op" do
    should "works" do
      terp.run '1 1'
      assert_equal [1, 1], terp.stack
      terp.run "+"
      assert_equal [2], terp.stack
    end

    should "raise StackTooSmall error when called with an empty stack" do
      assert_equal [], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "+"
      end
    end

    should "raise StackTooSmall error when called with one element in the stack" do
      terp.run '1'
      assert_equal [1], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "+"
      end
    end
  end

  context "- op" do
    should "works" do
      terp.run '3 1'
      assert_equal [3, 1], terp.stack
      terp.run "-"
      assert_equal [2], terp.stack
    end

    should "raise StackTooSmall error when called with an empty stack" do
      assert_equal [], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "-"
      end
    end

    should "raise StackTooSmall error when called with one element in the stack" do
      terp.run '1'
      assert_equal [1], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "-"
      end
    end
  end

  context "* op" do
    should "works" do
      terp.run '3 1'
      assert_equal [3, 1], terp.stack
      terp.run "*"
      assert_equal [3], terp.stack
    end

    should "raise StackTooSmall error when called with an empty stack" do
      assert_equal [], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "*"
      end
    end

    should "raise StackTooSmall error when called with one element in the stack" do
      terp.run '1'
      assert_equal [1], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "*"
      end
    end
  end

  context "/ op" do
    should "works" do
      terp.run '8 2'
      assert_equal [8, 2], terp.stack
      terp.run "/"
      assert_equal [4], terp.stack
    end

    should "raise StackTooSmall error when called with an empty stack" do
      assert_equal [], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "/"
      end
    end

    should "raise StackTooSmall error when called with one element in the stack" do
      terp.run '1'
      assert_equal [1], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "/"
      end
    end
  end

  context "√ op" do
    should "works" do
      terp.run '25'
      assert_equal [25], terp.stack
      terp.run "RT"
      assert_equal [5], terp.stack
    end

    should "raise StackTooSmall error when called with an empty stack" do
      assert_equal [], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "RT"
      end
    end
  end
end
