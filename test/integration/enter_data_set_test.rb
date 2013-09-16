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

  test "enter a data set" do
    login('kate', '12345')
    click_on 'Projects'
    click_on 'Measuring Things'
    find('#fields').click_on 'Edit'
    find('#fields').click_on 'Add Field'
    find('#fields').click_on 'Number'
    find('#fields').click_on 'Add Field'
    find('#fields').click_on 'Number'
    click_on 'Manual Entry'
    find('#manualTable').all('.input-small')[0].native.send_keys "5"
    find('#manualTable').all('.input-small')[1].native.send_keys "6"
    click_on "Add Row"
    find('#manualTable').all('.input-small')[2].native.send_keys "22"
    find('#manualTable').all('.input-small')[3].native.send_keys "1"
    click_on 'Save'
    click_on 'Measuring Things'
    find('#dataset_list').click_on 'Visualize'

    assert page.has_content?('Number_2'), "Has new field"
    assert page.has_content?('Histogram'), "On the Viz page"
  end

  test "upload a CSV file" do
    login('kate', '12345')

    click_on "Projects"
    click_on "Dessert is Delicious"

    csv_path = Rails.root.join('test', 'CSVs', 'dessert.csv')

    page.execute_script %Q{$('#csv_file_form').parent().show()}
    find("#csv_file_form").attach_file("csv", csv_path)
    page.execute_script %Q{$('#csv_file_form').submit()}

    click_on "Finish"

    assert page.has_content?('Histogram'), "On the Viz page"
  end
 
  test "upload a mismatched CSV file" do
    login('kate', '12345')

    click_on "Projects"
    click_on "Dessert is Delicious"

    csv_path = Rails.root.join('test', 'CSVs', 'dinner.csv')

    page.execute_script %Q{$('#csv_file_form').parent().show()}
    find("#csv_file_form").attach_file("csv", csv_path)
    page.execute_script %Q{$('#csv_file_form').submit()}

    assert page.has_content?('pizza'), "got match dialog"
    find('#match_table').all('select')[0].select("soup")
    find('#match_table').all('select')[1].select("pizza")
    find('#match_table').all('select')[2].select("wings")
    click_on "Finished"
    
    assert page.has_content?('enter a name'), "got rename dialog"
    click_on "Finish"
    
    assert page.has_content?('Histogram'), "On the Viz page"
  end

  test "import fields" do
    login('kate', '12345')

    click_on "Projects"
    click_on "Empty Project"

    click_on "Edit"
    
    csv_path = Rails.root.join('test', 'CSVs', 'dinner.csv')

    page.execute_script %Q{$('#template_file_form').parent().show()}
    find("#template_file_form").attach_file("csv", csv_path)
    page.execute_script %Q{$('#template_file_form').submit()}

    assert page.has_content?("telling us the type of each of your fields"), 
      "got type dialog"

    find('#template_match_table').all('select')[0].select("Number")
    find('#template_match_table').all('select')[1].select("Number")
    find('#template_match_table').all('select')[2].select("Number")
    click_on "Finished"

    assert page.has_content?('Description')
  end
end
