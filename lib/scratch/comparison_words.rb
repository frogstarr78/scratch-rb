module Scratch
  module ComparisonWords
    def comparison_op op
      error_if_stack_isnt! 2

      left_term, right_term = stack.pop 2
      self << left_term.send( op, right_term )
    end
    private :comparison_op

    def <
      comparison_op :<
    end

    def <=
      comparison_op :<=
    end

    def ==
      comparison_op :==
    end

    def >=
      comparison_op :>=
    end

    def >
      comparison_op :>
    end
  end

end
