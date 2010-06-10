module Scratch
  module StringWords
    define_method :'"' do
      self.stack << lexer.next_chars_to( '"' )
    end
  end
end
