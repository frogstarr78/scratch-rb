require 'helper'

class TestCompilingWords < TestHelper
  context 'Scratch::CompilingWords' do
    %w(def end).each do |method|
      should "define '#{method}'" do
        assert Scratch::CompilingWords.instance_methods(false).include?( method )
      end
    end

    context 'def method' do
      should "work" do
        assert_nil terp.latest
        assert_equal false, terp.stack.compiling?
        terp.run 'def cube_root'
        assert_equal 'cube_root', terp.latest
        assert_equal true, terp.stack.compiling? 
      end

      should "raise UnexpectedEOI error when there isn't a function name" do
        assert_raise Scratch::UnexpectedEOI do
          terp.run 'def'
        end
      end
    end

    context 'end method' do
      setup do
        @function_body = 'dup *'
        terp.run "2 #@function_body"
        @expectation = terp.stack.data
        terp.stack.clear
      end

      should "work" do
        assert_nil terp.latest
        assert_equal false, terp.stack.compiling?
        assert !terp.respond_to?(:square)
        terp.run "def square #@function_body"
        assert_equal 'square', terp.latest
        assert_equal true, terp.stack.compiling? 
        assert_equal_compiling_stack [terp.method(:dup), terp.method(:"*")], terp.stack
        assert_equal_stack [], terp.stack
        terp.run 'end'
        assert_nil terp.latest
        assert_respond_to terp, :square
        assert_equal false, terp.stack.compiling? 

        terp.stack.clear
        terp.run '2 square'
        assert_equal_stack @expectation, terp.stack

        terp.run '2'
        terp.square
        assert_equal_stack @expectation, terp.stack
      end
    end
  end
end
