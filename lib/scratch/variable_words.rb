module Scratch
  module VariableWords
    def var
      var_name = lexer.next_word
      raise UnexpectedEOI.new if var_name.nil?

      @var = ::Scratch::Variable.new( 0 )
      define_variable(var_name) { self.stack << @var }
    end

    def store
      self.get_n_types Object, Object do |value, var|
        @var = var
        @var.value = value
      end
    end

    def fetch
      self.get_n_types Object do |var|
        @var = var
        self.stack << @var.value
      end
    end
  end
end
