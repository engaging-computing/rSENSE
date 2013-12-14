require 'test_helper'

class EnterDataSetTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = Capybara.javascript_driver
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end
  
  test "upload media" do 
    login("nixon", "12345")
    
    #Upload media to tutorial
    visit '/tutorials/1'
    assert page.has_content? "Media"
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    page.execute_script %Q{$('#upload').show()}
    find(".upload_media form").attach_file("upload", img_path)
    assert page.has_content?("nerdboy.jpg"), "File should be in list"

    #Upload media to news
    visit '/news/1'
    assert page.has_content? "Media"
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    page.execute_script %Q{$('#upload').show()}
    find(".upload_media form").attach_file("upload", img_path)
    assert page.has_content?("nerdboy.jpg"), "File should be in list"

    #Upload media to project
    visit '/projects/1'
    assert page.has_content? "Media"
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    page.execute_script %Q{$('#upload').show()}
    find(".upload_media form").attach_file("upload", img_path)
    assert page.has_content?("nerdboy.jpg"), "File should be in list"

    #Upload media to project
    visit '/projects/1'
    assert page.has_content? "Media"
    text_path = Rails.root.join('test', 'CSVs', 'test.txt')
    page.execute_script %Q{$('#upload').show()}
    find(".upload_media form").attach_file("upload", text_path)
    assert page.has_content?("test.txt"), "File should be in list"

    #Upload media to project
    visit '/projects/1'
    assert page.has_content? "Media"
    pdf_path = Rails.root.join('test', 'CSVs', 'test.pdf')
    page.execute_script %Q{$('#upload').show()}
    find(".upload_media form").attach_file("upload", pdf_path)
    assert page.has_content?("test.pdf"), "File should be in list"

    #Upload media to project
    visit '/projects/1'
    assert page.has_content? "Media"
    ods_path = Rails.root.join('test', 'CSVs', 'test.ods')
    page.execute_script %Q{$('#upload').show()}
    find(".upload_media form").attach_file("upload", ods_path)
    assert page.has_content?("test.ods"), "File should be in list"
    
    #Test for media objects helpers
    visit '/projects/1'
    all(".media_edit")[0].click
    assert page.has_content? "nerdboy.jpg"
    
    visit '/projects/1'
    all(".media_edit")[1].click
    assert page.has_content? "Warning"

    visit '/projects/1'
    all(".media_edit")[2].click
    assert page.has_content? "Warning"

    visit '/projects/1'
    all(".media_edit")[2].click
    assert page.has_content? "Warning"
    
  end

end