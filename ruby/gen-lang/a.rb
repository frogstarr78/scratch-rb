require 'generator' 
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
      puts "nw char '#{char}'" if DEBUG
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
      puts "nct char '#{char}'" if DEBUG
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
    puts "word #{word}" if DEBUG

    word
  end
end

class Scratch
  attr_accessor :dictionary, :stack, :lexer

  def initialize
    @dictionary = {}
    @stack = []
    @lexer = nil
  end

  def add_words new_dict
    new_dict.each do |word, callback|
      dictionary.update word.upcase => callback
    end
  end

  def define_variable word, code
    dictionary.update word.upcase => code
  end

  def define_constant value, terp
    lambda {|terp| terp.stack << value }
  end

  def run text
    self.lexer = ScratchLexer.new(text)

    while word = lexer.next_word
      word.upcase!
      if dictionary.has_key?( word )
        puts "word '#{word}'" if DEBUG
        dictionary[word].call(self)
      elsif word.is_numeric?
        stack << word.to_i
      else
        raise "Unknown word '#{word}'."
      end
#      word = lexer.next_word
    end
  end

  def lookup word
    dictionary[word]
  end
end

class StackTooSmall < Exception
  def message
    "Not enough items on stack"
  end
end

class UnexpectedEOI < Exception
  def message
    "Unexpected end of input"
  end
end

PrintingWords = {
  "PRINT" => lambda do |terp|
    raise StackTooSmall.new if terp.stack.empty? 
    puts terp.stack.pop
  end,

  "PSTACK" => lambda do |terp|
    puts terp.stack
  end

}

math_op = lambda do |terp, op|
  raise StackTooSmall.new if terp.stack.size < 2
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
    raise StackTooSmall.new if terp.stack.empty?
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
    raise StackTooSmall.new if terp.stack.size < 2
    @var = terp.stack.pop
    new_val = terp.stack.pop
    @var.value = new_val
  end,

  "FETCH" => lambda do |terp|
    raise StackTooSmall.new if terp.stack.size < 1
    @var = terp.stack.pop
    terp.stack << @var.value
  end

}

ConstantWords = {
  "CONST" => lambda do |terp|
    raise StackTooSmall.new if terp.stack.size < 1

    const_name = terp.lexer.next_word
    raise UnexpectedEOI.new if const_name.nil?

    const_value = terp.stack.pop
    terp.define_variable const_name, lambda {|terp| terp.stack <<  const_value }
  end
}

StringWords = {
  '"' => lambda do |terp|
    word = terp.lexer.next_chars_to('"')
    puts "word '#{word}'" if DEBUG
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

FunctionWords = {
  "DEF" => lambda do |terp|
    func_name = terp.lexer.next_word
    raise UnexpectedEOI.new if func_name.nil?
    done = false

    code = []
    until done
      word = terp.lexer.next_word
      raise UnexpectedEOI.new if func_name.nil?

      word.upcase!
      done = true and break if word == 'END'
      
      found_word = terp.lookup(word)
      if found_word
        case word
        when "VAR", "CONST", '"', '/*'
          found_word.call terp
        else
          code << found_word
        end
      elsif word.is_numeric?
        code << word.to_i
      else
        raise "Unknown word '#{word}'!"
      end
    end

    terp.define_variable(
      func_name, lambda do |terp|
        pointer = 0
        while pointer < code.size
          word = code[pointer]
          if word.is_a? Proc
            word.call(terp)
          else
            terp.stach << word
          end
          pointer += 1
        end
      end 
    )
  end
}

StackWords = {
  "DUP" => lambda do |terp|
    raise StackTooSmall.new if terp.stack.size < 1
    tos = terp.stack.pop
    terp.stack << tos << tos
  end,

  "DROP" => lambda do |terp|
    raise StackTooSmall.new if terp.stack.size < 1
    terp.stack.pop
  end,

  "SWAP" => lambda do |terp|
    raise StackTooSmall.new if terp.stack.size < 2
    tos = terp.stack.pop
    _2os = terp.stack.pop
    terp.stack << tos
    terp.stack << _2os
  end,

  "OVER" => lambda do |terp|
    raise StackTooSmall.new if terp.stack.size < 2
    tos = terp.stack.pop
    _2os = terp.stack.pop
    terp.stack << _2os
    terp.stack << tos
    terp.stack << _2os
  end,

  "ROT" => lambda do |terp|
    raise StackTooSmall.new if terp.stack.size < 3
    tos = terp.stack.pop
    _2os = terp.stack.pop
    _3os = terp.stack.pop
    terp.stack << _2os
    terp.stack << tos
    terp.stack << _3os
  end,
}

terp = Scratch.new
terp.add_words( PrintingWords )
terp.add_words( MathWords )
terp.add_words( VariableWords )
terp.add_words( ConstantWords )
terp.add_words( StringWords )
terp.add_words( CommentWords )
terp.add_words( CommentWords )
terp.add_words( FunctionWords )
terp.add_words( StackWords )

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
terp.run 'def hypot  dup * swap dup * + √  end'
terp.run '3 4 hypot print'
#puts terp.stack.inspect
#puts terp.dictionary.inspect
