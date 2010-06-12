module Scratch
  module VariableWords
    def var
      var_name = lexer.next_word
      raise UnexpectedEOI.new if var_name.nil?

      @var = ::Scratch::Variable.new( 0 )
      define_variable(var_name) { self.stack << @var }
    end

    def store
      self.stack.get_n_stack_items 2 do |value, var|
        @var = var
        @var.value = value
      end
    end

    def fetch
      self.stack.get_n_stack_items do |var|
        @var = var
        self.stack << @var.value
      end
    end
  end
end
