module DataSetsHelper
  def data_set_edit_helper(field, can_edit = false, make_link = true, url = '#')
    render 'shared/edit_info', type: 'data_set', field: field, value: @data_set[field],
      row_id: @data_set.id, can_edit: can_edit, make_link: make_link, href: url
  end

  def format_slickgrid(fields, data_set)
    cols, data = [fields, data_set]
    cols, data = format_slickgrid_merge cols, data
    cols, data = format_slickgrid_units cols, data
    cols, data = format_slickgrid_populate cols, data
    cols, data = format_slickgrid_editors cols, data
    cols, data = format_slickgrid_json cols, data
    [cols, data]
  end

  def format_slickgrid_merge(cols, data)
    cols_merge = cols.map do |x|
      restrictions = x.restrictions.nil? ? '""' : x.restrictions
      units = x.unit.nil? ? '' : x.unit

      {
        field_type: x.field_type,
        id: "#{x.id}",
        name: x.name,
        restrictions: restrictions,
        units: units
      }
    end

    coords = cols_merge.select { |x| x[:field_type] == 4 or x[:field_type] == 5 }

    if coords.empty?
      [cols_merge, data]
    else
      lat = coords.select { |x| x[:field_type] == 4 }[0]
      lon = coords.select { |x| x[:field_type] == 5 }[0]

      # merge longitude column into latitude column
      cols_merge.select! { |x| x[:id] != lat[:id] and x[:id] != lon[:id] }
      cols_merge << {
        field_type: 4,
        id: "#{lat[:id]}-#{lon[:id]}",
        name: "#{lat[:name]}, #{lon[:name]}",
        restrictions: '""',
        units: ''
      }

      # copy longitude data into latitude data
      lat_sym = lat[:id]
      lon_sym = lon[:id]
      data.map! do |x|
        if x[lat_sym] == '' and x[lon_sym] == ''
          x["#{lat_sym}-#{lon_sym}"] = ''
        else
          x["#{lat_sym}-#{lon_sym}"] = "#{x[lat_sym]}, #{x[lon_sym]}"
        end

        x.delete lat_sym
        x.delete lon_sym
        x
      end

      [cols_merge, data]
    end
  end

  def format_slickgrid_units(cols, data)
    cols.map! do |x|
      x[:name] =
        if x[:units] == ''
          "#{x[:name]}<br>"
        else
          "#{x[:name]}<br>(#{x[:units]})"
        end
      x
    end

    [cols, data]
  end

  def format_slickgrid_populate(cols, data)
    if data != []
      [cols, data]
    else
      data = { id: 0 }
      cols.each { |x| data[x[:id]] = '' }
      [cols, [data]]
    end
  end

  def format_slickgrid_editors(cols, data)
    cols_editors = cols.map.with_index do |x, i|
      editor =
        case x[:field_type]
        when 1
          'TimestampEditor'
        when 2
          'NumberEditor'
        when 3
          'TextEditor'
        when 4
          'LocationEditor'
        else
          'Slick.Editors.Text'
        end

      field = "slickgrid-#{x[:id]}"

      {
        id: "\"#{field}\"",
        name: "\"#{x[:name]}\"",
        field: "\"#{x[:id]}\"",
        editor: editor,
        restrictions: "#{x[:restrictions]}",
        sortable: 'false'
      }
    end

    [cols_editors, data.to_json]
  end

  def format_slickgrid_json(cols, data)
    cols_json = cols.map do |x|
      strs = []
      x.each do |key, value|
        strs << "\"#{key}\":#{value}"
      end
      "{#{strs.join ','}}"
    end.join ','

    ["[#{cols_json}]", data]
  end
end
