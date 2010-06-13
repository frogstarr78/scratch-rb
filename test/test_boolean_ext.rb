require 'helper'

class TestBooleanClass < TestHelper
  context "FalseClass" do
    should "respond_to? :&&" do
      assert_respond_to false, "&&"
    end
    should "respond_to? :||" do
      assert_respond_to false, "||"
    end

    context "\b#&&" do
      should "work when true" do
        assert !false.send("&&", true)
      end

      should "work when false" do
        assert !false.send("&&", false)
      end
    end

    context "\b#||" do
      should "work when true" do
        assert false.send("||", true)
      end
      should "work when false" do
        assert !false.send("||", false)
      end
    end
  end

  context "TrueClass" do
    should "respond_to? :&&" do
      assert_respond_to true, "&&"
    end
    should "respond_to? :||" do
      assert_respond_to true, "||"
    end

    context "\b#&&" do
      should "work when true" do
        assert true.send("&&", true)
      end

      should "work when false" do
        assert !true.send("&&", false)
      end
    end

    context "\b#||" do
      should "work when true" do
        assert true.send("||", true)
      end
      should "work when false" do
        assert true.send("||", false)
      end
    end
  end
end
