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

        # TODO: Figure out if this is a bug or acceptable
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

      context "run" do
        context "interfacing with the lexer" do
          setup do
            @string_to_parse = '3 dup'
            @mock_lexer = Scratch::ScratchLexer.new @string_to_parse
          end

          should "initialize a new one" do
            Scratch::ScratchLexer.expects(:new).with(@string_to_parse).returns @mock_lexer
            terp.run @string_to_parse
          end

          should "call next_word" do
            terp.send :stack=, ['3']
            terp.send :lexer=, @mock_lexer
            until_nil_word = sequence('until word.nil?')

            Scratch::ScratchLexer.any_instance.expects(:next_word).in_sequence(until_nil_word).returns '3'
            Scratch::ScratchLexer.any_instance.expects(:next_word).in_sequence(until_nil_word).returns 'dup'
            Scratch::ScratchLexer.any_instance.expects(:next_word).in_sequence(until_nil_word).returns nil
            terp.run @string_to_parse
          end
        end

        should "immediately interpret Scratch::IMMEDIATES" do
          assert Scratch::Scratch::IMMEDIATES.include?( 'false' )
          terp.expects(:compiling?).returns(true).never
          # if this doesn't get caught by the IMMEDIATES condition
          # it should fail because of the compiling? condition
          terp_false_method = terp.method :false
          terp.expects(:compile).with('false').returns terp_false_method
          terp.run 'false'
          assert_equal [false], terp.stack, "Code didn't follow IMMEDIATES include? conditional as expected"
          assert_not_equal ['false'], terp.stack, "Code followed compiling? conditional unexpectedly"
        end

        should "push items onto the buffer if we're compiling" do
          terp.expects(:compiling?).returns true
          dup_method = terp.method(:dup)
          terp.stack.expects(:<<).with dup_method
          terp.run 'dup'
        end

        should "interpret tokens that aren't IMMEDIATES when we're not compiling" do
          assert Scratch::Scratch::IMMEDIATES.include?( 'false' )
          terp.expects(:compiling?).returns(false)
          terp.send :stack=, [28]
          terp_dup_method = terp.method :dup
          terp.expects(:compile).with('dup').returns terp_dup_method
          terp_dup_method.expects :call
          terp.run 'dup'
        end
      end

      context "make_word" do
        should "create lambda from supplied list" do
          code_argument = ['1', "hello", terp.method(:dup), terp.method(:false) ]
          assert_equal [], terp.stack

          res = terp.send :make_word, code_argument
          assert_instance_of Proc, res
          res.call
          assert_equal ['1', "hello", "hello", false], terp.stack
        end
      end
    end
  end
end
