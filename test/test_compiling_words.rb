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
        assert_equal false, terp.compiling?
        terp.run 'def cube_root'
        assert_equal 'cube_root', terp.latest
        assert_equal true, terp.compiling? 
      end

      should "raise UnexpectedEOI error when there isn't a function name" do
        assert_raise Scratch::UnexpectedEOI do
          terp.run 'def'
        end
      end
    end

    context 'end method' do
      should "work" do
        assert_nil terp.latest
        assert_equal false, terp.compiling?
        assert !terp.respond_to?(:square)
        terp.run 'def square dup *'
        assert_equal 'square', terp.latest
        assert_equal true, terp.compiling? 
        terp.run 'end'
        assert_nil terp.latest
        assert_respond_to terp, :square
        assert_equal false, terp.compiling? 

        terp.run '2 square'
        assert_equal_stack [4], terp.stack
      end
    end
  end
end
