require 'helper'

class TestControlWords < TestHelper
  context 'Scratch::ControlWords' do
    %w(exec times is_true? is_false? if_else? continue? break? loop).each do |method|
      should "define :'#{method}'" do
        assert Scratch::ControlWords.instance_methods(false).include?( method )
      end
    end

    context 'exec method' do
      should "work"
      should "raise StackTooSmall error when called with empty stack"
      should "raise MissingListExpectation error the stack doesn't have a list"
    end

    context 'times method' do
      should "work"
      should "raise StackTooSmall error when called with empty stack"
      should "raise StackTooSmall error when called with one element in the stack"
      should "raise MissingListExpectation error when the first element in the stack isn't a list"
    end

    context 'is_true? method' do
      should "work"
      should "raise StackTooSmall error when called with empty stack"
      should "raise StackTooSmall error when called with one element in the stack"
      should "raise MissingListExpectation error when the first element in the stack isn't a list"
    end

    context 'is_false? method' do
      should "work"
      should "raise StackTooSmall error when called with empty stack"
      should "raise StackTooSmall error when called with one element in the stack"
      should "raise MissingListExpectation error when the first element in the stack isn't a list"
    end

    context 'if_else? method' do
      should "work"
      should "raise StackTooSmall error when called with empty stack"
      should "raise StackTooSmall error when called with one element in the stack"
      should "raise StackTooSmall error when called with two elements in the stack"
      should "raise MissingListExpectation error when the first element in the stack isn't a list"
      should "raise MissingListExpectation error when the second element in the stack isn't a list"
    end

    context 'continue? method' do
      should "work"
      should "raise StackTooSmall error when called with empty stack"
    end

    context 'break? method' do
      should "work"
      should "raise StackTooSmall error when called with empty stack"
    end

    context 'loop method' do
      should "work"
      should "raise StackTooSmall error when called with empty stack"
      should "raise MissingListExpectation error when the first element in the stack isn't a list"
    end
  end
end
