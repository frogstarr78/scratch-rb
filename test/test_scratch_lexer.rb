require 'helper'

class TestScratchLexer < TestHelper
  def lexer
    @lexer ||= Scratch::Lexer.new
  end

  context "Scratch::Lexer" do
    %w(words next_word next_chars_to parse).each do |meth|
      should "respond_to? #{meth}" do
        assert_respond_to lexer, meth
      end
    end

    context "\b#next_word" do
      should "understands one word" do
        lexer.parse 'abc'
        assert_instance_of StringIO, lexer.words
        word = lexer.next_word
        assert_equal "abc", word
      end

      should "gets nothing with an empty string" do
        lexer.parse ''
        assert_instance_of StringIO, lexer.words
        word = lexer.next_word
        assert_nil word
      end

      should "separate words by single space" do
        lexer.parse 'a bc'
        assert_instance_of StringIO, lexer.words
        word = lexer.next_word
        assert_equal 'a', word
        word = lexer.next_word
        assert_equal 'bc', word
        word = lexer.next_word
        assert_nil word
      end

      should "separate words by multiple space" do
        lexer.parse 'a                bc'
        assert_instance_of StringIO, lexer.words
        word = lexer.next_word
        assert_equal 'a', word
        word = lexer.next_word
        assert_equal 'bc', word
        word = lexer.next_word
        assert_nil word
      end

      should "separate words by tabs" do
        lexer.parse "a\tbc"
        assert_instance_of StringIO, lexer.words
        word = lexer.next_word
        assert_equal 'a', word
        word = lexer.next_word
        assert_equal 'bc', word
        word = lexer.next_word
        assert_nil word
      end

      should "separate words by newlines" do
        lexer.parse "ab\nbce"
        assert_instance_of StringIO, lexer.words
        word = lexer.next_word
        assert_equal 'ab', word
        word = lexer.next_word
        assert_equal 'bce', word
        word = lexer.next_word
        assert_nil word
      end

      should "separates words by multiple different whitespace characters" do
        lexer.parse "ab     \t      \n bce"
        assert_instance_of StringIO, lexer.words
        word = lexer.next_word
        assert_equal 'ab', word
        word = lexer.next_word
        assert_equal 'bce', word
        word = lexer.next_word
        assert_nil word
      end
    end

    context "\b#next_chars_to" do
      should "slurp characters up to the next occurance of the supplied char with nothing between" do
        lexer.parse '"'
        word = lexer.next_chars_to '"'
        assert_nil word
      end

      should "slurp characters up to the next occurance of the supplied char with stuff inside" do
        lexer.parse 'some stuff"'
        word = lexer.next_chars_to '"'
        assert_equal "some stuff", word
      end
    end

    context "#parse" do
      should "set @words to stringio intance" do
        assert_nil lexer.words
        lexer.parse "1 2 3"
        assert_instance_of StringIO, lexer.words
        assert_equal "1 2 3", lexer.words.read
      end
    end
  end
end
