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
        assert_equal [], terp.stack
        assert_respond_to terp, :a
        terp.a
        assert_instance_of Scratch::Variable, terp.stack.pop
      end

      should "raise UnexpectedEOI error when called with an empty stack" do
        assert_equal [], terp.stack
        assert_raise Scratch::UnexpectedEOI do
          terp.run "var"
        end
      end
    end

    context "store method" do
      should "works" do
        assert !terp.respond_to?( :b )
        terp.run 'var b'
        terp.run '1 b store'
        assert_instance_of Scratch::Variable, terp.b.pop
        assert_respond_to terp, :b
      end

      should "raise StackTooSmall error when called with an empty stack" do
        terp.run 'var c'
        assert_equal [], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "store"
        end
      end

      should "raise StackTooSmall error when called with stack size of 1" do
        terp.run 'var d'
        assert_equal [], terp.stack
        assert_raise Scratch::StackTooSmall do
          terp.run "d store"
        end
      end
    end

    context "fetch method" do
      should "works" do
        assert !terp.respond_to?( :e )
        terp.run 'var e'
        terp.run '1 e store'
        terp.run 'e fetch'
        assert_equal [1], terp.stack
      end

      should "raise StackTooSmall error when called with an empty stack" do
        terp.run 'var f'
        terp.run '1 f store'
        assert_equal [], terp.stack
        assert_respond_to terp, :f
        assert_raise Scratch::StackTooSmall do
          terp.run "fetch"
        end
      end
    end
  end
end
