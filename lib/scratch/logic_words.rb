module Scratch
  module LogicWords
    def true
      self << true
    end

    def false
      self << false
    end

    def or
      error_if_stack_isnt! 2

      left_term, right_term = stack.pop 2
      self << ( left_term || right_term )
    end

    def and
      error_if_stack_isnt! 2

      left_term, right_term = stack.pop 2
      self << ( left_term && right_term )
    end

    def not
      error_if_stack_isnt! 1

      self << !stack.pop
    end
  end
end
