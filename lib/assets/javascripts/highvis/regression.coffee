###
 * Copyright (c) 2011, iSENSE Project. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer. Redistributions in binary
 * form must reproduce the above copyright notice, this list of conditions and
 * the following disclaimer in the documentation and/or other materials
 * provided with the distribution. Neither the name of the University of
 * Massachusetts Lowell nor the names of its contributors may be used to
 * endorse or promote products derived from this software without specific
 * prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 *
###

$ ->

    if namespace.controller is "visualizations" and namespace.action in ["displayVis", "embedVis", "show"]

      #Regression Types
      window.globals ?= {}
      globals.REGRESSION ?= {}
      
      globals.REGRESSION.FUNCS = []
      
      globals.REGRESSION.LINEAR = globals.REGRESSION.FUNCS.length
      globals.REGRESSION.FUNCS.push [
        (x, P) -> P[0] + (x*P[1]),
        (x, P) -> 1,
        (x, P) -> x]
      
      globals.REGRESSION.QUADRATIC = globals.REGRESSION.FUNCS.length
      globals.REGRESSION.FUNCS.push [
        (x, P) -> P[0] + (x*P[1]) + (x*x*P[2]),
        (x, P) -> 1,
        (x, P) -> x,
        (x, P) -> x*x]
      
      globals.REGRESSION.CUBIC = globals.REGRESSION.FUNCS.length
      globals.REGRESSION.FUNCS.push [
        (x, P) -> P[0] + (x*P[1]) + (x*x*P[2]) + (x*x*x*P[3]),
        (x, P) -> 1,
        (x, P) -> x,
        (x, P) -> x*x,
        (x, P) -> x*x*x]
      
      globals.REGRESSION.EXPONENTIAL = globals.REGRESSION.FUNCS.length
      globals.REGRESSION.FUNCS.push [
        (x, P) -> P[0] + Math.exp(P[1] * x + P[2]),
        (x, P) -> 1,
        (x, P) -> x * Math.exp(P[1] * x + P[2]),
        (x, P) -> Math.exp(P[1] * x + P[2])]
      
      globals.REGRESSION.LOGARITHMIC = globals.REGRESSION.FUNCS.length
      globals.REGRESSION.FUNCS.push [
        (x, P) -> P[0] + P[1] * Math.log(P[2] + x),
        (x, P) -> 1,
        (x, P) -> Math.log(x + P[2]),
        (x, P) -> P[1] / (P[2] + x)]
      
      globals.REGRESSION.NUM_POINTS = 100

      ###
      Calculates a regression and returns it as a highcharts series.
      ###
      globals.getRegression = (x_in, y_in, regression_type, x_bounds, series_name) ->
        #Initialize x array
        x_fin = []
        
        #Get the correct regression type
        switch Number(regression_type)
      
          when globals.REGRESSION.LINEAR
            #Make x_fin based on linear params
            for x_val in x_in
              x_fin.push([1, x_val])
        
          when globals.REGRESSION.QUADRATIC
            #Make x_fin based on quadratic params
            for x_val in x_in
              x_fin.push([1, x_val, Math.pow(x_val, 2)])

          when globals.REGRESSION.CUBIC
            #Make x_fin based on cubic params
            for x_val in x_in
              x_fin.push([1, x_val, Math.pow(x_val, 2), Math.pow(x_val, 3)])
        
          when globals.REGRESSION.LOGARITHMIC
            #Make x_fin based on logarithmic params
            for x_val in x_in
              x_fin.push([1, Math.log(x_val)])
        
        #Calculate the regression matrix, and finally the highcharts series object
        regression_matrix = calculateRegression(x_fin, y_in)
        result_series = generateHighchartsSeries(regression_matrix, regression_type, x_bounds, series_name)
        
        return result_series
        
      ###
      Calculates the regression according to the provided x and y matrices.
      ###
      calculateRegression = (x, y) ->
        #Return the resulting vector
        return numeric.dot(numeric.dot(numeric.inv(numeric.dot(numeric.transpose(x), x)), numeric.transpose(x)), y)
      
      ###
      Returns a series object to draw on the chart canvas.
      ###
      generateHighchartsSeries = (regression_matrix, regression_type, x_bounds, series_name) ->
  
        data = for i in [0..globals.REGRESSION.NUM_POINTS]
          x = (i / globals.REGRESSION.NUM_POINTS) * (x_bounds.dataMax - x_bounds.dataMin) + x_bounds.dataMin
          y =  calculateRegressionPoint(regression_matrix, x, regression_type)
          {x: x, y: y}
                   
        str = makeToolTip(regression_matrix, regression_type, series_name)
                   
        ret =
          name:
            group: series_name,
            regression:
              tooltip: str
          data: data,
          type: 'line'
          color: '#000',
          lineWidth: 2,
          showInLegend: false,
          marker: 
            symbol: 'blank'
          states:
            hover:
              lineWidth: 4

      ###
      Uses the regression matrix to calculate the y value given an x value.
      ###
      calculateRegressionPoint = (regression_matrix, x_val, regression_type) ->
      
        switch Number(regression_type)
        
          when globals.REGRESSION.LINEAR
            return regression_matrix[0] + regression_matrix[1] * x_val

          when globals.REGRESSION.QUADRATIC
            return regression_matrix[0] + regression_matrix[1] * x_val + regression_matrix[2] * Math.pow(x_val, 2)
          
          when globals.REGRESSION.CUBIC
            return regression_matrix[0] + regression_matrix[1] * x_val + regression_matrix[2] * Math.pow(x_val, 2) + regression_matrix[3] * Math.pow(x_val, 3)
          
          when globals.REGRESSION.LOGARITHMIC
            return regression_matrix[0] + regression_matrix[1] * Math.log(x_val)
            
      ###
      Returns tooltip description of the regression.
      ###
      makeToolTip = (regression_matrix, regression_type, series_name) ->

        #Get the correct regression type
        switch Number(regression_type)

          when globals.REGRESSION.LINEAR
          
            str = "<div style='width:100%;text-align:center;color:#000;'> #{series_name}</div><br>"
            str += "<strong>f(x) = #{roundToFourSigFigs(regression_matrix[1])}x + #{roundToFourSigFigs(regression_matrix[0])}</strong>"

            return str

          when globals.REGRESSION.QUADRATIC

            str = "<div style='width:100%;text-align:center;color:#000;'> #{series_name}</div><br>"
            str += "<strong>f(x) = #{roundToFourSigFigs(regression_matrix[2])}x&#178; + "
            str += "#{roundToFourSigFigs(regression_matrix[1])}x + #{roundToFourSigFigs(regression_matrix[0])}</strong>"

            return str

          when globals.REGRESSION.CUBIC
            
            str = "<div style='width:100%;text-align:center;color:#000;'> #{series_name}</div><br>"
            str += "<strong>f(x) = #{roundToFourSigFigs(regression_matrix[3])}x&#179; + #{roundToFourSigFigs(regression_matrix[2])}x&#178; + "
            str += "#{roundToFourSigFigs(regression_matrix[1])}x + #{roundToFourSigFigs(regression_matrix[0])}</strong>"

            return str

          when globals.REGRESSION.LOGARITHMIC

            str = "<div style='width:100%;text-align:center;color:#000;'> #{series_name}</div><br>"
            str += "<strong>f(x) = #{roundToFourSigFigs(regression_matrix[1])} ln(x) + #{roundToFourSigFigs(regression_matrix[0])}</strong>"

            return str
            
      ###
      Round the current float value to 4 significant figures.
      I keep this in a separate function because we weren't sure this was the best implemenation.
      ###
      roundToFourSigFigs = (float) ->
        return float.toPrecision(4) 
      
      window.TEST = {}
      jacobian = (func, xs, Ps) ->
        jac = []
        
        res = for x in xs
          for P,Pindex in Ps
            func[Pindex+1](x, Ps)
        console.log Ps
        console.log numeric.prettyPrint res
        res.filter (row) -> not isNaN(numeric.sum(row))
      
      NLLS_MAX_ITER = 1000
      NLLS_SHIFT_CUT_DOWN = 0.9
      NLLS_SHIFT_CUT_UP = 1.01
      NLLS_THRESH = 0.0001
      TEST.NLLS = (func, xs, ys, Ps) ->
      
        prevErr = Infinity
        shiftCut = 1
      
        for iter in [1..NLLS_MAX_ITER]
          res = TEST.iterateNLLS(func, xs, ys, Ps)
          console.log [iter, Ps, prevErr - res[1], numeric.sum(numeric.abs(numeric.div(res[0], Ps)))]
          
          if prevErr < res[1]
            console.log 'DIVERGENCE'
            shiftCut *= NLLS_SHIFT_CUT_DOWN
          else
            shiftCut = Math.min(shiftCut * NLLS_SHIFT_CUT_UP, 1)
            
          prevErr = res[1]
          
          Ps = numeric.add(Ps, numeric.mul(res[0], shiftCut))
        Ps
            
      TEST.iterateNLLS = (func, xs, ys, Ps) ->
        
        residuals = numeric.sub(ys, xs.map((x) -> func[0](x, Ps)))
        sqe = numeric.sum(residuals.map (x) -> x*x)
      
        jac = jacobian(func, xs, Ps)
        jacT = numeric.transpose jac
        
        # dP = (JT*J)^-1 * JT * r
        deltaPs = numeric.dot(numeric.dot(numeric.inv(numeric.dot(jacT, jac)), 
                                          jacT), 
                              residuals)
        console.log deltaPs
        [deltaPs, sqe]
      
      
        
      TEST.x = [1...30].map((x) -> x)
      TEST.y = TEST.x.map((xi) -> Math.log(xi)*2+5)
      
      TEST.NLLS(globals.REGRESSION.FUNCS[globals.REGRESSION.LOGARITHMIC], TEST.x, TEST.y, [1,1,1])
