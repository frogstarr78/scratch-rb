module Scratch
  module ControlWords
    def exec
      self.stack.get_n_stack_items 1, [Array] do |code_list|
        interpret make_word( code_list )
      end
    end

    def times
      self.stack.get_n_stack_items 2, [Array, Fixnum] do |code_list, num_times|
        word = make_word code_list
        num_times.times do 
          word.call
        end
      end
    end

    def is_true?
      self.stack.get_n_stack_items 2, [Boolean, Array] do |cond, code_list|
        interpret make_word( code_list ) if cond
      end
    end

    def is_false?
      self.stack.get_n_stack_items 2, [Boolean, Array] do |cond, code_list|
        interpret make_word( code_list ) unless cond
      end
    end

    def if_else?
      self.stack.get_n_stack_items 3, [Boolean, Array, Array] do |cond, true_code, false_code|
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
      self.stack.get_n_stack_items 1, [Boolean] do |is_break|
        self.break_state = true if is_break
      end
    end

    def loop
      self.stack.get_n_stack_items 1, [Array] do |code_list|
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
