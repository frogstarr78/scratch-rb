require 'rubygems'
require 'test/unit'
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
end
