module Scratch
  module ControlWords
    def exec
      self.get_n_types Array do |code_list|
        interpret make_word( code_list )
      end
    end

    def times
      self.get_n_types Array, Fixnum do |code_list, num_times|
        word = make_word code_list
        num_times.times do 
          word.call
        end
      end
    end

    def is_true?
      self.get_n_types Boolean, Array do |cond, code_list|
        interpret make_word( code_list ) if cond
      end
    end

    def is_false?
      self.get_n_types Boolean, Array do |cond, code_list|
        interpret make_word( code_list ) unless cond
      end
    end

    def if_else?
      self.get_n_types Boolean, Array, Array do |cond, true_code, false_code|
        if cond
          interpret make_word( true_code )
        else
          interpret make_word( false_code )
        end
      end
    end

#    def continue?
#      error_if_stack_isnt! 1
##      next if stack.pop
#    end

    def break?
      self.get_n_types Boolean do |is_break|
        self.break_state = true if is_break
      end
    end

    def loop
      self.get_n_types Array do |code_list|
        word = make_word code_list
        old_break_state = break_state
        break_state = false
        until self.break_state
          word.call
        end
        break_state = old_break_state
      end
    end
  end
end
