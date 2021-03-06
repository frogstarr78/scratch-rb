require 'helper'

class TestBooleanClass < TestHelper
  context "FalseClass" do
    should "respond_to? #&&" do
      assert_respond_to false, "&&"
    end
    should "respond_to? #||" do
      assert_respond_to false, "||"
    end
    should "respond_to? #!" do
      assert_respond_to false, "!"
    end

    should "be_a? Boolean" do
      assert_equal true, false.is_a?(Boolean)
    end

    context "\b#!" do
      should "be true" do
        assert false.send("!")
      end
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
    should "respond_to? #&&" do
      assert_respond_to true, "&&"
    end

    should "respond_to? #||" do
      assert_respond_to true, "||"
    end

    should "respond_to? #!" do
      assert_respond_to true, "!"
    end

    should "be_a? Boolean" do
      assert_equal true, false.is_a?(Boolean)
    end

    context "\b#!" do
      should "be false" do
        assert !true.send("!")
      end
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
