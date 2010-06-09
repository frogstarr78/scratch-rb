module Scratch
  module CommentWords
    define_method :"/*" do
      word = lexer.next_word
      raise UnexpectedEOI.new if word.nil?

      until word[-2, 2] == "*/"
        raise UnexpectedEOI.new if word.nil?
        word = lexer.next_word
      end
    end
  end
end
