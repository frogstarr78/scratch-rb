module Scratch
  module PrintingWords
    def print
      self.get_n_types Object do |stuff|
        Kernel.print stuff
      end
    end

    def puts
      self.get_n_types Object do |stuff|
        Kernel.puts stuff
      end
    end

    def pstack
      Kernel.puts self.stack.stack
    end
  end
end
