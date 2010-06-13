module Scratch
  module PrintingWords
    def print
      self.stack.get_n_stack_items 1, [Object] do |stuff|
        Kernel.print stuff
      end
    end

    def puts
      self.stack.get_n_stack_items 1, [Object] do |stuff|
        Kernel.puts stuff
      end
    end

    def pstack
      Kernel.puts self.stack
    end
  end
end
