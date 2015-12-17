require 'test_helper'

class MediaObjectsHelperTest < ActionView::TestCase
  include MediaObjectsHelper

  test 'correct thumbnails - image' do
    mo = MediaObject.find_by_name 'some_image'
    correct1 = '<img alt="Tn some image" height="32" src="/media/ee/eee/tn_some_image" width="32" />'
    correct2 = "<img alt=\"Tn some image\" height=\"32\" src=\"/media/ee/eee/tn_some_image\" width=\"32\" />"
    correct3 = "<img alt=\"Tn some image\" height=\"16\" src=\"/media/ee/eee/tn_some_image\" width=\"16\" />"

    assert_equal correct1, media_object_thumbnail_helper(mo, nil, false)
    assert_equal correct2, media_object_thumbnail_helper(mo, nil, true)
    assert_equal correct3, media_object_thumbnail_helper(mo, '16x16', false)
  end

  test 'correct thumbnails - text' do
    mo = MediaObject.find_by_name 'some_text'
    correct1 = '<img alt="Text" height="32" src="/images/mime-icons/text.png" width="32" />'
    correct2 = "<img alt=\"Text download\" height=\"32\" src=\"/images/mime-icons/text-download.png\" width=\"32\" />"
    correct3 = "<img alt=\"Text\" height=\"16\" src=\"/images/mime-icons/text.png\" width=\"16\" />"

    assert_equal correct1, media_object_thumbnail_helper(mo, nil, false)
    assert_equal correct2, media_object_thumbnail_helper(mo, nil, true)
    assert_equal correct3, media_object_thumbnail_helper(mo, '16x16', false)
  end

  test 'correct thumbnails - pdf' do
    mo = MediaObject.find_by_name 'some_pdf'
    correct1 = '<img alt="Pdf" height="32" src="/images/mime-icons/pdf.png" width="32" />'
    correct2 = "<img alt=\"Pdf download\" height=\"32\" src=\"/images/mime-icons/pdf-download.png\" width=\"32\" />"
    correct3 = "<img alt=\"Pdf\" height=\"16\" src=\"/images/mime-icons/pdf.png\" width=\"16\" />"

    assert_equal correct1, media_object_thumbnail_helper(mo, nil, false)
    assert_equal correct2, media_object_thumbnail_helper(mo, nil, true)
    assert_equal correct3, media_object_thumbnail_helper(mo, '16x16', false)
  end

  test 'correct thumbnails - other' do
    mo = MediaObject.find_by_name 'some_other'
    correct1 = '<img alt="Document" height="32" src="/images/mime-icons/document.png" width="32" />'
    correct2 = "<img alt=\"Document download\" height=\"32\" src=\"/images/mime-icons/document-download.png\" width=\"32\" />"
    correct3 = "<img alt=\"Document\" height=\"16\" src=\"/images/mime-icons/document.png\" width=\"16\" />"

    assert_equal correct1, media_object_thumbnail_helper(mo, nil, false)
    assert_equal correct2, media_object_thumbnail_helper(mo, nil, true)
    assert_equal correct3, media_object_thumbnail_helper(mo, '16x16', false)
  end
end
