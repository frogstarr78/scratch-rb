require 'generator' 
require 'delegate'
require 'rubygems'
require 'ruby-debug'

DEBUG=false
class Variable
  def initialize v = 0
    @value = v
  end

  def value
    @value
  end

  def value= v = 0
    @value = v
  end
end

class NilClass
  def is_whitespace?
    false
  end

  def blank?
    true
  end
end

class String
  def is_whitespace?
    return self == '' ||
      self == " "  ||
      self == "\t" ||
      self == "\r" || 
      self == "\n" ||
      self == "\v"
  end

  def blank?
    self == ''
  end

  def is_numeric?
    self =~ /\A\d+\Z/
  end
end

class ScratchLexer
  attr_accessor :words, :generator
  def initialize txt
    @words = StringIO.new txt
#    @words = txt.split ''
#    @generator = Generator.new @words
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

  def _next_word

    char = generator.next
    # init word
    return nil unless not char.empty? or generator.next?

    # ignore whitespace
    while char.is_whitespace?
      return nil unless generator.next?
      char = generator.next
    end

    word = ""

    until char.is_whitespace? #or !generator.next? # again
      word << char
      char = generator.next
    end

    word
  end
end

class Scratch
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

  class MissingListExpectation < Exception
    def initialize received
      super "List expected, received instead '#{received.class}'"
    end
  end

  attr_accessor :dictionary, :stack, :buffer, :data_stack, :lexer, :latest
  IMMEDIATES = %w(VAR CONST " /* DEF END [)

  def initialize
    @dictionary = {}
    @buffer     = []
    @data_stack = []
    @stack      = SimpleDelegator.new @data_stack
    @lexer      = nil
  end

  def add_words new_dict
    new_dict.each do |word, callback|
      dictionary.update word.upcase => callback
    end
  end

  def define_variable word, code
    dictionary.update word.upcase => code
  end

  def make_word code
    lambda do |terp|
      code.each do |word|
        terp.interpret word
      end
    end
  end

  def start_compiling
    self.stack.__setobj__ self.buffer
  end

  def stop_compiling
    self.stack.__setobj__ self.data_stack
  end

  def compiling?
    self.stack == self.buffer
  end

  def run text
    self.lexer = ScratchLexer.new(text)

    while word = lexer.next_word
      token = self.compile word
      if IMMEDIATES.include? word
        self.interpret token
      elsif self.compiling?
        self.stack << token
      else
        self.interpret token
      end
    end
  end

  def compile word
    word.upcase!
    if dictionary.has_key?( word )
      return dictionary[word]
    elsif word.is_numeric?
      return word.to_i
    else
      raise "Unknown word '#{word}'."
    end
  end

  def interpret word
    if word.is_a? Proc
      word.call self
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
end

PrintingWords = {
  "PRINT" => lambda do |terp|
    terp.error_if_stack_isnt_sufficient! :empty?
    print terp.stack.pop
  end,

  "PUTS" => lambda do |terp|
    terp.error_if_stack_isnt_sufficient! :empty?
    puts terp.stack.pop
  end,

  "PSTACK" => lambda do |terp|
    puts terp.stack
  end

}
PrintingWords["."] = PrintingWords["PRINT"]
PrintingWords["!"] = PrintingWords["PUTS"]

math_op = lambda do |terp, op|
  terp.error_if_stack_isnt_sufficient! :<, 2
  tstack = terp.stack.pop
  tstack2 = terp.stack.pop
  terp.stack << tstack2.send( op, tstack )
end

MathWords = {
  "+" => lambda do |terp|
    math_op.call(terp, "+")
  end,

  "-" => lambda do |terp|
    math_op.call(terp, "-")
  end,

  "*"  => lambda do |terp|
    math_op.call(terp, "*")
  end,

  "/" => lambda do |terp|
    math_op.call(terp, "/")
  end,

  "√"  => lambda do |terp|
    terp.error_if_stack_isnt_sufficient! :empty?
    tstack = terp.stack.pop
    terp.stack << tstack ** 0.5
  end,
}

VariableWords = {
  "VAR" => lambda do |terp|
    var_name = terp.lexer.next_word
    raise UnexpectedEOI.new if var_name.nil?

    @var = Variable.new( 0 )
    terp.define_variable var_name, lambda{|terp| terp.stack << @var }
  end,

  "STORE" => lambda do |terp|
    terp.error_if_stack_isnt_sufficient! :<, 2
    @var = terp.stack.pop
    new_val = terp.stack.pop
    @var.value = new_val
  end,

  "FETCH" => lambda do |terp|
    terp.error_if_stack_isnt_sufficient! :<, 1
    @var = terp.stack.pop
    terp.stack << @var.value
  end

}

ConstantWords = {
  "CONST" => lambda do |terp|
    terp.error_if_stack_isnt_sufficient! :<, 1

    const_name = terp.lexer.next_word
    raise UnexpectedEOI.new if const_name.nil?

    const_value = terp.stack.pop
    terp.define_variable const_name, lambda {|terp| terp.stack <<  const_value }
  end
}

StringWords = {
  '"' => lambda do |terp|
    word = terp.lexer.next_chars_to('"')
    terp.stack << word
  end
}

CommentWords = {
  "/*" => lambda do |terp|
    word = terp.lexer.next_word
    raise UnexpectedEOI.new if word.nil?

    until word[-2, 2] == "*/"
      raise UnexpectedEOI.new if word.nil?
      word = terp.lexer.next_word
    end
  end
}

CompilingWords = {
  "DEF" => lambda do |terp|
    func_name = terp.lexer.next_word
    raise UnexpectedEOI.new if func_name.nil?

    terp.latest = func_name
    terp.start_compiling
  end,

  "END" => lambda do |terp|
    code = terp.stack.dup
    terp.stack = []
    terp.define_variable terp.latest, terp.make_word( code )
    terp.stop_compiling
  end
}

StackWords = {
  "DUP" => lambda do |terp|
    terp.error_if_stack_isnt_sufficient! :<, 1
    tos = terp.stack.pop
    terp.stack << tos << tos
  end,

  "DROP" => lambda do |terp|
    terp.error_if_stack_isnt_sufficient! :<, 1
    terp.stack.pop
  end,

  "SWAP" => lambda do |terp|
    terp.error_if_stack_isnt_sufficient! :<, 2
    tos = terp.stack.pop
    _2os = terp.stack.pop
    terp.stack << tos
    terp.stack << _2os
  end,

  "OVER" => lambda do |terp|
    terp.error_if_stack_isnt_sufficient! :<, 2
    tos = terp.stack.pop
    _2os = terp.stack.pop
    terp.stack << _2os
    terp.stack << tos
    terp.stack << _2os
  end,

  "ROT" => lambda do |terp|
    terp.error_if_stack_isnt_sufficient! :<, 3
    tos = terp.stack.pop
    _2os = terp.stack.pop
    _3os = terp.stack.pop
    terp.stack << _2os
    terp.stack << tos
    terp.stack << _3os
  end,
}

ListWords = {
  "[" => lambda do |terp|
    list = []
    old_stack = terp.stack.__getobj__
    terp.stack.__setobj__ list

    loop do
      word = terp.lexer.next_word
      raise UnexpectedEOI.new if word.nil?
      break if word == ']'

      token = terp.compile word
      if Scratch::IMMEDIATES.include? word
        terp.interpret token
      else
        terp.stack << token
      end
    end

    terp.stack.__setobj__ old_stack
    terp.stack << list
  end, 

  "LENGTH" => lambda do |terp|
    terp.error_if_stack_isnt_sufficient! :<, 1
    list = terp.stack.pop
    terp.stack << list.size
  end, 

  "ITEM" => lambda do |terp|
    terp.error_if_stack_isnt_sufficient! :<, 2

    index = terp.stack.pop
    list = terp.stack.pop

    terp.stack.push list[index]
  end
}

ControlWords = {
  "RUN" => lambda do |terp|
    terp.error_if_stack_isnt_sufficient! :<, 1
    list = terp.stack.pop
    raise Scratch::MissingListExpectation.new(list) unless list.is_a? Array

    terp.interpret terp.make_word( list )
  end,

  "TIMES" => lambda do |terp|
    terp.error_if_stack_isnt_sufficient! :<, 2
    num_times = terp.stack.pop
    list = terp.stack.pop
    raise Scratch::MissingListExpectation.new(list) unless list.is_a? Array

    word = terp.make_word list
    num_times.times do 
      word.call terp
    end
  end,

  "IS_TRUE" => lambda do |terp|
    terp.error_if_stack_isnt_sufficient! :<, 2
    code = terp.stack.pop
    cond = terp.stack.pop

    raise Scratch::MissingListExpectation.new(code) unless code.is_a? Array
    is_true = cond.call(terp)
    if is_true
      terp.interpret terp.make_word(code)
    end
  end, 

  "IS_FALSE" => lambda do |terp|
    terp.error_if_stack_isnt_sufficient! :<, 2
    list = terp.stack.pop
    cond = terp.stack.pop

    raise Scratch::MissingListExpectation.new(list) unless list.is_a? Array
    is_true = cond.call(terp)
    unless is_true
      terp.interpret terp.make_word(list)
    end
  end
}

LogicWords = {
  "TRUE" => lambda {|terp| true }, 
  "FALSE" => lambda {|terp| false }, 
}

terp = Scratch.new
terp.add_words( PrintingWords )
terp.add_words( MathWords )
terp.add_words( VariableWords )
terp.add_words( ConstantWords )
terp.add_words( StringWords )
terp.add_words( CommentWords )
terp.add_words( StackWords )
terp.add_words( CompilingWords )
terp.add_words( ListWords )
terp.add_words( ControlWords )
terp.add_words( LogicWords )

#terp.run "1 2 3 45 678"
#terp.run "pstack"
#terp.run '" ----------------------" print'
#terp.run '" - dup" print'
#terp.run "dup pstack"
#terp.run '" ----------------------" print'
#terp.run '" - drop" print'
#terp.run "drop pstack"
#terp.run '" ----------------------" print'
#terp.run '" - swap" print'
#terp.run "swap pstack"
#terp.run '" ----------------------" print'
#terp.run '" - over" print'
#terp.run "over pstack"
#terp.run '" ----------------------" print'
#terp.run '" - rot" print'
#terp.run "rot pstack"
#terp.run '" ----------------------" print'
#terp.run "10 pstack"
#terp.run "1 2 3 print print print"
#terp.run "2 2 + print"
#terp.run "2 2 - print"
#terp.run "4 2 / print"
#terp.run "3 3 * 4 4 * + √ print"
#terp.run "var a"
#terp.run "var b"
#terp.run "12 b store"
#terp.run "10 a store"
#terp.run "a fetch print"
#terp.run "b fetch print"
#terp.run "12 a store"
#terp.run "a fetch print"
#terp.run "b fetch print"
#terp.run "5 const Q"
#terp.run "Q print"
#terp.run '" Hello World!" print'
#terp.run '/* abc */ " Hello World!" print'
#terp.run '/* abc */ Q print'
#terp.run 'def hypot  dup * swap dup * + √  end'
#terp.run '3 4 hypot .'
#terp.run '[ 1 2 3 ] .'
#terp.run '[ 1 2 3 [ 4 5 6 ] 7 ] .'
#terp.run '[ 1 2 3 [ 4 5 6 ] 7 ] 3 item .'
#terp.run '[ 1 2 3 ] 1 item .'
#terp.run '[ 1 " hello" print ] .'
#terp.run '[ 1 2 3 ] run .'
#terp.run '[ 1 ! ] 5 times'
DEBUG=true
terp.run 'false [ 1 ! ] is_true'
terp.run 'true [ 3 ! ] is_true'
terp.run 'false [ 2 ! ] is_false'
terp.run 'true [ 4 ! ] is_false'
terp.run 'false [ 5 ! ] is_false'
terp.run 'false [ 6 ! ] is_false'
terp.run 'true [ 7 ! ] is_false'
#puts terp.dictionary.inspect
