module Scratch
  module ListWords
    define_method :"[" do
      self.stack.start_compiling!

      word = lexer.next_word
      until word.nil?
        break if word == ']'

        interpret! word
        word = lexer.next_word
      end
      raise UnexpectedEOI.new unless word == ']'

      list = self.stack.dup
      self.stack.stop_compiling!
      self.stack << list
    end

    define_method :"]" do
      # place holder method so the interpreter doesn't error
      # parsing this character. We don't want to do anything
      # with the stack though, in case we'er dealing with nested
      # arrays.
    end

    def length
      self.replace_n_types Array do |code_list|
        code_list.size
      end
    end

    def item
      self.replace_n_types Array, Fixnum do |code_list, index|
        code_list[index]
      end
    end
  end
end
