require 'helper'

class TestCommentWords < TestHelper
  context 'Scratch::CommentWords' do
    should 'define :/*' do
      assert Scratch::CommentWords.instance_methods(false).include?( '/*' )
    end

    context '/* method' do
      should "work" do
        terp.run "4 /* comment here */ 5"
        assert_equal_stack [4, 5], terp.stack
      end
    end
  end
end
