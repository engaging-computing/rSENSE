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
    #Regression Types
    LINEAR = 'linear'
    QUADRATIC = 'quadratic'
    CUBIC = 'cubic'
    EXPONENTIAL = 'exponential'
    LOGARITHMIC = 'logarithmic'    

    #TODO
    #Somehow generate and catch the on click event
    
    getRegression(x_in, y_in, regression_type) ->
    
      #Get the correct regression type
      switch regression_type
    
        when 'linear' then
          #Make x_fin based on linear params
          for x_val in x_in
            x_fin.push([1, x_val])
      
        when 'quadratic' then
          #Make x_fin based on quadratic params
          for x_val in x_in
            x_fin.push([1, x_val, Math.pow(x_val, 2)])

        when 'cubic' then
          #Make x_fin based on cubic params
          for x_val in x_in
            x_fin.push([1, x_val, Math.pow(x_val, 2), Math.pow(x_val, 3)])
      
        when 'exponential' then
          #Make x_fin based on exponential params
          for x_val in x_in
            x_fin.push([1, Math.exp(x_val)])
      
        when 'logarithmic' then
          #Make x_fin based on logarithmic params
           for x_val in x_in
            x_fin.push([1, Math.log(x_val)])
      
      #Calculate the result matrix, and finally the highcharts series object
      result_matrix = calculateResult(x_fin, y_in)
      result_series = generateHighchartsSeries(result_matrix, regression_type)
    
    #Calculates the regression according to the provided x and y matrices.
    calculateResult(x, y) ->
    
      #Return the resulting vector
      return numeric.dot(numeric.dot(numeric.inv(numeric.dot(numeric.transpose(x), x)), numeric.transpose(x)), y)
      