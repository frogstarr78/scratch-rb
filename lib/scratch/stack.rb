require 'delegate'

module Scratch
  class Stack
    undef_method :dup

    def initialize
      @data = []
      @buffer = []
      @stack = SimpleDelegator.new @data
      @compiling = false
    end

    def compiling?
      @compiling == true
#      stack.object_id == @buffer.object_id
    end

    def start_compiling!
      @stack.__setobj__ @buffer
      @compiling = true
    end

    def stop_compiling!
      @stack.__setobj__ @data
      @buffer.clear
      @compiling = false
    end

    def stack
      @stack.__getobj__
    end

    def pop n = nil
      return stack.pop if n.nil? or n == 1
      stack.pop n
    end

    def last n = nil
      return stack.last if n.nil? or n == 1
      stack.last n
    end

    def get_n_stack_items num, validations
      error_if_stack_isnt! num 

      stack_items = stack.pop(num)
      stack_items.validate! validations

      yield *stack_items
    end

    def replace_n_pop_items num, validations, &block
      items = get_n_stack_items( num, validations, &block )
      if items.is_array?
        items.each do |item|
          self.stack << item
        end
      else
        self.stack << items
      end
    end

    def error_if_stack_isnt! check
      raise StackTooSmall.new stack, check if self.stack.size < check 
    end

    def method_missing sym, *arguments
      meth = self.stack.method(sym)
      return meth.call if meth.arity == 0
      meth.call *arguments
    end
  end
end
