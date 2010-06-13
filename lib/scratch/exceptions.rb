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

  class InvalidType < Exception
    def initialize expected_class, received_class
      super "Expecting a(n) '#{expected_class}' class, but received a(n) '#{received_class}' class instead."
    end
  end
end
