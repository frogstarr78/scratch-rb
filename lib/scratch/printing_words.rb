module Scratch
  module PrintingWords
    def print
      error_if_stack_isnt! 1
      Kernel.print stack.pop
    end

    def puts
      error_if_stack_isnt! 1
      Kernel.puts stack.pop
    end

    def pstack
      Kernel.puts stack
    end
  end
end
