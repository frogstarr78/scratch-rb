# encoding: utf-8

require 'generator' 
require 'core_ext/nil'
require 'core_ext/string'
require 'scratch/variable'

module Scratch
  class ScratchLexer
    require 'stringio' 

    attr_accessor :words, :generator
    def initialize txt
      @words = ::StringIO.new txt
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
  end

  class StackTooSmall < Exception
    def initialize items, expected
      super( "Not enough items on stack:
      Expected: #{expected.inspect} items but stack is #{items.inspect}"
           )
    end
  end

  class UnexpectedEOI < Exception
    def message
      "Unexpected end of input"
    end
  end

  class ConstantReDefine < Exception
    def initialize constant
      @constant = constant
    end

    def message
      "Unable to redefine constant #{@constant}"
    end
  end

  class MissingListExpectation < Exception
    def initialize received
      super "List expected, received instead '#{received.class}'"
    end
  end

  module PrintingWords
    def print
      error_if_stack_isnt! 1
      Kernel.print stack.pop
    end

    def puts
      error_if_stack_isnt! 1
      Kernel.puts stack.pop
    end

    def pstack
      Kernel.puts stack
    end
  end

  module MathWords
    def math_op op
      error_if_stack_isnt! 2
      tstack2, tstack = stack.pop 2
      stack << tstack2.send( op, tstack )
    end
    private :math_op

    def +
      math_op "+"
    end

    def -
      math_op "-"
    end

    def *
      math_op "*"
    end

    def /
      math_op "/"
    end

    def rt
      error_if_stack_isnt! 1
      stack << stack.pop ** 0.5
    end
  end

  module StackWords
    def dup 
      error_if_stack_isnt! 1
      stack << stack.last
    end

    def drop
      error_if_stack_isnt! 1
      stack.pop
    end

    def swap
      error_if_stack_isnt! 2
      _2os, tos = stack.pop 2
      stack << tos << _2os
    end

    def over
      error_if_stack_isnt! 2
      stack << stack[-2]
    end

    def rot
      error_if_stack_isnt! 3
      _3os, _2os, tos = stack.pop 3
      stack << _2os << tos << _3os
    end
  end

  module VariableWords
    def var
      var_name = lexer.next_word
      raise UnexpectedEOI.new if var_name.nil?

      @var = ::Scratch::Variable.new( 0 )
      define_variable(var_name) { stack << @var }
    end

    def store
      error_if_stack_isnt! 2
      @var = stack.pop
      @var.value = stack.pop
    end

    def fetch
      error_if_stack_isnt! 1
      @var = stack.pop
      stack << @var.value
    end
  end

  module ConstantWords
    def const
      error_if_stack_isnt! 1

      const_name = lexer.next_word
      raise UnexpectedEOI.new if const_name.nil?

      if respond_to? const_name.to_sym
        raise ConstantReDefine.new const_name
      else
        define_variable(const_name) { stack.pop }
      end
    end
  end

  module StringWords
    define_method :'"' do
      stack << lexer.next_chars_to( '"' )
    end
  end

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

  module CompilingWords
    define_method :def do
      func_name = lexer.next_word
      raise UnexpectedEOI.new if func_name.nil?

      self.latest = func_name
      start_compiling
    end

    def end
      code = stack.dup
      stack = []
      define_variable latest, &make_word(code)
      stop_compiling
      self.latest = nil
    end
  end

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
      stack << stack.pop.size
    end

    def item
      error_if_stack_isnt! 2

      list, index = stack.pop 2

      stack << list[index]
    end
  end

  module LogicWords
    def true
      stack << true
    end

    def false
      stack << false
    end

    def or
      error_if_stack_isnt! 2

      left_term, right_term = stack.pop 2
      stack << ( left_term || right_term )
    end

    def and
      error_if_stack_isnt! 2

      left_term, right_term = stack.pop 2
      stack << ( left_term && right_term )
    end

    def not
      error_if_stack_isnt! 1

      stack << !stack.pop
    end
  end

  module ComparisonWords
    def comparison_op op
      error_if_stack_isnt! 2

      left_term, right_term = stack.pop 2
      stack << left_term.send( op, right_term )
    end
    private :comparison_op

    def <
      comparison_op :<
    end

    def <=
      comparison_op :<=
    end

    def ==
      comparison_op :==
    end

    def >=
      comparison_op :>=
    end

    def >
      comparison_op :>
    end
  end

  module ControlWords
    def exec
      error_if_stack_isnt! 1
      code_list = stack.pop
      raise MissingListExpectation.new(code_list) unless code_list.is_a? Array

      interpret make_word( code_list )
    end

    def times
      error_if_stack_isnt! 2
      code_list, num_times = stack.pop 2
      raise MissingListExpectation.new(code_list) unless code_list.is_a? Array

      word = make_word code_list
      num_times.times do 
        word.call
      end
    end

    def is_true?
      error_if_stack_isnt! 2
      cond, code_list = stack.pop 2

      raise MissingListExpectation.new(code_list) unless code_list.is_a? Array
      if cond
        interpret make_word( code_list )
      end
    end

    def is_false?
      error_if_stack_isnt! 2
      cond, code_list = stack.pop 2

      raise MissingListExpectation.new(code_list) unless code_list.is_a? Array
      unless cond
        interpret make_word( code_list )
      end
    end

    def if_else?
      error_if_stack_isnt! 3
      cond, true_code, false_code = stack.pop 3

      raise MissingListExpectation.new(true_code) unless true_code.is_a? Array
      raise MissingListExpectation.new(false_code) unless false_code.is_a? Array

      if cond
        interpret make_word( true_code )
      else
        interpret make_word( false_code )
      end
    end

