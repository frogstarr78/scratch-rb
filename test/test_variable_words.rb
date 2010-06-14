require 'helper'

class TestVariableWords < TestHelper
  context 'Scratch::VariableWords' do
    %w(var store fetch).each do |meth|
      should "define #{meth}"do
        assert Scratch::VariableWords.instance_methods(false).include?( meth )
      end
    end

    context "var method" do
      should "initializes a variable" do
        assert !terp.respond_to?( :a )
        terp.run 'var a'
        assert_equal_stack [], terp.stack
        assert_respond_to terp, :a
        terp.a
        assert_instance_of Scratch::Variable, terp.stack.pop
      end

      should "raise UnexpectedEOI error when called with an empty stack" do
        assert_equal_stack [], terp.stack
        assert_raise Scratch::UnexpectedEOI do
          terp.run "var"
        end
      end
    end

    should "set the value of the variable when store method called" do
      assert !terp.respond_to?( :b )
      terp.run 'var b'
      terp.run '1 b store'
      assert_instance_of Scratch::Variable, terp.b.pop
      assert_respond_to terp, :b
    end

    should "gets the variable value when fetch is called" do
      assert !terp.respond_to?( :e )
      terp.run 'var e'
      terp.run '1 e store'
      terp.run 'e fetch'
      assert_equal_stack [1], terp.stack
    end
  end
end
