module Scratch
  module ControlWords
    def exec
      error_if_stack_isnt! 1
      code_list = stack.pop
      raise MissingListExpectation.new(code_list) unless code_list.is_a? Array

      interpret make_word( code_list )
    end

    def times
      error_if_stack_isnt! 2
      code_list, num_times = stack.pop 2
      raise MissingListExpectation.new(code_list) unless code_list.is_a? Array

      word = make_word code_list
      num_times.times do 
        word.call
      end
    end

    def is_true?
      error_if_stack_isnt! 2
      cond, code_list = stack.pop 2

      raise MissingListExpectation.new(code_list) unless code_list.is_a? Array
      if cond
        interpret make_word( code_list )
      end
    end

    def is_false?
      error_if_stack_isnt! 2
      cond, code_list = stack.pop 2

      raise MissingListExpectation.new(code_list) unless code_list.is_a? Array
      unless cond
        interpret make_word( code_list )
      end
    end

    def if_else?
      error_if_stack_isnt! 3
      cond, true_code, false_code = self.stack.pop 3

      raise MissingListExpectation.new(true_code) unless true_code.is_a? Array
      raise MissingListExpectation.new(false_code) unless false_code.is_a? Array

      if cond
        interpret make_word( true_code )
      else
        interpret make_word( false_code )
      end
    end

#    def continue?
#      error_if_stack_isnt! 1
##      next if stack.pop
#    end

    def break?
      error_if_stack_isnt! 1
      self.break_state = true if stack.pop
    end

    def loop
      error_if_stack_isnt! 1
      code_list = stack.pop
      raise MissingListExpectation.new(code_list) unless code_list.is_a? Array

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
