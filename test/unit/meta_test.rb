require 'test_helper'

class MetaTest < ActiveSupport::TestCase
  test "minimum ruby version" do
    vs = RUBY_VERSION.split('.').map {|n| n.to_i}
    assert vs[0] >= 2, "ruby major version"
    assert vs[1] >= 1, "ruby minor version"
    assert vs[2] >= 0, "ruby minorer version"
    # assert RUBY_PATCHLEVEL >= 247, "ruby patchlevel" #No patchlevel for 2.1.0
  end

  test "imagemagick is installed" do
    iv = `identify --version`
    assert iv =~ /Version/, "imagemagick is installed"
  end
end
