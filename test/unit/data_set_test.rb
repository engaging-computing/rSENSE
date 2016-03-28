require 'test_helper'

class DataSetTest < ActiveSupport::TestCase
  # Tests that all default fields of a new data set are correctly set

  # Declares a new data set
  def setup
    @data_set = DataSet.new
  end

  # ---------------------------------------------------
  # Testing with fixtures

  test 'data set title' do
    assert_equal 'Sample Title', data_sets(:one).title
  end

  test 'user_id' do
    assert_equal users(:kate).id, data_sets(:one).user_id
  end

  test 'project_id' do
    assert_equal projects(:one).id, data_sets(:one).project_id
  end

  test 'calculate formula data with valid formulas' do
    ff1 = formula_fields(:calculation_ff_1)
    ff2 = formula_fields(:calculation_ff_2)

    # test that the first data set has the correct data
    dset1 = data_sets(:calculation_data_1)
    dset1.recalculate
    assert_similar_arrays dset1.formula_data, [
      { "#{ff1.id}" =>  '4.5', "#{ff2.id}" => '20.249999999999993' },
      { "#{ff1.id}" =>  '6.0', "#{ff2.id}" => '20.249999999999993' },
      { "#{ff1.id}" =>  '7.5', "#{ff2.id}" => '20.249999999999993' },
      { "#{ff1.id}" =>  '9.0', "#{ff2.id}" => '20.249999999999993' },
      { "#{ff1.id}" => '10.5', "#{ff2.id}" => '20.249999999999993' }
    ]

    # test that the second data set has the correct data
    dset2 = data_sets(:calculation_data_2)
    dset2.recalculate
    assert_similar_arrays dset2.formula_data, [
      { "#{ff1.id}" => '15.4', "#{ff2.id}" => '71738.26559999997' },
      { "#{ff1.id}" => '18.4', "#{ff2.id}" => '71738.26559999997' },
      { "#{ff1.id}" => '24.4', "#{ff2.id}" => '71738.26559999997' },
      { "#{ff1.id}" => '36.4', "#{ff2.id}" => '71738.26559999997' },
      { "#{ff1.id}" => '60.4', "#{ff2.id}" => '71738.26559999997' }
    ]

    # test that the second data set has the correct data
    dset3 = data_sets(:calculation_data_3)
    dset3.recalculate
    assert_similar_arrays dset3.formula_data, [
      { "#{ff1.id}" =>  '4.0', "#{ff2.id}" => '2916.0000000000005' },
      { "#{ff1.id}" => '19.0', "#{ff2.id}" => '2916.0000000000005' },
      { "#{ff1.id}" =>  '4.0', "#{ff2.id}" => '2916.0000000000005' },
      { "#{ff1.id}" => '19.0', "#{ff2.id}" => '2916.0000000000005' },
      { "#{ff1.id}" =>  '4.0', "#{ff2.id}" => '2916.0000000000005' }
    ]
  end

  test 'calculate formula data with an invalid formulas' do
    ff1 = formula_fields(:calculation_ff_3)
    ff2 = formula_fields(:calculation_ff_4)
    ff3 = formula_fields(:calculation_ff_5)

    # test that the first data set has the correct data
    # don't bother checking the rest, they'll be about the same
    dset1 = data_sets(:calculation_data_4)
    dset1.recalculate
    assert_similar_arrays dset1.formula_data, [
      { "#{ff1.id}" => '1.0', "#{ff2.id}" => '', "#{ff3.id}" => '1.0' },
      { "#{ff1.id}" => '2.0', "#{ff2.id}" => '', "#{ff3.id}" => '2.0' },
      { "#{ff1.id}" => '3.0', "#{ff2.id}" => '', "#{ff3.id}" => '3.0' },
      { "#{ff1.id}" => '4.0', "#{ff2.id}" => '', "#{ff3.id}" => '4.0' },
      { "#{ff1.id}" => '5.0', "#{ff2.id}" => '', "#{ff3.id}" => '5.0' }
    ]
  end
end
