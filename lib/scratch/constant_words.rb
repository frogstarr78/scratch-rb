module Scratch
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
end
