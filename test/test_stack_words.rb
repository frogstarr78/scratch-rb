require 'helper'

class TestStackWords < TestHelper

  context 'Scratch::StackWords' do
    %w(dup drop swap over rot).each do |meth|
      should "define #{meth}"do
        assert Scratch::StackWords.instance_methods(false).include?( meth )
      end
    end
  end

  context "dup method" do
    should "work"
  end

  context "drop method" do
    should "work"
  end

  context "swap method" do
    should "work"
  end

  context "over method" do
    should "work"
  end

  context "rot method" do
    should "work"
  end
end
