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
      globals.getRegression = (xs, ys, type, x_bounds, series_name) ->
        #Initialize x array
        Ps = []
        func = globals.REGRESSION.FUNCS[type]
        
        #Make an initial Estimate
        switch type
      
          when globals.REGRESSION.LINEAR
            Ps = [1,1]
        
          when globals.REGRESSION.QUADRATIC
            Ps = [1,1,1]

          when globals.REGRESSION.CUBIC
            Ps = [1,1,1,1]
            
          when globals.REGRESSION.EXPONENTIAL
            Ps = [1,1,1]
        
          when globals.REGRESSION.LOGARITHMIC
            # We want to avoid starting with a guess that takes the log of a negative number
            Ps = [1,1,Math.min.apply(null, xs) + 1]
        
        #Calculate the regression matrix, and finally the highcharts series object
        Ps = NLLS(func, xs, ys, Ps)
        result_series = generateHighchartsSeries(Ps, type, x_bounds, series_name)
        
        return result_series
      
      ###
      Returns a series object to draw on the chart canvas.
      ###
      generateHighchartsSeries = (Ps, type, x_bounds, series_name) ->
      
        data = for i in [0..globals.REGRESSION.NUM_POINTS]
          x = (i / globals.REGRESSION.NUM_POINTS) * (x_bounds.dataMax - x_bounds.dataMin) + x_bounds.dataMin
          y =  calculateRegressionPoint(Ps, x, type)
          {x: x, y: y}
                   
        str = makeToolTip(Ps, type, series_name)
                   
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
      calculateRegressionPoint = (Ps, x, type) ->
        globals.REGRESSION.FUNCS[type][0](x, Ps)
            
      ###
      Returns tooltip description of the regression.
      ###
      makeToolTip = (Ps, type, series_name) ->
      
        #Format parameters for output
        Ps = Ps.map roundToFourSigFigs
        #Get the correct regression type
        switch type

          when globals.REGRESSION.LINEAR
            """
            <div class="regressionTooltip"> #{series_name} </div>
            <br>
            <strong>
              f(x) = #{Ps[1]}x + #{Ps[0]}
            </strong>
            """
          when globals.REGRESSION.QUADRATIC
            """
            <div class="regressionTooltip"> #{series_name} </div>
            <br>
            <strong>
              f(x) = #{Ps[2]}x^2 #{Ps[1]}x + #{Ps[0]}
            </strong>
            """
          when globals.REGRESSION.CUBIC
            """
            <div class="regressionTooltip"> #{series_name} </div>
            <br>
            <strong>
              f(x) = #{Ps[3]}x^3 + #{Ps[2]}x^2 + #{Ps[1]}x + #{Ps[0]}
            </strong>
            """
          when globals.REGRESSION.EXPONENTIAL
            """
            <div class="regressionTooltip"> #{series_name} </div>
            <br>
            <strong>
              f(x) = e^(#{P[1]}x + #{P[2]}) + #{Ps[0]}
            </strong>
            """

          when globals.REGRESSION.LOGARITHMIC
            """
            <div class="regressionTooltip"> #{series_name} </div>
            <br>
            <strong>
              f(x) = #{Ps[1]}ln(x + #{Ps[2]}) + #{Ps[0]}
            </strong>
            """
            
      ###
      Round the current float value to 4 significant figures.
      I keep this in a separate function because we weren't sure this was the best implemenation.
      ###
      roundToFourSigFigs = (float) ->
        return float.toPrecision(4) 
      
      jacobian = (func, xs, Ps) ->
        jac = []
        
        res = for x in xs
          for P,Pindex in Ps
            func[Pindex+1](x, Ps)
            
        res.filter (row) -> not isNaN(numeric.sum(row))
      
      NLLS_MAX_ITER = 300
      NLLS_SHIFT_CUT_DOWN = 0.9
      NLLS_SHIFT_CUT_UP = 1.1
      NLLS_THRESH = 0.0001
      NLLS = (func, xs, ys, Ps) ->
        console.log [xs, ys, Ps]
        prevErr = Infinity
        shiftCut = 1
      
        for iter in [1..NLLS_MAX_ITER]
          dPs = iterateNLLS(func, xs, ys, Ps)
          nextPs = numeric.add(Ps, numeric.mul(dPs, shiftCut))
          nextError = sqe(func, xs, ys, nextPs)
          console.log [iter, nextPs, nextError]
          
          if prevErr < nextError or isNaN(nextError)
            console.log 'DIVERGENCE - LINE SEARCH'
            lsIters = 0
            while prevErr < nextError or isNaN(nextError)
              lsIters += 1
              if lsIters > 500
                console.log "stuck!"
                throw new Error()
              console.log '.'
              shiftCut *= NLLS_SHIFT_CUT_DOWN
              nextPs = numeric.add(Ps, numeric.mul(dPs, shiftCut))
              nextError = sqe(func, xs, ys, nextPs)
            console.log 'PICKED: ' + String(shiftCut)
          else
            shiftCut = Math.min(shiftCut * NLLS_SHIFT_CUT_UP, 1)
            
          prevErr = nextError
          Ps = nextPs
        Ps
      
      sqe = (func, xs, ys, Ps) ->
        numeric.sum(numeric.sub(ys, xs.map((x) -> func[0](x, Ps))).map (x) -> x*x)
      
      iterateNLLS = (func, xs, ys, Ps) ->
        
        residuals = numeric.sub(ys, xs.map((x) -> func[0](x, Ps)))
        jac = jacobian(func, xs, Ps)
        jacT = numeric.transpose jac
        
        # dP = (JT*J)^-1 * JT * r
        deltaPs = numeric.dot(numeric.dot(numeric.inv(numeric.dot(jacT, jac)), 
                                          jacT), 
                              residuals)
        
        deltaPs
      
      
        
#       TEST.x = [-5...300].map((x) -> x)
#       TEST.y = TEST.x.map((xi) -> Math.log(xi + 10)*2+5)
#       
#       TEST.NLLS(globals.REGRESSION.FUNCS[globals.REGRESSION.LOGARITHMIC], TEST.x, TEST.y, [1,1,6])
