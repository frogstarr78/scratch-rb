require 'delegate'

module Scratch
  class Stack
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

    def size
      stack.size
    end

    def last n = nil
      return stack.last if n.nil? or n == 1
      stack.last n
    end

    def << stuff
      stack << stuff
    end

    def [] index
      stack[index]
    end

    def clear 
      stack.clear
    end
  end
end
