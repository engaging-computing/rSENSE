require 'test_helper'

class FieldsHelperTest < ActionView::TestCase
  include FieldsHelper

  test 'invalid field name' do
    resp = get_field_name(6)
    assert resp.include?('invalid input'), "There isn't a sixth field name"
  end

  test 'get timestamp field type' do
    resp = get_field_type('Timestamp')
    assert resp == 1, 'Wrong field type for timestamp'
  end

  test 'invalid field type' do
    resp = get_field_type('eigenvector')
    assert resp.include?('invalid input'), "There isn't a field type named eigenvector"
  end
end
