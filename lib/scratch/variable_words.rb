module Scratch
  module VariableWords
    def var
      var_name = lexer.next_word
      raise UnexpectedEOI.new if var_name.nil?

      @var = ::Scratch::Variable.new( 0 )
      define_variable(var_name) { self << @var }
    end

    def store
      error_if_stack_isnt! 2
      @var = stack.pop
      @var.value = stack.pop
    end

    def fetch
      error_if_stack_isnt! 1
      @var = stack.pop
      self << @var.value
    end
  end
end
