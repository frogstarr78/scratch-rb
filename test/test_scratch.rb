require 'helper'

class TestScratch < TestHelper
  context "stack" do
    should "add literals to stack" do
      terp.run '1 2 3'
      assert_equal [1, 2, 3], terp.stack
    end
  end

  context "Scratch::Scratch" do
    should "include modules" do
      assert Scratch::Scratch.include?(Scratch::PrintingWords)
      assert Scratch::Scratch.include?(Scratch::MathWords)
      assert Scratch::Scratch.include?(Scratch::StackWords)
      assert Scratch::Scratch.include?(Scratch::VariableWords)
      assert Scratch::Scratch.include?(Scratch::ConstantWords)
      assert Scratch::Scratch.include?(Scratch::StringWords)
      assert Scratch::Scratch.include?(Scratch::CommentWords)
      assert Scratch::Scratch.include?(Scratch::CompilingWords)
      assert Scratch::Scratch.include?(Scratch::ListWords)
      assert Scratch::Scratch.include?(Scratch::LogicWords)
      assert Scratch::Scratch.include?(Scratch::ComparisonWords)
      assert Scratch::Scratch.include?(Scratch::ControlWords)
    end
  end

  context "import module" do
    should "be defined" do
      assert_respond_to Scratch::Scratch, :<
    end
  end
end
