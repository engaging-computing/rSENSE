class RefactorSavedRegressions < ActiveRecord::Migration
  def change
    say 'Refactoring saved regressions'
    Visualization.find_each do | v |
      #puts v.inspect
      #
      globals = JSON.parse(v.globals)
      scatter_params = globals['Scatter']
      timeline_params = globals['Timeline']
      if scatter_params.has_key? 'savedRegressions'
        scatter_params['savedRegressions'].each do |regression|
          xAxis = regression['fieldIndices'][0]
          yAxis = regression['fieldIndices'][1]
          groups = regression['fieldIndices'][2]
          id = regression['series']['name']
          dashStyle = regression['series']['dashStyle']
          name = regression['series']['name']['group']
          r2 = regression['series']['name']['regression']['tooltip'].split('</strong> ')[3].to_f
          type = regression['type']
          wtf = regression['series']['name']['regression']['tooltip'].split('<br>')[1].delete('^0-9 \.\-').split('  ').reverse
          params = wtf.select { |x| x != '' }
          params[params.length - 1] = sprintf("%.02f", params[params.length - 1])
          params.map! { |x| x.to_f }
          
          if regression['type'] == 4 or regression['type'] == 5
            copy = params.clone
            params[1] = copy[2]
            params[2] = copy[1]
          end
          parameters = params
          function = nil
          case regression['type']
          when 0
            function = 'return P[0] + (P[1] * x)'
          when 1
            function = 'return P[0] + (P[1] * x) + (P[2] * x * x)'
          when 2
            function = 'return P[0] + (x * P[1]) + (x * x * P[2]) + (x * x * x * P[3])'
          when 3
            function = 'return P[0] + Math.exp(P[1] * x + P[2])'
          when 4
            function = 'return P[0] + Math.log(P[1] * x + P[2])'
          end
          regression.clear
          regreesion['type'] = type
          regression['xAxis'] = xAxis
          regression['yAxis'] = yAxis
          regression['groups'] = groups
          regression['parameters'] = parameters
          regression['func'] = function
          regression['id'] = id
          regression['r2'] = r2
          regression['name'] = name
          regression['dashStyle'] = dashStyle
        end
      end

      if timeline_params.has_key? 'savedRegressions'
        timeline_params['savedRegressions'].each do |regression|
          xAxis = regression['fieldIndices'][0]
          yAxis = regression['fieldIndices'][1]
          groups = regression['fieldIndices'][2]
          id = regression['series']['name']
          dashStyle = regression['series']['dashStyle']
          name = regression['series']['name']['group']
          r2 = regression['series']['name']['regression']['tooltip'].split('</strong> ')[3].to_f
          type = regression['type']
          tooltip = regression['series']['name']['regression']['tooltip']
          wtf = regression['series']['name']['regression']['tooltip'].split('<br>')[1].delete('^0-9 \.\-').split('  ').reverse
          params = wtf.select { |x| x != '' }
          params[params.length - 1] = sprintf("%.02f", params[params.length - 1])
          params.map! { |x| x.to_f }
          
          if regression['type'] == 4 or regression['type'] == 5
            copy = params.clone
            params[1] = copy[2]
            params[2] = copy[1]
          end
          parameters = params
          function = nil
          case regression['type']
          when 0
            function = 'return P[0] + (P[1] * x)'
          when 1
            function = 'return P[0] + (P[1] * x) + (P[2] * x * x)'
          when 2
            function = 'return P[0] + (x * P[1]) + (x * x * P[2]) + (x * x * x * P[3])'
          when 3
            function = 'return P[0] + Math.exp(P[1] * x + P[2])'
          when 4
            function = 'return P[0] + Math.log(P[1] * x + P[2])'
          end
          regression.clear
          regression['type'] = type
          regression['xAxis'] = xAxis
          regression['yAxis'] = yAxis
          regression['groups'] = groups
          regression['parameters'] = parameters
          regression['func'] = function
          regression['id'] = id
          regression['r2'] = r2
          regression['name'] = name
          regression['dashStyle'] = dashStyle
          regression['tooltip'] = tooltip
        end
      end
      #puts globals.inspect
    end
  end
end
