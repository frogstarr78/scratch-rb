module Scratch
  module ControlWords
    def exec
      self.stack.get_n_stack_items do |code_list|
        raise MissingListExpectation.new(code_list) unless code_list.is_array?
        interpret make_word( code_list )
      end
    end

    def times
      self.stack.get_n_stack_items 2 do |code_list, num_times|
        raise MissingListExpectation.new(code_list) unless code_list.is_array?

        word = make_word code_list
        num_times.times do 
          word.call
        end
      end
    end

    def is_true?
      self.stack.get_n_stack_items 2 do |cond, code_list|
        raise MissingListExpectation.new(code_list) unless code_list.is_array?
        if cond
          interpret make_word( code_list )
        end
      end
    end

    def is_false?
      self.stack.get_n_stack_items 2 do |cond, code_list|
        raise MissingListExpectation.new(code_list) unless code_list.is_array?
        unless cond
          interpret make_word( code_list )
        end
      end
    end

    def if_else?
      self.stack.get_n_stack_items 3 do |cond, true_code, false_code|
        raise MissingListExpectation.new(true_code) unless true_code.is_array?
        raise MissingListExpectation.new(false_code) unless false_code.is_array?

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
      self.stack.get_n_stack_items do |is_break|
        self.break_state = true if is_break
      end
    end

    def loop
      self.stack.get_n_stack_items do |code_list|
        raise MissingListExpectation.new(code_list) unless code_list.is_array?

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
