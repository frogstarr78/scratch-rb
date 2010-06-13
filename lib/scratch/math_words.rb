module Scratch
  module MathWords
    def math_op op
      self.stack.get_n_stack_items 2 do |_2os, tos|
        self.stack << _2os.send( op, tos )
      end
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

    define_method "√" do
      self.stack.get_n_stack_items do |num|
        self.stack << ( num ** 0.5 )
      end
    end
  end
end
