require 'generator' 

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

class String
  def is_whitespace?
    return self == " " || 
      self == "\t" ||
      self == "\r" || 
      self == "\n" ||
      self == "\v"
  end
end

class ScratchLexer
  attr_accessor :words, :generator
  def initialize txt
    @words = txt.split /\s+/
    @generator = Generator.new @words
  end

  def next_word
    generator.next
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
    lambda {|terp| terp.stack.push value }
  end

  def run text
    self.lexer = ScratchLexer.new(text)

    while lexer.generator.next?
      word = lexer.generator.next.upcase
      if dictionary.has_key?( word )
        dictionary[word].call(self)
      elsif word =~ /^\d+$/
        stack.push word.to_i
      else
        raise "Unknown word '#{word}'."
      end
    end
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
  terp.stack.push tstack2.send( op, tstack )
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
    terp.stack.push tstack ** 0.5
  end,
}

VariableWords = {
  "VAR" => lambda do |terp|
    var_name = terp.lexer.next_word
    raise UnexpectedEOI.new if var_name.nil?

    @var = Variable.new( 0 )
    terp.define_variable var_name, lambda{|terp| terp.stack.push( @var ) }
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
    terp.stack.push(@var.value)
  end

}

ConstantWords = {
  "CONS" => lambda do |terp|
    raise StackTooSmall.new if terp.stack.size < 1

    cons_name = terp.lexer.next_word
    raise UnexpectedEOI.new if cons_name.nil?

    cons_value = terp.stack.pop
    terp.define_variable cons_name, lambda {|terp| terp.stack.push( cons_value ) }
  end
}

StringWords = {
  '"' => lambda do |terp|
    collector = ""
    done = false

    until done
      word = terp.lexer.next_word
      raise UnexpectedEOI.new if word.nil?
      
      if word[-1, 1] == '"'
        collector << word[0,word.size-1]
        done = true
      else
        collector << word << " "
      end
    end

    terp.stack.push collector
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

terp = Scratch.new
terp.add_words( PrintingWords )
terp.add_words( MathWords )
terp.add_words( VariableWords )
terp.add_words( ConstantWords )
terp.add_words( StringWords )
terp.add_words( CommentWords )

#terp.run "1 2 3 45 678"
#terp.run "10 pstack"
#terp.run "1 2 3 print print print"
terp.run "2 2 + print"
terp.run "2 2 - print"
terp.run "4 2 / print"
terp.run "3 3 * 4 4 * + √ print"
terp.run "var a"
terp.run "var b"
terp.run "12 b store"
terp.run "10 a store"
terp.run "a fetch print"
terp.run "b fetch print"
terp.run "12 a store"
terp.run "a fetch print"
terp.run "b fetch print"
terp.run "5 cons Q"
terp.run "Q print"
terp.run '" Hello World!" print'
terp.run '/* abc */ " Hello World!" print'
terp.run '/* abc */ Q print'
#puts terp.stack.inspect
