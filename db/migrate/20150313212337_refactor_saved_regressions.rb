class RefactorSavedRegressions < ActiveRecord::Migration
  def change
    say 'Refactoring saved regressions'
    vises = ['Scatter', 'Timeline']
    reformat(vises)
  end

  def get_func(type)
    case type
    when 0
      'return P[0] + (P[1] * x)'
    when 1
      'return P[0] + (P[1] * x) + (P[2] * x * x)'
    when 2
      'return P[0] + (x * P[1]) + (x * x * P[2]) + (x * x * x * P[3])'
    when 3
      'return P[0] + Math.exp(P[1] * x + P[2])'
    when 4
      'return P[0] + Math.log(P[1] * x + P[2])'
    end
  end

  def reformat(vis_types)
    Visualization.find_each do | v |
      for type in vis_types do
        globals = JSON.parse(v.globals)
        vis_params = globals[type]
        if !vis_params.nil? and vis_params.key? 'savedRegressions'
          regressions = []
          vis_params['savedRegressions'].each do |regression|
            keys = regression.keys
            if keys.include? 'fieldIndices' and keys.include? 'series'
              x_axis = regression['fieldIndices'][0]
              y_axis = regression['fieldIndices'][1]
              groups = regression['fieldIndices'][2]
              id = regression['series']['name']['id']
              dash_style = regression['series']['dashStyle']
              name = regression['series']['name']['group']
              r2 = regression['series']['name']['regression']['tooltip'].split('</strong> ')[3].gsub('e', 'E')
              type = regression['type']
              str_params = regression['series']['name']['regression']['tooltip'].split('<br>')[1].delete('^0-9 \.\-eE').split('  ').reverse
              params = str_params.select { |x| x != '' }
              params[params.length - 1] = params[params.length - 1][0...params[params.length - 1].length - 1]
              params = params.map { |x| x.gsub('e', 'E') }
              if regression['type'] == 4 or regression['type'] == 5
                copy = params.clone
                params[1] = copy[2]
                params[2] = copy[1]
              end
              parameters = params
              function = get_func(regression['type'])
              new_regression = {}
              new_regression['type'] = type
              new_regression['xAxis'] = x_axis
              new_regression['yAxis'] = y_axis
              new_regression['groups'] = groups
              new_regression['parameters'] = parameters
              new_regression['func'] = function
              new_regression['id'] = id
              new_regression['r2'] = r2
              new_regression['name'] = name
              new_regression['dashStyle'] = dash_style
              regressions.push new_regression
            else
              regressions.push regression
            end
          end
          puts "WATWATWAT"
          puts globals
          puts globals[type]
          puts "LOLOLOLOLOLOL"
          globals[type]['savedRegressions'] = regressions
          v.globals = globals.to_json
          v.save
        end
      end
    end
  end
end