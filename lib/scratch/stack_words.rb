module Scratch
  module StackWords
    def dup 
      self.error_if_stack_isnt! 1
      self.stack << stack.last
    end

    def drop
      self.error_if_stack_isnt! 1
      stack.pop
    end

    def swap
      self.replace_n_types Object, Object do |_2os, tos|
        [ tos, _2os ]
      end
    end

    def over
      self.error_if_stack_isnt! 2
      self.stack << self.stack[-2]
    end

    def rot
      self.replace_n_types Object, Object, Object do |_3os, _2os, tos|
        [ _2os,  tos,  _3os ]
      end
    end
  end
end
