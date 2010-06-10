module Scratch
  module LogicWords
    def true
      self.stack << true
    end

    def false
      self.stack << false
    end

    def or
      error_if_stack_isnt! 2

      left_term, right_term = stack.pop 2
      self.stack << ( left_term || right_term )
    end

    def and
      error_if_stack_isnt! 2

      left_term, right_term = stack.pop 2
      self.stack << ( left_term && right_term )
    end

    def not
      error_if_stack_isnt! 1

      self.stack << !stack.pop
    end
  end
end
