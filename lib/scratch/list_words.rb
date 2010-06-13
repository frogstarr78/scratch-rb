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

      list = self.stack.stack.dup
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
      self.stack.replace_n_pop_items do |code_list|
        raise MissingListExpectation.new(code_list) unless code_list.is_a? Array
        code_list.size
      end
    end

    def item
      self.stack.replace_n_pop_items 2 do |code_list, index|
        raise MissingListExpectation.new(code_list) unless code_list.is_a? Array
        code_list[index]
      end
    end
  end
end
