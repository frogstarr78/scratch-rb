require 'helper'

class TestCompilingWords < TestHelper
  context 'Scratch::CompilingWords' do
    %w(def end).each do |method|
      should "define '#{method}'" do
        assert Scratch::CompilingWords.instance_methods(false).include?( method )
      end
    end

    context 'def method' do
      should "work" 
      should "raise UnexpectedEOI error when there isn't a function name"
    end

    context 'end method' do
      should "work" 
    end
  end
end
