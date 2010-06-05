require 'helper'

class TestControlWords < TestHelper
  context 'Scratch::ControlWords' do
    %w(run times is_true? is_false? if_else? continue? break? loop).each do |method|
      should "define :'#{method}'" do
        assert Scratch::ControlWords.instance_methods(false).include?( '"' )
      end
    end
  end

  context 'run method' do
    should "work"
  end

  context 'times method' do
    should "work"
  end

  context 'is_true? method' do
    should "work"
  end

  context 'is_false? method' do
    should "work"
  end

  context 'if_else? method' do
    should "work"
  end

  context 'continue? method' do
    should "work"
  end

  context 'break? method' do
    should "work"
  end

  context 'loop method' do
    should "work"
  end
end
