require 'helper'

class MockKernel
  class << self
    def puts *arguments
      @puts = ['puts'] | arguments << "\n"
    end

    def print *arguments
      @print = ['print'] | arguments
    end

    def puts?
      @puts
    end

    def print?
      @print
    end
  end
end

class TestScratch < Test::Unit::TestCase
  def terp 
    @terp ||= Scratch::Scratch.new
  end

  context "stack" do
    should "add literals to stack" do
      terp.run '1 2 3'
      assert_equal [1, 2, 3], terp.stack
    end
  end

  context 'Scratch::PrintingWords' do
    should "print element of from stack" do
      terp.add_words( Scratch::PrintingWords )

      terp.dictionary["PRINT"].expects(:call).with(terp)
      terp.run '3'
      assert_equal [3], terp.stack
      terp.run "print"
    end

    should "raise StackTooSmall error when print called with an empty stack" do
      terp.add_words( Scratch::PrintingWords )

      assert_equal [], terp.stack
      assert_raise Scratch::Scratch::StackTooSmall do
#        terp.dictionary["PRINT"].call terp 
        terp.run "print"
      end
    end
  end
end
