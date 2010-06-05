require 'helper'

class TestCommentWords < TestHelper
  context 'Scratch::CommentWords' do
    should 'define :/*' do
      fail
      assert Scratch::CommentWords.instance_methods(false).include?( '/*' )
    end
  end

  context '" method' do
    should "work" do
      fail
    end
  end
end
