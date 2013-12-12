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
    
  end

end