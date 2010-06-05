require 'helper'

class TestComparisonWords < TestHelper
  context 'Scratch::ComparisonWords' do
    %w(< <= == >= >).each do |method|
      should "define '#{method}'" do
        fail
        assert Scratch::ComparisonWords.instance_methods(false).include?( method )
      end
    end
  end

  context '" method' do
    should "work" do
      fail
    end
  end
end
