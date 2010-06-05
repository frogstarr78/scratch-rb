require 'helper'

class TestCompilingWords < TestHelper
  context 'Scratch::CompilingWords' do
    %w(def end).each do |method|
      should "define '#{method}'" do
        fail
        assert Scratch::CompilingWords.instance_methods(false).include?( 'method' )
      end
    end
  end

  context 'method' do
    should "work" do
      fail
    end
  end
end
