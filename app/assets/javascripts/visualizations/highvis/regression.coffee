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
  if namespace.controller is "visualizations" and
  namespace.action in ["displayVis", "embedVis", "show"]

    # Regression Types
    # Regression functions are listed with their partial derrivitives, eg.
    #
    # [f(x,Ps), f(x,Ps) dPs[0], f(x,Ps) dPs[1] ,... , f(x,Ps) dPs[dPs.length]]
    window.globals ?= {}
    globals.REGRESSION ?= {}

    globals.REGRESSION.FUNCS = []
    globals.REGRESSION.DENORM_FUNCS = []

    globals.REGRESSION.LINEAR = globals.REGRESSION.FUNCS.length
    globals.REGRESSION.FUNCS.push [
      (x, P) -> P[0] + (x * P[1]),
      (x, P) -> 1,
      (x, P) -> x]

    globals.REGRESSION.QUADRATIC = globals.REGRESSION.FUNCS.length
    globals.REGRESSION.FUNCS.push [
      (x, P) -> P[0] + (x * P[1]) + (x * x * P[2])
      (x, P) -> 1
      (x, P) -> x
      (x, P) -> x * x]

    globals.REGRESSION.CUBIC = globals.REGRESSION.FUNCS.length
    globals.REGRESSION.FUNCS.push [
      (x, P) -> P[0] + (x * P[1]) + (x * x * P[2]) + (x * x * x * P[3]),
      (x, P) -> 1,
      (x, P) -> x,
      (x, P) -> x * x,
      (x, P) -> x * x * x]

    globals.REGRESSION.EXPONENTIAL = globals.REGRESSION.FUNCS.length
    globals.REGRESSION.FUNCS.push [
      (x, P) -> P[0] + Math.exp(P[1] * x + P[2]),
      (x, P) -> 1,
      (x, P) -> x * Math.exp(P[1] * x + P[2]),
      (x, P) -> Math.exp(P[1] * x + P[2])]

    globals.REGRESSION.LOGARITHMIC = globals.REGRESSION.FUNCS.length
    globals.REGRESSION.FUNCS.push [
      (x, P) -> P[0] + Math.log(P[1] * x + P[2]),
      (x, P) -> 1,
      (x, P) -> x / (P[1] * x + P[2]),
      (x, P) -> 1 / (P[1] * x + P[2])]

    globals.REGRESSION.SYMBOLIC = globals.REGRESSION.FUNCS.length

    globals.REGRESSION.NUM_POINTS = 200

    ###
    Calculates a regression and returns it as a highcharts series.
    ###
    globals.getRegression = (points, type, xBounds, seriesName, dashStyle, id) ->
      Ps = []
      if type isnt globals.REGRESSION.SYMBOLIC
        func = globals.REGRESSION.FUNCS[type]
        [xs, ys] = [(point.x for point in points), (point.y for point in points)]
        # Make an initial Estimate
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

        # Get the new Ps
        [Ps, R2] = NLLS(func, normalizeData(xs, type), ys, Ps)
        generateHighchartsSeries(func[0], Ps, R2, type, xBounds, seriesName, dashStyle, id)
      else
        func = optimizedSymbolicRegression(points)
        R2 = calculateR2(func, points)
        generateHighchartsSeries(func, null, R2, type, xBounds, seriesName, dashStyle, id)

    ###
    Returns a series object to draw on the chart canvas.
    ###
    generateHighchartsSeries = (func, Ps, R2, type, xBounds,
      seriesName, dashStyle, id, tooltip = null, normalized = true) ->
      data = for i in [0...globals.REGRESSION.NUM_POINTS]
        xv = (i / globals.REGRESSION.NUM_POINTS)
        yv = null
        if not normalized
          if func.length is 2
            yv = func(xv * (xBounds[1] - xBounds[0]) + xBounds[0], Ps)
          else
            yv = func(xv * (xBounds[1] - xBounds[0]) + xBounds[0])
        else if type is globals.REGRESSION.LOGARITHMIC
          yv = func(xv * (xBounds[1] - xBounds[0]) + xBounds[0], Ps)
        else if type isnt globals.REGRESSION.SYMBOLIC
          yv = func(xv + 1, Ps)
        else
          func.evaluate(xv * (xBounds[1] - xBounds[0]) + xBounds[0])
        {x: xv * (xBounds[1] - xBounds[0]) + xBounds[0], y: yv}
      if normalized and Ps isnt null
        Ps = visSpaceParameters(Ps, xBounds, type)

      tt =
        if tooltip? then tooltip
        else makeToolTip(Ps, R2, type, seriesName, func)

      retSeries =
        name:
          id: 'hs-' + id
          group: seriesName
          regression:
            tooltip: tt
        data: data
        type: 'line'
        color: '#000'
        lineWidth: 2
        dashStyle: dashStyle
        showInLegend: false
        marker:
          symbol: 'blank'
        states:
          hover:
            lineWidth: 4

      func = if func.length? and typeof(func) isnt 'function' then func[0] else func
      return [func, Ps, R2, retSeries, tt]

    ###
    # Uses the regression matrix to calculate the y value given an x value.
    ###
    calculateRegressionPoint = (Ps, x, type) ->
      globals.REGRESSION.FUNCS[type][0](x, Ps)

    ###
    # Linear Equation solver creates trivial roundoff error for parameters
    # that are equal to zero.
    ###
    roundOffError = (p) ->
      if Math.abs(p) < Math.sqrt numeric.epsilon then 0 else p

    ###
    Returns tooltip description of the regression.
    ###
    makeToolTip = (Ps, R2, type, seriesName, func) ->
      # Format parameters for output
      Ps = if Ps isnt null then Ps.map(roundToFourSigFigs).map(roundOffError)

      ret = switch type

        when globals.REGRESSION.LINEAR
          """
          <div class="regressionTooltip"> #{seriesName} </div>
          <br>
          <strong>
            f(x) = #{Ps[1]}x + #{Ps[0]}
          </strong>
          """

        when globals.REGRESSION.QUADRATIC
          """
          <div class="regressionTooltip"> #{seriesName} </div>
          <br>
          <strong>
            f(x) = #{Ps[2]}x<sup>2</sup> + #{Ps[1]}x + #{Ps[0]}
          </strong>
          """

        when globals.REGRESSION.CUBIC
          """
          <div class="regressionTooltip"> #{seriesName} </div>
          <br>
          <strong>
            f(x) = #{Ps[3]}x<sup>3</sup> + #{Ps[2]}x<sup>2</sup> + #{Ps[1]}x + #{Ps[0]}
          </strong>
          """

        when globals.REGRESSION.EXPONENTIAL
          """
          <div class="regressionTooltip"> #{seriesName} </div>
          <br>
          <strong>
            f(x) = e<sup>(#{Ps[1]}x + #{Ps[2]})</sup> + #{Ps[0]}
          </strong>
          """

        when globals.REGRESSION.LOGARITHMIC
          """
          <div class="regressionTooltip"> #{seriesName} </div>
          <br>
          <strong>
            f(x) = ln(#{Ps[1]}x + #{Ps[2]}) + #{Ps[0]}
          </strong>
          """

        else
          tooltip = """
          <div class="regressionTooltip"> #{seriesName} </div>
          <br>
          <strong>
            f(x) =
          """
          tooltip += BinaryTree.stringify(func.tree)
          tooltip += """
          </strong>
          """
      ret += """
      <br>
      <strong> R <sup>2</sup> = </strong> #{roundToFourSigFigs R2}
      """

    ###
    Round the current float value to 4 significant figures.
    I keep this in a separate function because we weren't sure this was the best implemenation.
    ###
    window.roundToFourSigFigs = (float) ->
      return float.toPrecision(4)

    ###
    Calculates the jacobian of the given x over the given parameters using
    a set of partial derrivitive functions as given at the top of this file.
    ###
    jacobian = (func, xs, Ps) ->
      jac = []

      res = for x in xs
        for P,Pindex in Ps
          func[Pindex + 1](x, Ps)

    ###
    Newton-Gauss non-linear least squares regression using shift-cutting

      MAX_ITER       - Maximum number of iterations before termination.
      SHIFT_CUT_DOWN - Shift cut fraction used when divergence occurs.
      SHIFT_CUT_UP   - Fraction used to increase shift size if no divergence occurs.
      THRESH         - Threshold of error change, terminates algorithm early if met.

      func - Array of function, function to be fit followed by its partial derrivitives.
      xs   - Array of x values
      ys   - Array of y values (ground truth)
      Ps   - Array of initial parameter estimates.
    ###
    NLLS_MAX_ITER = 1000
    NLLS_SHIFT_CUT_DOWN = 0.9
    NLLS_SHIFT_CUT_UP = 1.1
    NLLS_THRESH = 1e-10
    NLLS = (func, xs, ys, Ps) ->
      prevErr = Infinity
      shiftCut = 1
      for iter in [1..NLLS_MAX_ITER]
        # Iterate
        dPs = iterateNLLS(func, xs, ys, Ps)
        nextPs = numeric.add(Ps, numeric.mul(dPs, shiftCut))
        nextErr = sqe(func, xs, ys, nextPs)

        if prevErr < nextErr or isNaN(nextErr)
          # If the iteration has diverged (or failed), line search a shift cut
          lsIters = 0
          while prevErr < nextErr or isNaN(nextErr)
            # If we line search too long and can't find a valid value
            # Then we declare the regression to have failed and throw.
            lsIters += 1
            if lsIters > 500
              throw new Error()

            shiftCut *= NLLS_SHIFT_CUT_DOWN
            nextPs = numeric.add(Ps, numeric.mul(dPs, shiftCut))
            nextErr = sqe(func, xs, ys, nextPs)
        else
          # Otherwise, accelerate towards optimum
          shiftCut = Math.min(shiftCut * NLLS_SHIFT_CUT_UP, 1)

        Ps = nextPs

        # Break early if the error ratio has dropped below the threshold
        if (prevErr - nextErr) / prevErr < NLLS_THRESH
          break

        prevErr = nextErr

      # Calculate R^2 value
      mean = numeric.sum(ys) / ys.length
      SStot = numeric.sum(ys.map((y) -> (y - mean) * (y - mean)))
      R2 = (1 - prevErr / SStot)

      [Ps, R2]

    ###
    Inner loop of Newton-gauss method
    ###
    iterateNLLS = (func, xs, ys, Ps) ->
      residuals = numeric.sub(ys, xs.map((x) -> func[0](x, Ps)))
      jac = jacobian(func, xs, Ps)
      jacT = numeric.transpose jac

      # dP = (JT*J)^-1 * JT * r
      deltaPs = numeric.dot(numeric.dot(numeric.inv(numeric.dot(jacT, jac)),
        jacT),
        residuals)

    ###
    Calculates the current squared error for the given function, parameters and ground truth.
    ###
    sqe = (func, xs, ys, Ps) ->
      numeric.sum(numeric.sub(ys, xs.map((x) -> func[0](x, Ps))).map (x) -> x * x)

    # Calculate the average
    calculateMean = (points) ->
      mean = 0
      for point in points
        mean += point / points.length
      mean

    # Normalize
    normalizeData = (points, type) ->
      max = Math.max.apply(null, points)
      min = Math.min.apply(null, points)
      ret =
        if type in [globals.REGRESSION.LOGARITHMIC, globals.REGRESSION.EXPONENTIAL]
          points
        else
          points.map((y) -> ((y - min) / (max - min)) + 1)

    ###
    # Map the parameters of the normalized features to the visualization space
    # (done by Gauss-Jordan elimination on a system of linear equations)
    ###
    visSpaceParameters = (Ps, xBounds, type) ->
      [coeffMatrix, solutionVector, newPs] = [[], [], []]
      [max, min] = [xBounds[1], xBounds[0]]
      projection = 2 * (max - min) + min

      if type in [globals.REGRESSION.LOGARITHMIC, globals.REGRESSION.EXPONENTIAL]
        return Ps

      switch type
        when globals.REGRESSION.LINEAR
          coeffMatrix = [
            [1, min],
            [1, max]
          ]
          solutionVector = [
            globals.REGRESSION.FUNCS[globals.REGRESSION.LINEAR][0](1, Ps),
            globals.REGRESSION.FUNCS[globals.REGRESSION.LINEAR][0](2, Ps)
          ]
          newPs = numeric.solve(coeffMatrix, solutionVector)

        when globals.REGRESSION.QUADRATIC
          coeffMatrix = [
            [1, min, min * min],
            [1, (max + min) / 2, ((max + min) / 2) * ((max + min) / 2)],
            [1, max, max * max]
          ]
          solutionVector = [
            globals.REGRESSION.FUNCS[globals.REGRESSION.QUADRATIC][0](1, Ps),
            globals.REGRESSION.FUNCS[globals.REGRESSION.QUADRATIC][0](1.5, Ps),
            globals.REGRESSION.FUNCS[globals.REGRESSION.QUADRATIC][0](2, Ps)
          ]
          newPs = numeric.solve(coeffMatrix, solutionVector)

        when globals.REGRESSION.CUBIC
          coeffMatrix = [
            [1, min, min * min, min * min * min],
            [1, (max + min) / 2, Math.pow((max + min) / 2, 2), Math.pow((max + min) / 2, 3)],
            [1, max, max * max, max * max * max],
            [1, projection, projection * projection, projection * projection * projection]
          ]
          solutionVector = [
            globals.REGRESSION.FUNCS[globals.REGRESSION.CUBIC][0](1, Ps),
            globals.REGRESSION.FUNCS[globals.REGRESSION.CUBIC][0](1.5, Ps),
            globals.REGRESSION.FUNCS[globals.REGRESSION.CUBIC][0](2, Ps),
            globals.REGRESSION.FUNCS[globals.REGRESSION.CUBIC][0](3, Ps)
          ]
          newPs = numeric.solve(coeffMatrix, solutionVector)

        when globals.REGRESSION.EXPONENTIAL
          coeffMatrix = [
            [Math.exp(min), 1],
            [Math.exp(max), 1]
          ]
          solutionVector = [
            Math.log(globals.REGRESSION.FUNCS[globals.REGRESSION.EXPONENTIAL][0](1, Ps) - Ps[0]),
            Math.log(globals.REGRESSION.FUNCS[globals.REGRESSION.EXPONENTIAL][0](2, Ps) - Ps[0])
          ]
          solutionVector.push Math.log(globals.REGRESSION.FUNCS[globals.REGRESSION.EXPONENTIAL][0](1, Ps) - Ps[0])
          solutionVector.push Math.log(globals.REGRESSION.FUNCS[globals.REGRESSION.EXPONENTIAL][0](2, Ps) - Ps[0])
          newPs = numeric.solve(coeffMatrix, solutionVector)
          newPs.push globals.REGRESSION.FUNCS[globals.REGRESSION.EXPONENTIAL][0](1, Ps) - \
            (Math.exp((newPs[0] * min) + newPs[1]))
      newPs

    calculateR2 = (solution, points) ->
      # Get R2 value
      [xs, ys] = [(point.x for point in points), (point.y for point in points)]
      yAvg = ys.reduce((pv, cv, index, array) -> pv + cv) / ys.length
      ssRes = (Math.pow(y - solution.evaluate(xs[i]), 2) for y, i in ys)\
      .reduce((pv, cv, index, array) -> (pv + cv))
      ssTot = (Math.pow(y - yAvg, 2) for y in ys).reduce (pv, cv, index, array) -> (pv + cv)
      1 - (ssRes / ssTot)

    globals.getRegressionSeries = \
    (func, Ps, R2, type, xBounds, seriesName, dashStyle, id, tooltip = null, normalized = false) ->
      generateHighchartsSeries(func, Ps, R2, type, xBounds, seriesName, dashStyle, id, tooltip, normalized)
