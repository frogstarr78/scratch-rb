require 'helper'

class TestStringWords < TestHelper
  context 'Scratch::StringWords' do
    should 'define :"' do
      assert Scratch::StringWords.instance_methods(false).include?( '"' )
    end

    context '" method' do
      should "work" do
        terp.run '" hello world"'
        assert_equal_stack ["hello world"], terp.stack
      end
    end
  end
end
