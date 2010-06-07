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

      while char = @words.read(1)
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
      end
      word
    end

    def next_chars_to up_tochar
      word = nil
      while char = @words.read( 1 )
        if char == up_tochar
          return word
        else
          word ||= ''
          word << char
        end
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
      error_if_stack_isnt_sufficient! :empty?
      Kernel.print stack.pop
    end

    def puts
      error_if_stack_isnt_sufficient! :empty?
      Kernel.puts stack.pop
    end

    def pstack
      Kernel.puts stack
    end
  end

  module MathWords
    def math_op op
      error_if_stack_isnt_sufficient! :<, 2
      tstack = stack.pop
      tstack2 = stack.pop
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

    def RT
      error_if_stack_isnt_sufficient! :empty?
      stack << stack.pop ** 0.5
    end
  end

  module StackWords
    def dup 
      error_if_stack_isnt_sufficient! :<, 1
      tos = stack.pop
      stack << tos << tos
    end

    def drop
      error_if_stack_isnt_sufficient! :<, 1
      stack.pop
    end

    def swap
      error_if_stack_isnt_sufficient! :<, 2
      tos = stack.pop
      _2os = stack.pop
      stack << tos
      stack << _2os
    end

    def over
      error_if_stack_isnt_sufficient! :<, 2
      tos = stack.pop
      _2os = stack.pop
      stack << _2os
      stack << tos
      stack << _2os
    end

    def rot
      error_if_stack_isnt_sufficient! :<, 3
      tos = stack.pop
      _2os = stack.pop
      _3os = stack.pop
      stack << _2os
      stack << tos
      stack << _3os
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
      error_if_stack_isnt_sufficient! :<, 2
      @var = stack.pop
      @var.value = stack.pop
    end

    def fetch
      error_if_stack_isnt_sufficient! :<, 1
      @var = stack.pop
      stack << @var.value
    end
  end

  module ConstantWords
    def const
      error_if_stack_isnt_sufficient! :<, 1

      const_name = lexer.next_word
      raise UnexpectedEOI.new if const_name.nil?

      const_value = stack.pop
      if respond_to? const_name.to_sym
        raise ConstantReDefine.new const_name
      else
        define_variable(const_name) { const_value }
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

      while word = lexer.next_word
        raise UnexpectedEOI.new if word.nil?
        break if word == ']'

        token = compile word
        if Scratch::IMMEDIATES.include? word
          interpret token
        else
          self.stack << token
        end
      end
      raise UnexpectedEOI.new unless word == ']'

      list = self.stack
      self.stack = old_stack
      self.stack << list
    end

    define_method :"]" do
    end

    def length
      error_if_stack_isnt_sufficient! :<, 1
      stack << stack.pop.size
    end

    def item
      error_if_stack_isnt_sufficient! :<, 2

      index = stack.pop
      list = stack.pop

      stack.push list[index]
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
      error_if_stack_isnt_sufficient! :<, 2
      term2 = stack.pop
      term1 = stack.pop

      stack.push term1 || term2
    end

    def and
      error_if_stack_isnt_sufficient! :<, 2
      term2 = stack.pop
      term1 = stack.pop

      stack.push term1 && term2
    end

    def not
      error_if_stack_isnt_sufficient! :<, 1

      stack.push !stack.pop
    end
  end

  module ComparisonWords
    def comparison_op op
      error_if_stack_isnt_sufficient! :<, 2

      term2 = stack.pop
      term1 = stack.pop

      stack.push term1.send op, term2
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
    end
#    "RUN" => lambda do |terp|
#      terp.error_if_stack_isnt_sufficient! :<, 1
#      list = terp.stack.pop
#      raise Scratch::MissingListExpectation.new(list) unless list.is_a? Array
#
#      terp.interpret terp.make_word( list )
#    end,

    def times
    end
#    "TIMES" => lambda do |terp|
#      terp.error_if_stack_isnt_sufficient! :<, 2
#      num_times = terp.stack.pop
#      list = terp.stack.pop
#      raise Scratch::MissingListExpectation.new(list) unless list.is_a? Array
#
#      word = terp.make_word list
#      num_times.times do 
#        word.call terp
#      end
#    end,
#

    def is_true?
    end
