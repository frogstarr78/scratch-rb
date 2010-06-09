require 'rubygems'
require 'test/unit'
require 'test/unit/assertions'
require 'shoulda'
require 'mocha'
require 'unittest-colorizer'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'scratch'

class TestHelper < Test::Unit::TestCase
  def terp 
    @terp ||= Scratch::Scratch.new
  end

  def test_me
  end

  def equal_stack compiling, expected, stack, message = nil
    message = build_message "?\nexpected ?compiling stack to be <?>, but was <?>.", message, ('non-' unless compiling), expected.inspect, stack.inspect
    assert_block message do
      expected == stack
    end
  end

  def assert_equal_stack expected, stack, message = nil
    equal_stack false, expected, stack.data, message
  end

  def assert_equal_compiling_stack expected, stack, message = nil
    equal_stack true, expected, stack.buffer, message
  end
end

module Scratch
  class Stack
    attr_reader :data, :buffer

    def pop
      if compiling?
        @buffer.pop
      else
        @data.pop
      end
    end
  end
end
