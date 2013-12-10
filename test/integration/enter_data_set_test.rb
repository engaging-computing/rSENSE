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

 # test "enter a data set" do
 #   skip
 #
 #   login('kate', '12345')  
 #   click_on 'Projects'
 #   find("div.item div div", text: "Measuring Things").click
 #   click_on 'Manual Entry'
 #   find('#manualTable').all('.input-small')[0].native.send_keys "5"
 #   find('#manualTable').all('.input-small')[1].native.send_keys "6"
 #   click_on "Add Row"
 #   find('#manualTable').all('.input-small')[2].native.send_keys "22"
 #   find('#manualTable').all('.input-small')[3].native.send_keys "1"
 #   click_on 'Save'
 #   click_on 'Measuring Things'
 #   find('#dataset_list').click_on 'Visualize'
 #
 #   assert page.has_content?('Number_2'), "Has new field"
 #   assert page.has_content?('Histogram'), "On the Viz page"
 # end

 # test "upload a CSV file" do
 #   skip
 #
 #   login('kate', '12345')
 #
 #   click_on "Projects"
 #   
 #   find("div.item div div", text: "Dessert is Delicious").click
 #
 #   csv_path = Rails.root.join('test', 'CSVs', 'dessert.csv')
 #   
 #   page.execute_script %Q{$('#datafile_form').parent().show()}
 #   find("#datafile_form").attach_file("file", csv_path)
 #   page.execute_script %Q{$('#datafile_form').submit()}
 #   assert page.has_content?('Project Fields')
 #   click_on "Submit"
 #
 #   assert page.has_content?('Histogram'), "On the Viz page"
 # end
 
 # test "upload a mismatched CSV file" do
 #   skip
 #
 #   login('kate', '12345')
 #
 #   click_on "Projects"
 #   
 #   find("div.item div div", text: "Dessert is Delicious").click
 #
 #   csv_path = Rails.root.join('test', 'CSVs', 'dinner.csv')
 #
 #   page.execute_script %Q{$('#datafile_form').parent().show()}
 #   find("#datafile_form").attach_file("file", csv_path)
 #   page.execute_script %Q{$('#datafile_form').submit()}
 #
 #   assert page.has_content?('pizza'), "got match dialog"
 #   find('.field_match').all('select')[0].select("soup")
 #   find('.field_match').all('select')[1].select("pizza")
 #   find('.field_match').all('select')[2].select("wings")
 #   click_on "Submit"
 #   
 #   #assert page.has_content?('Histogram'), "On the Viz page"
 # end

 # test "import fields" do
 #   skip
 #
 #   login('kate', '12345')
 # 
 #   click_on "Projects"
 #   
 #   find("div.item div div", text: "Empty Project").click
 #
 #   click_on "Upload File"
 #   
 #   csv_path = Rails.root.join('test', 'CSVs', 'dinner.csv')
 #
 #   page.execute_script %Q{$('#template_file_form').parent().show()}
 #   find("#template_file_form").attach_file("file", csv_path)
 #   page.execute_script %Q{$('#template_file_form').submit()}
 #
 #   assert page.has_content?("Please select types for each field below."), 
 #     "got type dialog"
 #
 #   find('#fields_table').all('select')[0].select("Number")
 #   find('#fields_table').all('select')[1].select("Number")
 #   find('#fields_table').all('select')[2].select("Number")
 #   click_on "Submit"
 #
 #   assert page.has_content?('Description')
 # end
end
