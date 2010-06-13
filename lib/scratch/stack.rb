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

    def method_missing sym, *arguments
      meth = self.stack.method(sym)
      return meth.call if meth.arity == 0
      meth.call *arguments
    end
  end
end
