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
        else
          @tree = binaryTree.clone(tree)
        @depth = @tree.maxDepth()
        @maxDepth = maxDepth

      # Numerically evaluate the individual function at the value n
      evaluate: (n) ->
        @tree.evaluate(n)

      # Point mutation genetic operator
      @mutate: (individual) -> 
        length = individual.tree.treeSize()
        mutationSite = Math.floor(Math.random() * length)
        mutant = binaryTree.clone(individual.tree)
        depthAtMutationSite = mutant.depthAtPoint(mutationSite)
        mutation = new binaryTree
        mutation.generate(individual.maxDepth - depthAtMutationSite + 1)
        mutant.insertTree(mutation, mutationSite)
        ret = new window.individual(mutant, mutant.maxDepth())

      # Crossover genetic operator (cut and splice approach)
      @crossover: (individual1, individual2) ->
        [childOne, childTwo] = binaryTree.crossover(individual1.tree, individual2.tree)
        [new individual(childOne, childOne.maxDepth()), new individual(childTwo, childTwo.maxDepth())]

      # Fitness-proportional reproduction genetic operator
      @fpReproduce: (individuals, points, func) ->
        sumFitnesses = 0
        individualFitnesses = []
        for individual in individuals
          individualFitness = eval "individual.#{func}(points)"
          sumFitnesses = sumFitnesses + individualFitness
          individualFitnesses.push individualFitness
        distribution = for number, index in individualFitnesses
          cumulativeFitness = individualFitnesses[0..index].reduce (pv, cv, index, array) -> pv + cv
          cumulativeFitness / sumFitnesses
        rand = Math.random()
        for probability, i in distribution
          if rand < probability
            individual = individuals[i]
            ret = new window.individual(individual.tree, individual.maxDepth)
            return ret  

      # Tournament reproduction genetic operator
      @tournamentReproduce: (individuals, points, func, tournamentSize = 10, probability = 0.8) ->
        tournament = for i in [0...tournamentSize]
          participant = Math.floor(Math.random() * individuals.length)
          {individual: individuals[participant], index: i} 
        for participant in tournament
          participant.fitness = eval "participant.individual.#{func}(points)"
        tournament.sort (a, b) -> Number(b.fitness) - Number(a.fitness)
        console.log tournament
        for participant, ind in tournament
          rand = Math.random()
          if rand < probability * Math.pow(1 - probability, ind)
            return new individual(participant.individual.tree, participant.individual.maxDepth)
        return new individual(tournament[0].individual.tree, tournament[0].individual.maxDepth)

      # Calculates an individual's fitness by its sum of squared-error over points 
      sseFitness: (points) ->
        fitnessAtPoints = for point in points
          Math.pow(point.y - this.evaluate(point.x), 2)
        sseFitness = fitnessAtPoints.reduce (pv, cv, index, array) -> pv + cv
        if isNaN(sseFitness) then 0 else 1 / (1 + sseFitness)

      # Calculates an individual's fitness by its mean squared-error over points
      mseFitness: (points) ->
        mseFitness = (1 / points.length) * this.sseFitness(points)
        mseFitness      

      # Calculates an individual's fitness by scaled fitness 
      # (technique employed in the scaled symbolic regression paper by Keijzer)
      scaledFitness: (points) ->
        # define inputs (xs), targets (ts), and outputs (ys)
        xs = (point.x for point in points)
        ys = (this.evaluate(point.x) for point in points)
        ts = (point.y for point in points)

        # calculate sum of inputs, targets, and outputs
        xSum = xs.reduce (pv, cv, index, array) -> pv + cv
        ySum = ys.reduce (pv, cv, index, array) -> pv + cv
        tSum = ts.reduce (pv, cv, index, array) -> pv + cv

        # calculate average of inputs, targets, and outputs
        xAvg = xSum / xs.length
        yAvg = ySum / ys.length
        tAvg = tSum / ts.length
        
        # calculate each input's distance from the mean, xAvg
        xMeanDiffs = (x - xAvg for x in xs)
        # calculate each output's distance from the mena, yAvg
        yMeanDiffs = (y - yAvg for y in ys)
        # calculate each target's distance from the mean, tAvg
        tMeanDiffs = (t - tAvg for t in ts)
        
        # calculate the pair-wise terms of cov(y,t)
        ytCovTerms = for i in [0...ys.length]
          (yMeanDiffs[i] * tMeanDiffs[i])
        # calculate the covariance of t and y
        ytCov = ytCovTerms.reduce (pv, cv, index, array) -> pv + cv

        # calculate the pair-wise terms of var(y)
        yVarTerms = for ydiff in yMeanDiffs
          Math.pow(ydiff, 2)
        # calculate the variance of y
        yVar = yVarTerms.reduce (pv, cv, index, array) ->
          pv + cv
        
        # b = cov(y,t) / var(y)
        b = if yVar is 0 then 1 else ytCov / yVar
        # a = tAvg - b * yAvg
        a = tAvg - b * yAvg
        
        # calculate scaled residuals (target[i] - (a + b * output[i])) ^ 2
        scaledResiduals = for i in [0...points.length]
          Math.pow(ts[i] - (a + b * ys[i]), 2)
        # calculate sum of scaled residuals
        sumScaledResiduals = scaledResiduals.reduce (pv, cv, index, array) -> pv + cv
        
        # Calculate scaled fitness
        scaledFitness = (1 / points.length) * sumScaledResiduals
        return if isNaN(scaledFitness) then 0 else 1 / (1 + scaledFitness)

    window.points = for i in [0...20]
      x: i
      y: Math.pow(i, 2)

  ###
  # TODO: 
  # 1.  Selection (just use reproduction operators)
  # 2.  New Crossover techniques (ew)
  # 3.  New mutation techniques
  # 4.  New Reproduction techniques (maybe) 
  # 5.  Pareto fitness (think about this one)
  # 6.  TEST EVERYTHING!
  ###