#    "IS_TRUE?" => lambda do |terp|
#      terp.error_if_stack_isnt_sufficient! :<, 2
#      code = terp.stack.pop
#      cond = terp.stack.pop
#
#      raise Scratch::MissingListExpectation.new(code) unless code.is_a? Array
#      if cond
#        terp.interpret terp.make_word(code)
#      end
#    end, 
#

    def is_false?
    end
#    "IS_FALSE?" => lambda do |terp|
#      terp.error_if_stack_isnt_sufficient! :<, 2
#      list = terp.stack.pop
#      cond = terp.stack.pop
#
#      raise Scratch::MissingListExpectation.new(list) unless list.is_a? Array
#      unless cond
#        terp.interpret terp.make_word(list)
#      end
#    end, 

    def if_else?
    end
#    "IF_ELSE?" => lambda do |terp|
#      terp.error_if_stack_isnt_sufficient! :<, 3
#      false_code = terp.stack.pop
#      true_code = terp.stack.pop
#      cond = terp.stack.pop
#
#      raise Scratch::MissingListExpectation.new(true_code) unless true_code.is_a? Array
#      raise Scratch::MissingListExpectation.new(false_code) unless false_code.is_a? Array
#
#      if cond
#        terp.interpret terp.make_word(true_code)
#      else
#        terp.interpret terp.make_word(false_code)
#      end
#    end,

    def continue?
    end
#    "CONTINUE?" => lambda do |terp|
#      terp.error_if_stack_isnt_sufficient! :<, 1
#      cond = terp.stack.pop
#
#      next if cond
#    end,

    def break?
    end
#    "BREAK?" => lambda do |terp|
#      terp.error_if_stack_isnt_sufficient! :<, 1
#      cond = terp.stack.pop
#
#      if cond
#        terp.break_state = true
#      end
#    end,
#

    def loop
    end
#    "LOOP" => lambda do |terp|
#      terp.error_if_stack_isnt_sufficient! :<, 1
#      code = terp.stack.pop
#
#      raise Scratch::MissingListExpectation.new(code) unless code.is_a? Array
#
#      word = terp.make_word code
#      old_break_state = terp.break_state
#      terp.break_state = false
#      until terp.break_state
#        word.call terp
#      end
#      terp.break_state = old_break_state
#    end
  end

  class Scratch
    attr_accessor :stack, :buffer, :data_stack, :lexer, :latest, :break_state
    private :stack=, :buffer=, :data_stack=, :lexer=, :latest=, :break_state=
    IMMEDIATES = %w(var const " /* def end [ true false)
    @@dictionary = []

    def initialize
      @buffer     = []
      @data_stack = []
      @stack      = @data_stack
      @lexer      = nil
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

    def start_compiling
      self.stack = self.buffer
    end

    def stop_compiling
      self.stack = self.data_stack
    end

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
      if word.is_a? Method
        word.call
      else
        self.stack << word
      end
    end

    def error_if_stack_isnt_sufficient! check, arg = nil
      case check
      when :empty?
        raise StackTooSmall.new stack, '> 0' if self.stack.empty? 
      when :<
        raise StackTooSmall.new stack, arg if self.stack.size < arg 
      end
    end

    def self.[] mod
      @@dictionary.select {|modul| modul == mod }
    end

    def self.< mod
      include mod
      @@dictionary << mod
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
  include Scratch
  terp = Scratch::Scratch.new
  terp.add_words( StringWords )
  terp.add_words( CommentWords )
  terp.add_words( StackWords )
  terp.add_words( CompilingWords )
  terp.add_words( ListWords )
  terp.add_words( ControlWords )
  terp.add_words( ComparisonWords )
  terp.add_words( LogicWords )


#  terp.run "1"
#  terp.run "drop"
#  terp.run 'puts'
#  terp.run "1 2 3 45 678"
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
