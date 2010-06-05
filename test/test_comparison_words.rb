require 'helper'

class TestComparisonWords < TestHelper
  context 'Scratch::ComparisonWords' do
    %w(< <= == >= >).each do |method|
      should "define '#{method}'" do
        assert Scratch::ComparisonWords.instance_methods(false).include?( method )
      end
    end

  end

  context "< method" do
    should "work" do
      terp.run "1 2 <"
      assert_equal [true], terp.stack

      terp.stack.clear

      terp.run "2 1 <"
      assert_equal [false], terp.stack
      terp.stack.clear

      terp.run "2 2 <"
      assert_equal [false], terp.stack
    end

    should "raise StackTooSmall error when called with an empty stack" do
      assert_equal [], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "<"
      end
    end

    should "raise StackTooSmall error when called with one element in the stack" do
      terp.run '1'
      assert_equal [1], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "<"
      end
    end
  end

  context "<= method" do
    should "work" do
      terp.run "1 2 <="
      assert_equal [true], terp.stack

      terp.stack.clear

      terp.run "2 1 <="
      assert_equal [false], terp.stack

      terp.stack.clear

      terp.run "2 2 <="
      assert_equal [true], terp.stack
    end

    should "raise StackTooSmall error when called with an empty stack" do
      assert_equal [], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "<"
      end
    end

    should "raise StackTooSmall error when called with one element in the stack" do
      terp.run '1'
      assert_equal [1], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "<"
      end
    end
  end

  context "== method" do
    should "work" do
      terp.run "1 2 =="
      assert_equal [false], terp.stack

      terp.stack.clear

      terp.run "2 1 =="
      assert_equal [false], terp.stack

      terp.stack.clear

      terp.run "2 2 =="
      assert_equal [true], terp.stack
    end

    should "raise StackTooSmall error when called with an empty stack" do
      assert_equal [], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "=="
      end
    end

    should "raise StackTooSmall error when called with one element in the stack" do
      terp.run '1'
      assert_equal [1], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run "=="
      end
    end
  end

  context ">= method" do
    should "work" do
      terp.run "1 2 >="
      assert_equal [false], terp.stack

      terp.stack.clear

      terp.run "2 1 >="
      assert_equal [true], terp.stack

      terp.stack.clear

      terp.run "2 2 >="
      assert_equal [true], terp.stack
    end

    should "raise StackTooSmall error when called with an empty stack" do
      assert_equal [], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run ">="
      end
    end

    should "raise StackTooSmall error when called with one element in the stack" do
      terp.run '1'
      assert_equal [1], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run ">="
      end
    end
  end

  context "> method" do
    should "work" do
      terp.run "1 2 >"
      assert_equal [false], terp.stack

      terp.stack.clear

      terp.run "2 1 >"
      assert_equal [true], terp.stack
      terp.stack.clear

      terp.run "2 2 >"
      assert_equal [false], terp.stack
    end

    should "raise StackTooSmall error when called with an empty stack" do
      assert_equal [], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run ">"
      end
    end

    should "raise StackTooSmall error when called with one element in the stack" do
      terp.run '1'
      assert_equal [1], terp.stack
      assert_raise Scratch::StackTooSmall do
        terp.run ">"
      end
    end
  end

end
