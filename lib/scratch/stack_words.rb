module Scratch
  module StackWords
    def dup 
      error_if_stack_isnt! 1
      self << stack.last
    end

    def drop
      error_if_stack_isnt! 1
      stack.pop
    end

    def swap
      error_if_stack_isnt! 2
      _2os, tos = stack.pop 2
      self << tos << _2os
    end

    def over
      error_if_stack_isnt! 2
      self << stack[-2]
    end

    def rot
      error_if_stack_isnt! 3
      _3os, _2os, tos = stack.pop 3
      self << _2os << tos << _3os
    end
  end
end
