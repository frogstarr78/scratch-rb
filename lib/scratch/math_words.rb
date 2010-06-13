module Scratch
  module MathWords
    def +
      send_ruby_op "+"
    end

    def -
      send_ruby_op "-"
    end

    def *
      send_ruby_op "*"
    end

    def /
      send_ruby_op "/"
    end

    define_method "√" do
      self.replace_n_types Fixnum do |num|
        num ** 0.5
      end
    end
  end
end
