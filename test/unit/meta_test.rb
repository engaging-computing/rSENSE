require 'test_helper'

class DataSetTest < ActiveSupport::TestCase
  test "minimum ruby version" do
    vs = RUBY_VERSION.split('.').map {|n| n.to_i}
    assert vs[0] >= 2, "ruby major version"
    assert vs[1] >= 0, "ruby minor version"
    assert vs[2] >= 0, "ruby minorer version"
    assert RUBY_PATCHLEVEL >= 247, "ruby patchlevel"
  end
end
