module Scratch
  class StackTooSmall < Exception
    def initialize items, expected
      super( "Not enough items on stack:
      Expected: #{expected.inspect} items but stack is #{items.inspect}"
           )
    end
  end

  class UnexpectedEOI < Exception
    def message
      "Unexpected end of input"
    end
  end

  class ConstantReDefine < Exception
    def initialize constant
      @constant = constant
    end

    def message
      "Unable to redefine constant #{@constant}"
    end
  end

  class MissingListExpectation < Exception
    def initialize received
      super "List expected, received instead '#{received.class}'"
    end
  end
end
