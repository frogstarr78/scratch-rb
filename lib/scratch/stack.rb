require 'delegate'

module Scratch
  class Stack
#    attr_reader :stack
    def initialize
      @data = []
      @buffer = []
      @stack = SimpleDelegator.new @data
      @compiling = false
    end

    def compiling?
      @compiling == true
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
      return stack.pop if n.nil?
      stack.pop n
    end

    def size
      stack.size
    end

    def last n = nil
      return stack.last if n.nil?
      stack.last n
    end

    def << stuff
      stack << stuff
#      if compiling?
#        @buffer << stuff
#      else
#        @data << stuff
#      end
    end

    def [] index
      stack[index]
    end

    def clear 
      stack.clear
    end

#    def method_missing method, *args
#      unless method.to_s == 'each'
#        @stack.__getobj__.send method, *args
#      end
#    end
  end
end
