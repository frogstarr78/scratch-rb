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
      self.replace_n_types( Boolean ) {|item| !item }
    end
  end
end
