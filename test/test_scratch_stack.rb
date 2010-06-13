require 'helper'

class TestScratchStack < TestHelper
  def stack
    @stack ||= Scratch::Stack.new
  end

  context "Scratch::Stack" do
    setup do
      @buffer_object_id = stack.buffer.object_id
      @data_object_id   = stack.data.object_id
    end

    %w(compiling? start_compiling! stop_compiling! stack pop last).each do |meth|
      should "respond_to? #{meth}" do
        assert_respond_to terp.stack, meth
      end
    end

    should "correctly report compiling?" do
      stack.compiling = false
      assert !stack.compiling
      assert !stack.compiling?

      stack.compiling = true
      assert stack.compiling
      assert stack.compiling?
    end

    should "start_compiling!" do
      stack << '3'
      assert_equal_stack ['3'], stack
      assert_equal_compiling_stack [], stack
      assert !stack.compiling?

      stack.start_compiling!
      stack << '2'
      assert_equal_stack ['3'], stack
      assert_equal_compiling_stack ['2'], stack
      assert stack.compiling?
    end

    should "stop_compiling!" do
      stack.data << '0'
      stack.buffer << '1'
      stack.start_compiling!
      assert_equal_stack ['0'], stack
      assert_equal_compiling_stack ['1'], stack

      stack.stop_compiling!
      assert_equal_stack ['0'], stack
      assert_equal_compiling_stack [], stack
    end

    should "reference the correct stack" do
      assert_equal @data_object_id, stack.stack.object_id

      stack.start_compiling!
      assert_equal @buffer_object_id, stack.stack.object_id
    end

    context "\b#pop" do
      should "pop the correct n item(s) from the data stack" do
        stack << 1 << 6
        assert_equal_stack [1, 6], stack
        assert_equal_compiling_stack [], stack
        popd_stack = stack.pop
        assert_equal_stack [1], stack
        assert_equal 6, popd_stack

        stack << 5 << 9 << 3
        assert_equal_stack [1, 5, 9, 3], stack
        popd_stack = stack.pop 2
        assert_equal_stack [1, 5], stack
        assert_equal [9, 3], popd_stack

        popd_stack = stack.pop 1
        assert_equal 5, popd_stack
        assert_equal_stack [1], stack
      end

      should "pop the correct n item(s) from the buffer stack" do
        stack.start_compiling!
        stack << 7 << 8 << 2
        assert_equal_stack [], stack
        assert_equal_compiling_stack [7, 8, 2], stack
        stack.pop 2
        assert_equal_compiling_stack [7], stack
      end
    end

    context "\b#size" do
      should "return the correct size from the data" do
        stack << '9'
        assert_equal 1, stack.size
      end

      should "return the correct size from the buffer" do
        stack.start_compiling!
        stack << '3' << '2'
        assert_equal 2, stack.size
      end
    end

    context "\b#last" do
      should "return the correct last n item(s) from the data stack" do
        stack << 1 << 6
        assert_equal_stack [1, 6], stack
        assert_equal_compiling_stack [], stack
        popd_stack = stack.last
        assert_equal_stack [1, 6], stack
        assert_equal 6, popd_stack

        stack << 5 << 9 << 3
        assert_equal_stack [1, 6, 5, 9, 3], stack
        popd_stack = stack.last 2
        assert_equal_stack [1, 6, 5, 9, 3], stack
        assert_equal [9, 3], popd_stack

        popd_stack = stack.last 1
        assert_equal 3, popd_stack
        assert_equal_stack [1, 6, 5, 9, 3], stack
      end

      should "return the correct last n item(s) from the buffer stack" do
        stack.start_compiling!
        stack << 7 << 8 << 2
        assert_equal_stack [], stack
        assert_equal_compiling_stack [7, 8, 2], stack
        popd_stack = stack.last 2
        assert_equal_compiling_stack [7, 8, 2], stack
        assert_equal [8, 2], popd_stack
      end
    end

    context "\b#<<" do
      should "shift stuff onto the data stack" do
        assert_equal [], stack.stack
        assert !stack.compiling?
        stack << 9
        assert_equal [9], stack.stack
      end

      should "shift stuff onto the buffer stack" do
        stack.start_compiling!
        assert_equal [], stack.stack
        assert stack.compiling?
        stack << 9
        assert_equal [9], stack.stack
      end
    end

    context "\b#[]" do
      should "return item from the data stack" do
        stack << 4 << 3 << 2 << 1
        assert !stack.compiling?
        assert_equal 2, stack[2]
      end

      should "return item from the buffer stack" do
        stack.start_compiling!
        stack << 4 << 3 << 2 << 1
        assert stack.compiling?
        assert_equal 3, stack[1]
      end
    end

    context "\b#clear" do
      should "clear data stack" do
        stack << 1 << 2 << 3
        assert_equal 3, stack.size
        stack.clear
        assert_equal 0, stack.size
      end

      should "clear buffer stack" do
        stack.start_compiling!
        stack << 1 << 2 << 3 << 4 << 5
        assert_equal 5, stack.size
        stack.clear
        assert_equal 0, stack.size
      end
    end

    context "\b#dup" do
      setup do
        @stack_id = stack.object_id
      end
      should "copy data stack" do
        stack << 1 << 2 << 3
        assert_equal_stack [1, 2, 3], stack
        dup_stack = stack.dup
        assert_equal [1, 2, 3], dup_stack
        assert_not_equal dup_stack.object_id, @stack_id
      end

      should "copy buffer stack" do
        stack.start_compiling!
        stack << 1 << 2 << 3
        assert_equal_compiling_stack [1, 2, 3], stack
        dup_stack = stack.dup
        assert_equal [1, 2, 3], dup_stack
        assert_not_equal dup_stack.object_id, @stack_id
      end
    end

    context "error_if_stack_isnt!" do
      setup do
        stack << 1 << 2
      end

      should "raise error when the stack isn't correct size" do
        assert_raise Scratch::StackTooSmall do
          stack.send :error_if_stack_isnt!, 3
        end
        assert_equal_stack [1, 2], stack
      end

      should "not raise an error when the stack is less than the supplied size" do
        assert_nothing_raised do
          stack.send :error_if_stack_isnt!, 2
        end
        assert_equal_stack [1, 2], stack
      end
    end

    context "get_n_stack_items" do
      setup do
        stack << 3 << 4
        @yielded_items = []
      end

      should "yield 1 item by default " do
        stack.get_n_stack_items do |*items|
          @yielded_items = items
        end
        assert_equal [4], @yielded_items
      end

      should "yield the requested number of items" do
        stack.get_n_stack_items 2 do |*items|
          @yielded_items = items
        end
        assert_equal [3, 4], @yielded_items
      end

      should "rather than yield number of items, raise an error, when the number of items aren't available" do
        assert_raise Scratch::StackTooSmall do
          stack.get_n_stack_items 3 do |*items|
            @yielded_items = items
          end
          assert_equal [], @yielded_items
        end
      end
    end
  end
end
