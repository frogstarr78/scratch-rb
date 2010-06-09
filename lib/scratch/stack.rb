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
    end

    def start_compiling!
      @stack.__setobj__ @buffer
      @compiling = true
    end

    def stop_compiling!
      @stack.__setobj__ @data
      @compiling = false
    end

#    def pop n = 1
#      @stack.pop n
#    end

#    def size
#      @stack.size
#    end

#    def last
#      @stack.last
#    end

#    def << stuff
#      @stack << stuff
##      if compiling?
##        @buffer << stuff
##      else
##        @data << stuff
##      end
#    end

    def method_missing method, *args
      @stack.send method, *args
    end
  end
end
