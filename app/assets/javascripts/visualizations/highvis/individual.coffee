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

##########################################################################
# Programmer:   Jacob Kinsman                                            #
#                                                                        #
# Assignment:   Honors Project                                           #
#                                                                        #
# File:         Individual                                               #
#                                                                        #
# Description:  This file defines an "individual" to be used in my       #
#               symbolic regression algorithm.  In genetic algorithms,   #
#               each individual in a population describes a              #
#               candidate solution, to which a genetic operator may be   #
#               applied.                                                 #
##########################################################################


$ ->

  if namespace.controller is "visualizations" and
  namespace.action in ["displayVis", "embedVis", "show"]

    class window.individual
      
      # Create a a binary tree to represent a random mathematical function
      constructor: (tree = null, maxDepth = 10) ->
        if tree is null
          @tree = new binaryTree
          @tree.generate(maxDepth)
          @depth = maxDepth
        else
          @tree = binaryTree.clone(tree)

      # Numerically evaluate the individual function at the value n
      evaluate: (n) ->
        @tree.evaluate(n)

      # Point mutation genetic operator
      @mutate: (individual) -> 
        length = individual.tree.treeSize()
        mutationSite = Math.floor(Math.random() * length)
        mutant = binaryTree.clone(individual.tree)
        value = individual.tree.index(mutationSite).data
        mutation = null
        if typeof(individual.tree.index(mutationSite).data) is 'function'
          if individual.tree.index(mutationSite).data.length is 1
            candidates = 
              binaryTree.operators.filter (func) ->
                '' + func != '' + value and func.length is 1
            mutation = candidates[Math.floor(Math.random() * candidates.length)]
          else
            candidates = 
              binaryTree.operators.filter (func) ->
                '' + func != '' + value and func.length is 2
            mutation = candidates[Math.floor(Math.random() * candidates.length)]
        else
          candidates = 
            binaryTree.terminals.filter (term) ->
              term != value
          mutation = candidates[Math.floor(Math.random() * candidates.length)]
        mutant.index(mutationSite).data = mutation
        depth = individual.tree.depth
        ret = new window.individual(mutant, depth)
        ret

      # Crossover genetic operator
      @crossover: (individual1, individual2) ->
        [childOne, childTwo] = binaryTree.crossover(individual1.tree, individual2.tree)
        [new individual(childOne), new individual(childTwo)]

      # Fitness-proportional reproduction genetic operator
      @fpReproduce: (individuals) ->
        1

      # Tournament reproduction genetic operator
      @tournamentReproduce: (individuals) ->
        1

      # Calculates an individual's fitness by its sum of squared-error over points 
      sseFitness: (points) ->
        fitnessAtPoints = for point in points
          console.log this.evaluate(point.x)
          Math.pow(point.y - this.evaluate(point.x), 2)
        sseFitness = fitnessAtPoints.reduce (pv, cv, index, array) ->
          pv + cv
        sseFitness

      # Calculates an individual's fitness by its mean squared-error over points
      mseFitness: (points) ->
        mseFitness = (1 / points.length) * this.sseFitness(points)
        mseFitness      

      # Calculates an individual's fitness by scaled fitness 
      # (technique employed in the scaled symbolic regression paper by Keijzer)
      scaledFitness: (points) ->
        xs = for point in points
          point.x
        ys = for point in points
          this.evaluate(point.x)
        ts = for point in points
          point.y

        xSum = xs.reduce (pv, cv, index, array) ->
          pv + cv
        ySum = ys.reduce (pv, cv, index, array) ->
          pv + cv
        tSum = ts.reduce (pv, cv, index, array) ->
          pv + cv

        xAvg = xSum / xs.length
        yAvg = ySum / ys.length
        tAvg = tSum / ts.length
        
        xMeanDiffs = for x in xs
          x - xAvg
        yMeanDiffs = for y in ys
          y - yAvg
        tMeanDiffs = for t in ts
          t - tAvg
        
        ytCovTerms = for i in [0...ys.length]
          (yMeanDiffs[i] * tMeanDiffs[i])
        ytCov = ytCovTerms.reduce (pv, cv, index, array) ->
          pv + cv

        yVarTerms = for ydiff in yMeanDiffs
          Math.pow(ydiff, 2)
        yVar = yVarTerms.reduce (pv, cv, index, array) ->
          pv + cv
        
        b = 
          if yVar is 0
            1
          else
            ytCov / yVar

        a = tAvg - b * yAvg
        
        scaledResiduals = for i in [0...points.length]
          Math.pow(ts[i] - (a + b * ys[i]), 2)
        sumScaledResiduals = scaledResiduals.reduce (pv, cv, index, array) ->
          pv + cv
        
        scaledFitness = (1 / points.length) * sumScaledResiduals
        scaledFitness

    window.points = for i in [0...20]
      x: i
      y: Math.pow(i, 2)

