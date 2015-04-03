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
        scatter_regressions = []
        scatter_params['savedRegressions'].each do |regression|
          xAxis = regression['fieldIndices'][0]
          yAxis = regression['fieldIndices'][1]
          groups = regression['fieldIndices'][2]
          id = regression['series']['name']['id']
          dashStyle = regression['series']['dashStyle']
          name = regression['series']['name']['group']
          r2 = regression['series']['name']['regression']['tooltip'].split('</strong> ')[3].to_f
          type = regression['type']
          wtf = regression['series']['name']['regression']['tooltip'].split('<br>')[1].delete('^0-9 e\.\-').split('  ').reverse
          params = wtf.select { |x| x != '' }
          params[params.length - 1] = sprintf("%.02f", params[params.length - 1])
          puts params
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
          #regression.clear
          newRegression = {}
          newRegression['type'] = type
          newRegression['xAxis'] = xAxis
          newRegression['yAxis'] = yAxis
          newRegression['groups'] = groups
          newRegression['parameters'] = parameters
          newRegression['func'] = function
          newRegression['id'] = id
          newRegression['r2'] = r2
          newRegression['name'] = name
          newRegression['dashStyle'] = dashStyle
          scatter_regressions.push newRegression
        end
        globals['Scatter']['savedRegressions'] = scatter_regressions 
      end

      if timeline_params.has_key? 'savedRegressions'
        timeline_regressions = []
        timeline_params['savedRegressions'].each do |regression|
          xAxis = regression['fieldIndices'][0]
          yAxis = regression['fieldIndices'][1]
          groups = regression['fieldIndices'][2]
          id = regression['series']['name']['id']
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
          #regression.clear
          newRegression = {}
          newRegression['type'] = type
          newRegression['xAxis'] = xAxis
          newRegression['yAxis'] = yAxis
          newRegression['groups'] = groups
          newRegression['parameters'] = parameters
          newRegression['func'] = function
          newRegression['id'] = id
          newRegression['r2'] = r2
          newRegression['name'] = name
          newRegression['dashStyle'] = dashStyle
          newRegression['tooltip'] = tooltip
          timeline_regressions.push newRegression
        end
        globals['Timeline']['savedRegressions'] = timeline_regressions
      end
      #puts globals.inspect
      v.globals = globals.to_json
      v.save
    end
  end
end
