require 'helper'

class TestScratch < Test::Unit::TestCase
  context "Scratch::Variable" do
    setup do
      @var = Scratch::Variable.new 1
    end

    should "have a value, a value= methods" do
      assert_respond_to @var, :value
      assert_respond_to @var, :value=
    end

    should "set value on init" do
      assert_equal 1, @var.value
    end
  end
end
