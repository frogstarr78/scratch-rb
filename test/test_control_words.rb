require 'helper'

class TestControlWords < TestHelper
  context 'Scratch::ControlWords' do
    %w(run ttimes is_true? is_false? if_else? continue? break? loop).each do |method|
      should 'define :"' do
        fail
        assert Scratch::ControlWords.instance_methods(false).include?( '"' )
      end
    end
  end

  context '" method' do
    should "work" do
      fail
    end
  end
end
