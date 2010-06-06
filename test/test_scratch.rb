require 'helper'

class TestScratch < TestHelper
  context "stack" do
    should "add literals to stack" do
      terp.run '1 2 3'
      assert_equal [1, 2, 3], terp.stack
    end

    context "Scratch::Scratch" do
      should "include modules" do
        assert Scratch::Scratch.include?(Scratch::PrintingWords)
        assert Scratch::Scratch.include?(Scratch::MathWords)
        assert Scratch::Scratch.include?(Scratch::StackWords)
        assert Scratch::Scratch.include?(Scratch::VariableWords)
        assert Scratch::Scratch.include?(Scratch::ConstantWords)
        assert Scratch::Scratch.include?(Scratch::StringWords)
        assert Scratch::Scratch.include?(Scratch::CommentWords)
        assert Scratch::Scratch.include?(Scratch::CompilingWords)
        assert Scratch::Scratch.include?(Scratch::ListWords)
        assert Scratch::Scratch.include?(Scratch::LogicWords)
        assert Scratch::Scratch.include?(Scratch::ComparisonWords)
        assert Scratch::Scratch.include?(Scratch::ControlWords)
      end

      context "import module" do
        should "be defined" do
          assert_respond_to Scratch::Scratch, :<
        end
      end

      context "interpret" do
        should "call a method argument" do
          assert_respond_to terp, :true
          terp.expects :true
          terp.interpret terp.method(:true)
        end

        should "can call external methods" do
          klass = self.method(:class)
          klass.expects :call
          terp.interpret klass
        end

        should "push non-method arguments onto the stack" do
          arg = 'hello'
          terp.stack.expects(:<<).with arg
          terp.interpret arg
        end
      end

      context "compile" do
        should "convert method name argument to instance method" do
          assert_respond_to terp, :true
          method = terp.compile 'true'
          assert_equal terp.method(:true), method
        end

        should "convert non-method, integer type arguments to integers" do
          assert_equal 1, terp.compile('1')
        end

        should "raise error on non-method non-integer type arguments" do
          assert_raise RuntimeError, "Unknown word 'something_that_is_neither_a_method_name_or_integer'." do
            terp.compile 'something_that_is_neither_a_method_name_or_integer'
          end
        end
      end
    end
  end
end
