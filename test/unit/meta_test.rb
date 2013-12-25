require 'test_helper'

class DataSetTest < ActiveSupport::TestCase
  test "minimum ruby version" do
    vs = RUBY_VERSION.split('.').map {|n| n.to_i}
    assert vs[0] >= 2, "ruby major version"
    assert vs[1] >= 0, "ruby minor version"
    assert vs[2] >= 0, "ruby minorer version"
    assert RUBY_PATCHLEVEL >= 0, "ruby patchlevel"
  end

  test "imagemagick is installed" do
    iv = `identify --version`
    assert iv =~ /Version/, "imagemagick is installed"
  end
end
