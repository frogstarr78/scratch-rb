module Scratch
  module CompilingWords
    define_method :def do
      func_name = lexer.next_word
      raise UnexpectedEOI.new if func_name.nil?

      self.latest = func_name
      self.stack.start_compiling!
    end

    def end
      func = make_word(self.stack.stack)
      define_variable latest, &func
      self.stack.stop_compiling!
      self.latest = nil
    end
  end
end
