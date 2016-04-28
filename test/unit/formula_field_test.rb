require 'test_helper'

class FormulaFieldTest < ActiveSupport::TestCase
  # Tests that all default fields of a new field are correctly set

  # Declares a new field
  def setup
    # empty formula field
    @ffield = FormulaField.new

    # valid formula field
    @ffield_valid = FormulaField.new
    @ffield_valid.name = 'Valid FormulaField'
    @ffield_valid.field_type = 2
    @ffield_valid.project_id = projects(:formula_fields_test).id
    @ffield_valid.index = 5
    @ffield_valid.formula = 'FF3 - 2'

    # id of the formula fields test project
    @pid = projects(:formula_fields_test).id
  end

  # Passes if the non-recursive hash contains the right values
  test 'non-recursive hash is correct' do
    # assign a temporary refname and id so we have something to actually check
    @ffield_valid.id = 5000
    @ffield_valid.refname = 'ValidFormulaField'

    # convert the formula field to a hash and check its values
    h = @ffield_valid.to_hash recurse: false
    keys = [:id, :name, :type, :unit, :refname, :formula, :index].all? { |x| h.key? x }
    assert keys, 'Hash is missing one or more keys'
    assert h[:id] == 5000, 'ID in hash is not a number'
    assert h[:name] == 'Valid FormulaField', 'Wrong name in hash'
    assert h[:type] == 2, 'Wrong field type in hash'
    assert h[:unit] == '', 'Wrong unit in hash'
    assert h[:refname] == 'ValidFormulaField', 'Wrong refname in hash'
    assert h[:formula] == 'FF3 - 2', 'Wrong formula in hash'
    assert h[:index] == 5, 'Wrong index in hash'
  end

  # passes if the recursive hash contains the right values
  test 'recursive hash is correct' do
    # convert the formula field to a hash and check its values
    h = @ffield_valid.to_hash
    keys = [:id, :name, :type, :unit, :refname, :formula, :index, :project].all? { |x| h.key? x }
    assert keys, 'Hash is missing one or more keys'
    assert h[:project][:id] == @ffield_valid.project_id
    assert h[:project][:name] == 'Project for formula field testing'
  end

  # Passes if unit is an empty string
  test 'unit is an empty string' do
    assert_equal '', @ffield.unit, 'Expected field unit is not an empty string.'
  end

  # Passes if the formula field name is unique and considered valid
  test 'formula field name is unique' do
    assert @ffield_valid.valid?, 'Formula field should initially be valid'
    @ffield_valid.name = 'A unique name'
    assert @ffield_valid.valid?, 'Result should be valid'
  end

  # Passes if the formula field name is not unique amongst other formula fields
  test 'fail with non-unique formula field name' do
    assert @ffield_valid.valid?, 'Formula field should initially be valid'
    @ffield_valid.name = 'FF1'
    assert !@ffield_valid.valid?, 'Result should not be valid'
    errs = @ffield_valid.errors.full_messages
    assert errs.length == 1, 'Should only have one validation error'
    assert errs[0] == 'Name has already been taken', 'Wrong error message'
  end

  # Passes if the formula field name is not unique amongst fields
  test 'fail with non-unique field name' do
    assert @ffield_valid.valid?, 'Formula field should initially be valid'
    @ffield_valid.name = 'No Formula 1'
    assert !@ffield_valid.valid?, 'Result should not be valid'
    errs = @ffield_valid.errors.full_messages
    assert errs.length == 1, 'Should only have one validation error'
    assert errs[0] == 'No Formula 1 has the same name as another field', 'Wrong error message'
  end

  # Try to choose an appropriate refname with no collisions
  test 'get easy refname' do
    ff = FormulaField.new
    ff.project_id = @pid
    ff.name = 'word Word ++ Word'
    ff.choose_refname
    assert_equal 'WordWordWord', ff.refname
  end

  # Test out refname choosing with goofy casing
  test 'get tricky refname' do
    ff = FormulaField.new
    ff.project_id = @pid
    ff.name = 'ABC DEF GHI'
    ff.choose_refname
    assert_equal 'AbcDefGhi', ff.refname
  end

  # Try to choose an appropriate refname with a field name collision
  test 'get refname with field collision' do
    ff = FormulaField.new
    ff.project_id = @pid
    ff.name = 'N-F-2'
    ff.choose_refname
    assert_equal 'NF2_1', ff.refname
  end

  # Try to choose an appropriate refname with a formula field name collision
  test 'get refname with formula field collision' do
    ff = FormulaField.new
    ff.project_id = @pid
    ff.name = 'F-F-2'
    ff.choose_refname
    assert_equal 'FF2_1', ff.refname
  end

  # Setting a valid field type
  test 'set field type to something valid' do
    assert @ffield_valid.valid?, 'Formula field should initially be valid'
    @ffield_valid.field_type = 2
    assert @ffield_valid.valid?, 'Formula field should still be valid'
    @ffield_valid.field_type = 3
    assert @ffield_valid.valid?, 'Formula field should still be valid'
  end

  # Setting an invalid field type
  test 'set field type to something invalid' do
    assert @ffield_valid.valid?, 'Formula field should initially be valid'
    @ffield_valid.field_type = 1
    assert !@ffield_valid.valid?, 'Formula field should not allow timestamp type'
    errs = @ffield_valid.errors.full_messages
    assert errs.length == 1, 'Should only have one validation error'
    assert errs[0] == 'Field type must be either 2 (number) or 3 (text)', 'Wrong error message'
    @ffield_valid.field_type = 4
    assert !@ffield_valid.valid?, 'Formula field should not allow latitude type'
    @ffield_valid.field_type = 5
    assert !@ffield_valid.valid?, 'Formula field should not allow longitude type'
  end

  # Make sure that we're requiring a valid, existing project for each formula field
  test 'require valid project id' do
    assert @ffield_valid.valid?, 'Formula field should initially be valid'
    @ffield_valid.project_id = 'a tiny man trying to make his way in a world for much larger people'
    assert !@ffield_valid.valid?, 'Result should not be valid'
    errs = @ffield_valid.errors.full_messages
    assert errs.length == 1, 'Should only have one validation error'
    assert errs[0] == 'Project not found', 'Wrong error message'
  end

  # Verify that try_execute works on valid data
  test 'pass try executing' do
    formulas = [
      ['Number_3', [:number], 'Number_1 ^ Number_2 + array_length(Text_1)', 'Number_3'],
      ['Number_4', [:number], 'Number_3 + prev(Number_4, 0)', 'Number_4'],
      ['Text_3', [:text], '"dog" * -2.3', 'Text_3'],
      ['Text_4', [:text], '"Mr." + Text_1 + Text_2 + Text_3', 'Text_4']
    ]

    fields = [
      ['Timestamp', [:timestamp]],
      ['Latitude', [:latitude]],
      ['Longitude', [:longitude]],
      ['Number_1', [:number]],
      ['Number_2', [:number]],
      ['Text_1', [:text]],
      ['Text_2', [:text]]
    ]

    errs = FormulaField.try_execute(formulas, fields)
    assert errs.length == 0, 'Should not have any errors'
  end

  # Verify that try_execute fails on invalid data
  test 'fail try executing' do
    formulas = [
      ['TooEarly', [:text], 'WrongType1', 'TooEarly'],
      ['WrongType1', [:number], '"a"', 'WrongType1'],
      ['WrongType2', [:text], '1', 'WrongType2'],
      ['WrongType3', [:number], 'array_length', 'WrongType3'],
      ['WrongType4', [:number], 'true', 'WrongType4'],
      ['WrongType5', [:number], 'location(latitude(1), longitude(1))', 'WrongType5'],
      ['UnknownIdent', [:number], 'muggles()', 'UnknownIdent'],
      ['LexerError', [:number], '$', 'LexerError'],
      ['ParseError', [:number], '(1))', 'ParseError'],
      ['EvalError', [:text], 'true + 1', 'EvalError']
    ]

    fields = [
      ['Timestamp', [:timestamp]],
      ['Latitude', [:latitude]],
      ['Longitude', [:longitude]],
      ['Number_1', [:number]],
      ['Number_2', [:number]],
      ['Text_1', [:text]],
      ['Text_2', [:text]]
    ]

    errs = FormulaField.try_execute(formulas, fields)
    assert errs.length == 10, 'Should have 10 errors'
    assert errs[0] == 'With formula field TooEarly: Unknown identifier WrongType1'
    assert errs[1] == 'With formula field WrongType1: returned type text, expected type [:number]'
    assert errs[2] == 'With formula field WrongType2: returned type number, expected type [:text]'
    assert errs[3] == 'With formula field WrongType3: returned type function, expected type [:number]'
    assert errs[4] == 'With formula field WrongType4: returned type bool, expected type [:number]'
    assert errs[5] == 'With formula field WrongType5: In location: expected (longitude,latitude), given (latitude,longitude)'
    assert errs[6] == 'With formula field UnknownIdent: Unknown identifier muggles'
    assert errs[7] == 'With formula field LexerError: Unable to match string with any of the given rules: $'
    assert errs[8] == 'With formula field ParseError: Unexpected token CLOSEP at 1:4'
    assert errs[9] == 'With formula field EvalError: In +: expected (number,number), given (bool,number)'
  end
end
