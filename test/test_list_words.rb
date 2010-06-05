require 'helper'

class TestListWords < TestHelper
  context 'Scratch::ListWords' do
    %w([ length item).each do |method|
      should "define '#{method}'" do
        fail
        assert Scratch::ListWords.instance_methods(false).include?( method )
      end
    end
  end

  context '" method' do
    should "work" do
      fail
    end
  end
end
