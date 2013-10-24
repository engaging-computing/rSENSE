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
      globals.REGRESSION.LINEAR = 1
      globals.REGRESSION.QUADRATIC = 2
      globals.REGRESSION.CUBIC = 3
      globals.REGRESSION.EXPONENTIAL = 4
      globals.REGRESSION.LOGARITHMIC = 5    

      #TODO
      #Somehow magically generate and catch the on click event
      
      getRegression:(x_in, y_in, regression_type, x_bounds) ->
      
        #Get the correct regression type
        switch regression_type
      
          when globals.REGRESSION.LINEAR then
            #Make x_fin based on linear params
            for x_val in x_in
              x_fin.push([1, x_val])
        
          when globals.REGRESSION.QUADRATIC then
            #Make x_fin based on quadratic params
            for x_val in x_in
              x_fin.push([1, x_val, Math.pow(x_val, 2)])

          when globals.REGRESSION.CUBIC then
            #Make x_fin based on cubic params
            for x_val in x_in
              x_fin.push([1, x_val, Math.pow(x_val, 2), Math.pow(x_val, 3)])
        
          when globals.REGRESSION.EXPONENTIAL then
            #Make x_fin based on exponential params
            for x_val in x_in
              x_fin.push([1, Math.exp(x_val)])
        
          when globals.REGRESSION.LOGARITHMIC then
            #Make x_fin based on logarithmic params
            for x_val in x_in
              x_fin.push([1, Math.log(x_val)])
        
        #Calculate the regression matrix, and finally the highcharts series object
        regression_matrix = calculateRegression(x_fin, y_in)
        result_series = generateHighchartsSeries(regression_matrix, regression_type, x_bounds)
      
      #Calculates the regression according to the provided x and y matrices.
      calculateRegression:(x, y) ->
      
        #Return the resulting vector
        return numeric.dot(numeric.dot(numeric.inv(numeric.dot(numeric.transpose(x), x)), numeric.transpose(x)), y)
      
      #Returns a series object to draw on the chart canvas
      generateHighchartsSeries:(regression_matrix, regression_type, x_bounds) ->
        
        #Get the correct regression type
        switch regression_type
        
          when globals.REGRESSION.LINEAR then
            ret =
              name: 'Linear Trend',
              data: [{ y : calculateRegressionPoint(regression_matrix, x_val, x_bounds.min), x : x_bounds.min },
                     { y : calculateRegressionPoint(regression_matrix, x_val, x_bounds.max), x : x_bounds.max }]
          
          when globals.REGRESSION.QUADRATIC then
            #TODO actually generate a trend here
            ret =
              name: 'Quadratic Trend',
              data: [{ y : calculateRegressionPoint(regression_matrix, x_val, x_bounds.min), x : x_bounds.min },
                     { y : calculateRegressionPoint(regression_matrix, x_val, x_bounds.max), x : x_bounds.max }]
          
          when globals.REGRESSION.CUBIC then
            #TODO actually generate a trend here
            ret =
              name: 'Cubic Trend',
              data: [{ y : calculateRegressionPoint(regression_matrix, x_val, x_bounds.min), x : x_bounds.min },
                     { y : calculateRegressionPoint(regression_matrix, x_val, x_bounds.max), x : x_bounds.max }]
              
          when globals.REGRESSION.EXPONENTIAL then
            #TODO actually generate a trend here
            ret =
              name: 'Exponential Trend',
              data: [{ y : calculateRegressionPoint(regression_matrix, x_val, x_bounds.min), x : x_bounds.min },
                     { y : calculateRegressionPoint(regression_matrix, x_val, x_bounds.max), x : x_bounds.max }]

          when globals.REGRESSION.LOGARITHMIC then
            #TODO actually generate a trend here
            ret =
              name: 'Logarithmic Trend',
              data: [{ y : calculateRegressionPoint(regression_matrix, x_val, x_bounds.min), x : x_bounds.min },
                     { y : calculateRegressionPoint(regression_matrix, x_val, x_bounds.max), x : x_bounds.max }]
      
      #Uses the regression matrix to calculate the y value given an x value
      calculateRegressionPoint:(regression_matrix, x_val, regression_type) ->
      
        switch regression_type
        
          when globals.REGRESSION.LINEAR then
            return regression_matrix[0][2] + regression_matrix[1][2] * x_val

          when globals.REGRESSION.QUADRATIC then
            return regression_matrix[0][3] + regression_matrix[1][3] * x_val + regression_matrix[2][3] * Math.pow(x_val, 2)
          
          when globals.REGRESSION.CUBIC then
            return regression_matrix[0][4] + regression_matrix[1][4] * x_val + regression_matrix[2][4] * Math.pow(x_val, 2) + regression_matrix[3][4] * Math.pow(x_val, 3)
          
          when globals.REGRESSION.EXPONENTIAL then
            return regression_matrix[0][2] + regression_matrix[1][2] * Math.exp(x_val)
          
          when globals.REGRESSION.LOGARITHMIC then
            return regression_matrix[0][2] + regression_matrix[1][2] * Math.log(x_val)