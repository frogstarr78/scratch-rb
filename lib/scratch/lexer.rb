module Scratch
  class ScratchLexer
    require 'stringio' 

    attr_accessor :words, :generator
    def initialize
#      @words = ::StringIO.new txt
    end

    def next_word
      word = nil
      char = @words.read( 1 )
      while char
        if char.is_whitespace?
          if word.blank?
            next
          else
            return word
          end
        else
          word ||= ''
          word << char
        end
        char = @words.read( 1 )
      end
      word
    end

    def next_chars_to up_tochar
      word = nil
      char = @words.read( 1 )
      while char
        if char == up_tochar
          return word
        else
          word ||= ''
          word << char
        end
        char = @words.read( 1 )
      end
      word
    end

    def parse txt
      @words = ::StringIO.new txt
    end
  end
end
