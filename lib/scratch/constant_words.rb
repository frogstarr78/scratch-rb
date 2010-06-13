module Scratch
  module ConstantWords
    def const
      self.get_n_types Fixnum do |value|
        const_name = lexer.next_word
        raise UnexpectedEOI.new if const_name.nil?

        if respond_to? const_name.to_sym
          raise ConstantReDefine.new const_name
        else
          define_variable(const_name) { value }
        end
      end
    end
  end
end
