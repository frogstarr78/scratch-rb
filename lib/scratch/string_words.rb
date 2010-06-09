module Scratch
  module StringWords
    define_method :'"' do
      self << lexer.next_chars_to( '"' )
    end
  end
end
