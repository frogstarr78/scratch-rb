module Scratch
  module MathWords
    def math_op op
      error_if_stack_isnt! 2
      tstack2, tstack = stack.pop 2
      self << tstack2.send( op, tstack )
    end
    private :math_op

    def +
      math_op "+"
    end

    def -
      math_op "-"
    end

    def *
      math_op "*"
    end

    def /
      math_op "/"
    end

    def rt
      error_if_stack_isnt! 1
      self << stack.pop ** 0.5
    end
  end
end
