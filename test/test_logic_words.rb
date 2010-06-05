require 'helper'

class TestLogicWords < TestHelper
  context 'Scratch::LogicWords' do
    %w(true false and or not).each do |method|
      should "define '#{method}'" do
        fail
        assert Scratch::LogicWords.instance_methods(false).include?( method )
      end
    end
  end

  context '" method' do
    should "work" do
      fail
    end
  end
end
