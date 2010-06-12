module Scratch
  module ComparisonWords
    def comparison_op op
      self.stack.get_n_stack_items 2 do |left_term, right_term|
        self.stack << left_term.send( op, right_term )
      end
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
