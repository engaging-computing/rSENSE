require 'test_helper'
require_relative 'base_integration_test'

class UploadMediaTest < IntegrationTest
  self.use_transactional_fixtures = false

  # Upload pdf to tutorial
  test 'upload pdf to tutorial' do
    login('nixon@whitehouse.gov', '12345')
    tutorial_id = tutorials(:media_test).id
    visit "/tutorials/#{tutorial_id}/edit"
    assert page.has_no_content? 'Media' 'should be no media by default'
    pdf_path = Rails.root.join('test', 'CSVs', 'test.pdf')
    find('.upload_media form').attach_file('upload', pdf_path)
    assert page.has_content?('test.pdf'), 'File should be in list'
    find('.media_edit').click
    assert page.has_content?('test.pdf'), 'Should have gone to edit page'
  end

  # Upload media to news
  test 'upload media to news' do
    login('nixon@whitehouse.gov', '12345')
    news_id = news(:media_test).id
    visit "/news/#{news_id}"
    assert page.has_content? 'Media'
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    find('.upload_media form').attach_file('upload', img_path)
    assert page.has_content?('nerdboy.jpg'), 'File should be in list'
    find('.media_edit').click
    assert page.has_content?('nerdboy.jpg'), 'Should have gone to edit page'
    visit "/news/#{news_id}"
    find('.menu_edit_link').click
    find('.menu_delete').click
    # Capybara-webkit needs the window.confirm hack instead.
    # page.driver.browser.switch_to.alert.accept
    # No more Selenium, use this instead
    page.driver.browser.accept_js_confirms
  end

  # Upload jpg to project
  test 'upload jpg to project' do
    login('nixon@whitehouse.gov', '12345')
    proj_id = projects(:media_test).id
    visit "/projects/#{proj_id}"
    assert page.has_content? 'Media'
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    find('.upload_media form').attach_file('upload', img_path)
    assert page.has_content?('nerdboy.jpg'), 'File should be in list'

    nerdboy_found = 0
    @project = Project.find(proj_id)
    @project.media_objects.length.times do |i|
      visit "/projects/#{proj_id}"
      all('.media_edit')[i].click
      if page.html.include? 'nerdboy.jpg'
        nerdboy_found += 1
      end
      assert page.html.include? "data-page-name=\"media_objects/show\""
    end
    assert nerdboy_found == 1, 'Nerdboy was not displayed exactly once on the media objects view.'
  end

  # Upload text file to project
  test 'upload txt file to project' do
    login('nixon@whitehouse.gov', '12345')
    proj_id = projects(:media_test).id
    visit "/projects/#{proj_id}"
    assert page.has_content? 'Media'
    text_path = Rails.root.join('test', 'CSVs', 'test.txt')
    find('.upload_media form').attach_file('upload', text_path)
    assert page.has_content?('test.txt'), 'File should be in list'
  end

  # Upload pdf to project
  test 'upload pdf to project' do
    login('nixon@whitehouse.gov', '12345')
    proj_id = projects(:media_test).id
    visit "/projects/#{proj_id}"
    assert page.has_content? 'Media'
    pdf_path = Rails.root.join('test', 'CSVs', 'test.pdf')
    find('.upload_media form').attach_file('upload', pdf_path)
    assert page.has_content?('test.pdf'), 'File should be in list'
  end

  # Upload ods to project
  test 'upload ods to project' do
    login('nixon@whitehouse.gov', '12345')
    proj_id = projects(:media_test).id
    visit "/projects/#{proj_id}"
    assert page.has_content? 'Media'
    ods_path = Rails.root.join('test', 'CSVs', 'test.ods')
    find('.upload_media form').attach_file('upload', ods_path)
    assert page.has_content?('test.ods'), 'File should be in list'
  end

  # Failed Upload media to project
  test 'upload html to project should fail' do
    login('nixon@whitehouse.gov', '12345')
    proj_id = projects(:media_test).id
    visit "/projects/#{proj_id}"
    assert page.has_content? 'Media'
    html_path = Rails.root.join('test', 'CSVs', 'test.html')
    find('.upload_media form').attach_file('upload', html_path)
    assert page.has_no_content?('test.html'), 'File should be in list'
    assert page.has_content?('Sorry, html is not a supported file type.'), 'Unsupported file type failed.'
  end
end
