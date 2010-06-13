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

    %w(compiling? start_compiling! stop_compiling! stack).each do |meth|
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
      should "work" do
        stack.stubs(:stack).returns [0, 1, 6]
        pstack = stack.pop 2
        assert_equal [1, 6], pstack
        assert_equal [0], stack.stack
      end
    end

    context "\b#size" do
      should "work" do
        stack.stubs(:stack).returns [2, 7]
        assert_equal 2, stack.size
      end
    end

    context "\b#last" do
      should "work" do
        stack.stubs(:stack).returns [2, 3, 8]
        lstack = stack.last 2
        assert_equal [3, 8], lstack
        assert_equal [2, 3, 8], stack.stack
      end
    end

    context "\b#<<" do
      should "shift stuff onto the data stack" do
        stack.stubs(:stack).returns [9]
        stack << 3 << 4
        assert_equal [9, 3, 4], stack.stack
      end
    end

    context "\b#[]" do
      should "return item from the data stack" do
        stack.stubs(:stack).returns [4, 3, 2, 1]
        istack = stack[3]
        assert_equal 1, istack

        istack = stack[2..-1]
        assert_equal [2, 1], istack
      end
    end

    context "\b#clear" do
      should "clear data stack" do
        stack.stubs(:stack).returns [1, 2, 3]
        stack.clear
        assert_equal [], stack.stack
      end
    end

    context "\b#dup" do
      setup do
        @stack_id = stack.stack.object_id
      end
      should "copy data stack" do
        stack.stubs(:stack).returns [1, 2, 3]
        dup_stack = stack.dup
        assert_equal [1, 2, 3], dup_stack
        assert_not_equal dup_stack.object_id, @stack_id
      end
    end
  end
end
