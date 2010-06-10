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
      error_if_stack_isnt! 1
      self.stack << stack.pop.size
    end

    def item
      error_if_stack_isnt! 2

      list, index = stack.pop 2

      self.stack << list[index]
    end
  end
end
