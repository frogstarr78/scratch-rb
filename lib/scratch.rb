# encoding: utf-8

require 'generator' 
require 'core_ext/nil'
require 'core_ext/string'
require 'scratch/variable'
require 'scratch/lexer'
require 'scratch/exceptions'
require 'scratch/printing_words'
require 'scratch/math_words'
require 'scratch/stack_words'
require 'scratch/variable_words'
require 'scratch/constant_words'
require 'scratch/string_words'
require 'scratch/comment_words'
require 'scratch/compiling_words'
require 'scratch/list_words'
require 'scratch/logic_words'
require 'scratch/comparison_words'
require 'scratch/control_words'
require 'scratch/stack'

module Scratch
  class Scratch
#    attr_accessor :stack, :buffer, :data_stack, :lexer, :latest, :break_state
#    private :stack=, :buffer=, :data_stack=, :lexer=, :latest=, :break_state=
    attr_accessor :lexer, :latest, :break_state
    attr_reader :stack
    # TODO: See about making Scratch::Stack do all the stack temporary re-assignments.
    attr_writer :stack
    private  :lexer=, :latest=, :break_state=
    IMMEDIATES = %w(var const " /* def end [ true false)

    def initialize
#      @buffer      = []
#      @data_stack  = []
      @stack       = Stack.new
#      @stack       = @data_stack
      @lexer       = nil
      @break_state = false
    end

    def define_variable term, &block
      self.class.send :define_method, term, &block
    end

    def make_word code
      lambda do
        code.each do |word|
          interpret word
        end
      end
    end
    private :make_word

    def run text
      self.lexer = ScratchLexer.new(text)

      word = lexer.next_word
      until word.nil?
        token = self.compile word
        if IMMEDIATES.include? word
          self.interpret token
        elsif self.stack.compiling?
          self << token
        else
          self.interpret token
        end
        word = lexer.next_word
      end
    end

    def compile word
      if self.respond_to? word
        return self.method(word.to_sym)
      elsif word.is_numeric?
        return word.to_i
      else
        raise "Unknown word '#{word}'."
      end
    end

    def interpret word
      if ( word.is_a? Method and respond_to? word.name ) or word.is_a? Proc
        word.call
      else
        self << word
      end
    end

    def error_if_stack_isnt! check
      raise StackTooSmall.new stack, check if self.stack.size < check 
    end
    private :error_if_stack_isnt!

    def << thing
      self.stack << thing
    end
#    private :<<

    include PrintingWords
    include MathWords
    include StackWords
    include VariableWords
    include ConstantWords
    include StringWords
    include CommentWords
    include CompilingWords
    include ListWords
    include LogicWords
    include ComparisonWords
    include ControlWords
  end
end

if $0 == __FILE__
  $LOAD_PATH << 'lib'
  include Scratch
  terp = Scratch::Scratch.new

#  terp.run "1"
#  terp.run "drop"
  terp.run 'puts'
  terp.run "1 2 3 45 678"
#  terp.run "pstack"
#  terp.run '" ----------------------" print'
#  terp.run '" - dup" print'
#  terp.run "dup pstack"
#  terp.run '" ----------------------" print'
#  terp.run '" - drop" print'
#  terp.run "drop pstack"
#  terp.run '" ----------------------" print'
#  terp.run '" - swap" print'
#  terp.run "swap pstack"
#  terp.run '" ----------------------" print'
#  terp.run '" - over" print'
#  terp.run "over pstack"
#  terp.run '" ----------------------" print'
#  terp.run '" - rot" print'
#  terp.run "rot pstack"
#  terp.run '" ----------------------" print'
#  terp.run "10 pstack"
#  terp.run "1 2 3 print print print"
#  terp.run "2 2 + print"
#  terp.run "2 2 - print"
#  terp.run "4 2 / print"
#  terp.run "3 3 * 4 4 * + √ print"
#  terp.run "var a"
#  terp.run "var b"
#  terp.run "12 b store"
#  terp.run "10 a store"
#  terp.run "a fetch print"
#  terp.run "b fetch print"
#  terp.run "12 a store"
#  terp.run "a fetch print"
#  terp.run "b fetch print"
#  terp.run "5 const Q"
#  terp.run "Q print"
#  terp.run '" Hello World!" print'
#  terp.run '/* abc */ " Hello World!" print'
#  terp.run '/* abc */ Q print'
#  terp.run 'def HYPOT  dup * swap dup * + √  end'
#  terp.run '3 4 hypot .'
#  terp.run '[ 1 2 3 ] .'
#  terp.run '[ 1 2 3 [ 4 5 6 ] 7 ] .'
#  terp.run '[ 1 2 3 [ 4 5 6 ] 7 ] 3 item .'
#  terp.run '[ 1 2 3 ] 1 item .'
#  terp.run '[ 1 " hello" print ] .'
#  terp.run '[ 1 2 3 ] run .'
#  terp.run '[ 1 ! ] 5 times'
#  terp.run 'false [ 1 ! ] is_true?'
#  terp.run 'true [ 3 ! ] is_true?'
#  terp.run 'false [ 2 ! ] is_false?'
#  terp.run 'true [ 4 ! ] is_false?'
#  terp.run 'false [ 5 ! ] is_false?'
#  terp.run 'false [ 6 ! ] is_false?'
#  terp.run 'true [ 7 ! ] is_false?'
#  terp.run 'true [ 7 ! ] [ 8 ! ] if_else?'
#  terp.run 'false [ 7 ! ] [ 8 ! ] if_else?'
#  terp.run 'true false or [ 9 . ] is_true?'
#  terp.run 'true false and [ 10 . ] is_true?'
#  terp.run 'false not [ 11 . ] is_true?'
#  terp.run '1 [ dup 3 > break? dup print 1 + ] loop'
  #puts terp.dictionary.inspect
end
