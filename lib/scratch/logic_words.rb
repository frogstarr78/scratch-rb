module Scratch
  module LogicWords
    def true
      self.stack << true
    end

    def false
      self.stack << false
    end

    def or
      send_ruby_op "||"
    end

    def and
      send_ruby_op "&&"
    end

    def not
      self.stack.replace_n_pop_items( 1, [Boolean] ) {|item| !item }
    end
  end
end
