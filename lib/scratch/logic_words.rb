module Scratch
  module LogicWords
    def true
      self.stack << true
    end

    def false
      self.stack << false
    end

    def or
      self.stack.get_n_stack_items 2 do |left_term, right_term|
        self.stack << ( left_term || right_term )
      end
    end

    def and
      self.stack.get_n_stack_items 2 do |left_term, right_term|
        self.stack << ( left_term && right_term )
      end
    end

    def not
      self.stack.get_n_stack_items do |is|
        self.stack << !is
      end
    end
  end
end
