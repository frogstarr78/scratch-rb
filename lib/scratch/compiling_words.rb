module Scratch
  module CompilingWords
    define_method :def do
      func_name = lexer.next_word
      raise UnexpectedEOI.new if func_name.nil?

      self.latest = func_name
      self.stack.start_compiling!
    end

    def end
      code = stack.dup
      stack = []
      define_variable latest, &make_word(code)
      self.stack.stop_compiling!
      self.latest = nil
    end
  end
end
