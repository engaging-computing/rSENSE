module FieldsHelper
  def get_field_name(field)
    case field
    when 1
      'Timestamp'
    when 2
      'Number'
    when 3
      'Text'
    when 4
      'Latitude'
    when 5
      'Longitude'
    else
      'invalid input: try get_field_type(int)'
    end
  end

  def get_field_type(field)
    case field
    when 'Timestamp'
      1
    when 'Number'
      2
    when 'Text'
      3
    when 'Latitude'
      4
    when 'Longitude'
      5
    else
      'invalid input: try get_field_name(string)'
    end
  end
end