#    def continue?
#      error_if_stack_isnt! 1
##      next if stack.pop
#    end

    def break?
      error_if_stack_isnt! 1
      self.break_state = true if stack.pop
    end

    def loop
      error_if_stack_isnt! 1
      code_list = stack.pop
      raise MissingListExpectation.new(code_list) unless code_list.is_a? Array

      word = make_word code_list
      old_break_state = break_state
      break_state = false
      until self.break_state
        word.call
      end
      break_state = old_break_state
    end
  end

  class Scratch
    attr_accessor :stack, :buffer, :data_stack, :lexer, :latest, :break_state
    private :stack=, :buffer=, :data_stack=, :lexer=, :latest=, :break_state=
    IMMEDIATES = %w(var const " /* def end [ true false)
    @@dictionary = []

    def initialize
      @buffer      = []
      @data_stack  = []
      @stack       = @data_stack
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

    def start_compiling
      self.stack = self.buffer
    end
    private :start_compiling

    def stop_compiling
      self.stack = self.data_stack
    end
    private :stop_compiling

    def compiling?
      self.stack.object_id == self.buffer.object_id
    end

    def run text
      self.lexer = ScratchLexer.new(text)

      word = lexer.next_word
      until word.nil?
        token = self.compile word
        if IMMEDIATES.include? word
          self.interpret token
        elsif self.compiling?
          self.stack << token
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
        self.stack << word
      end
    end

    def error_if_stack_isnt! check
      raise StackTooSmall.new stack, check if self.stack.size < check 
    end
    private :error_if_stack_isnt!

    class << self
      def [] mod
        @@dictionary.select {|modul| modul == mod }
      end
      private :[]

      def < mod
        include mod
        @@dictionary << mod
      end
#      private :<
    end

    self < PrintingWords
    self < MathWords
    self < StackWords
    self < VariableWords
    self < ConstantWords
    self < StringWords
    self < CommentWords
    self < CompilingWords
    self < ListWords
    self < LogicWords
    self < ComparisonWords
    self < ControlWords
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
