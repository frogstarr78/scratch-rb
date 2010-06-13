require 'delegate'

module Scratch
  class Stack
    stack_delegate_methods = %w(dup)
    stack_delegate_methods.each do |meth|
      undef_method meth.to_sym
    end

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

    def get_n_stack_items num = 1
      error_if_stack_isnt! num 
      yield *stack.pop(num)
    end

    def replace_n_pop_items num = 1, &block
      items = get_n_stack_items( num, &block )
      if items.is_a? Array
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
      if meth.arity == 0
        meth.call
      else
        meth.call *arguments
      end
    end
  end
end
