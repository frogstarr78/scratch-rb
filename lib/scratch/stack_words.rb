module Scratch
  module StackWords
    def dup 
      self.stack.error_if_stack_isnt! 1
      self.stack << stack.last
    end

    def drop
      self.stack.error_if_stack_isnt! 1
      stack.pop
    end

    def swap
      self.stack.replace_n_pop_items 2 do |_2os, tos|
        [ tos, _2os ]
      end
    end

    def over
      self.stack.error_if_stack_isnt! 2
      self.stack << self.stack[-2]
    end

    def rot
      self.stack.replace_n_pop_items 3 do |_3os, _2os, tos|
        [ _2os,  tos,  _3os ]
      end
    end
  end
end
