module Scratch
  module ListWords
    define_method :"[" do
      list = []
      old_stack = self.stack
      self.stack = list

      word = lexer.next_word
      while word
        raise UnexpectedEOI.new if word.nil?
        break if word == ']'

        token = compile word
        if Scratch::IMMEDIATES.include? word
          interpret token
        else
          self.stack << token
        end
        word = lexer.next_word
      end
      raise UnexpectedEOI.new unless word == ']'

      list = self.stack
      self.stack = old_stack
      self.stack << list
    end

    define_method :"]" do
    end

    def length
      self.stack.get_n_stack_items do |code_list|
#        raise MissingListExpectation.new(code_list) unless code_list.is_a? Array
        self.stack << code_list.size
      end
    end

    def item
      self.stack.get_n_stack_items 2 do |code_list, index|
        raise MissingListExpectation.new(code_list) unless code_list.is_a? Array
        self.stack << code_list[index]
      end
    end
  end
end
