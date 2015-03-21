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

    class window.individual extends Object
      
      # Create a a binary tree to represent a random mathematical function
      constructor: (tree = null, maxDepth = 10) ->
        if tree is null
          @tree = new binaryTree
          @tree.generate(Math.floor(Math.random() * (maxDepth - 1)) + 2)
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
        mutation = new binaryTree
        mutation.generate(Math.floor(Math.random() * (individual.maxDepth - 1)) + 2)
        mutant.insertTree(mutation, mutationSite)
        ret = new window.individual(mutant, mutant.maxDepth())

      # Crossover genetic operator (cut and splice approach)
      @crossover: (individual1, individual2) ->
        [childOne, childTwo] = binaryTree.crossover(individual1.tree, individual2.tree)
        [new individual(childOne, childOne.maxDepth()), new individual(childTwo, childTwo.maxDepth())]

      # Crossover genetic operator (single-point approach)
      @onePointCrossover: (individual1, individual2) ->
        [treeOne, treeTwo] = [binaryTree.clone(individual1.tree), binaryTree.clone(individual2.tree)]
        mutationSite = Math.floor(Math.random() * Math.min(treeOne.treeSize(), treeTwo.treeSize()))
        [childOne, childTwo] = [binaryTree.clone(treeOne), binaryTree.clone(treeTwo)]
        childOne.insertTree(treeTwo.index(mutationSite), mutationSite)
        childTwo.insertTree(treeOne.index(mutationSite), mutationSite)
        [new individual(childOne, childOne.maxDepth()), new individual(childTwo, childTwo.maxDepth())]

      # Crossover genetic operator (two-point approach)
      @twoPointCrossover: (individual1, individual2) ->
        [tree1a, tree1b] = [binaryTree.clone(individual1.tree), binaryTree.clone(individual1.tree)]
        [tree2a, tree2b] = [binaryTree.clone(individual2.tree), binaryTree.clone(individual2.tree)]
        [tree1c, tree2c] = [binaryTree.clone(individual1.tree), binaryTree.clone(individual2.tree)]
        mutationSite1 = Math.floor(Math.random() * Math.min(tree1a.treeSize(), tree2a.treeSize()))
        mutationSite2 = Math.floor(Math.random() * Math.min(tree1a.treeSize() - mutationSite1, tree2a.treeSize() - mutationSite1)) + mutationSite1
        [childOne, childTwo] = [binaryTree.clone(tree1a), binaryTree.clone(tree2a)]
        [childOneTail, childTwoTail] = [binaryTree.clone(tree1a.index(mutationSite2)), binaryTree.clone(tree2a.index(mutationSite2))]
        childOne.insertTree(tree2a.index(mutationSite1), mutationSite1)
        childTwo.insertTree(tree1a.index(mutationSite1), mutationSite1)
        childOne.insertTree(childOneTail, Math.min(mutationSite2, childOne.treeSize()))
        childTwo.insertTree(childTwoTail, Math.min(mutationSite2, childTwo.treeSize()))
        [new individual(childOne, childOne.maxDepth()), new individual(childTwo, childTwo.maxDepth())]

      # Fitness-proportional reproduction genetic operator
      @fpReproduce: (individuals, points, func, distribution = null) ->
        if distribution is null
          sumFitnesses = 0
          individualFitnesses = []
          for individual in individuals
            individualFitness = eval "individual.#{func}(points)"
            sumFitnesses = sumFitnesses + individualFitness
            individualFitnesses.push individualFitness
          individualFitnesses = individualFitnesses.map((y) -> if isNaN y then 0 else y)
          distribution = for number, index in individualFitnesses
            cumulativeFitness = individualFitnesses[0..index].reduce (pv, cv, index, array) -> pv + cv
            cumulativeFitness / sumFitnesses
        rand = Math.random()
        for probability, i in distribution
          if rand < probability
            individual = individuals[i]
            return new window.individual(individual.tree, individual.maxDepth)

      # Fitness-proportional selection genetic operator
      @fpSelection: (individuals, points, func, distribution = null) ->
        @fpReproduce(individuals, points, func, distribution)

      # Tournament reproduction genetic operator
      @tournamentReproduce: (individuals, points, func, tournamentSize = 10, probability = 0.8) ->
        tournament = for i in [0...tournamentSize]
          participant = Math.floor(Math.random() * individuals.length)
          [tree, maxDepth] = [participant.tree, participant.maxDepth]
          {individual: new window.individual(tree, maxDepth), index: i} 
        for participant in tournament
          participant.fitness = eval "participant.individual.#{func}(points)"
        tournament.map((participant) -> if isNaN participant.fitness then 0 else participant.fitness)
        tournament.sort (a, b) -> Number(b.fitness) - Number(a.fitness)
        for participant, ind in tournament
          rand = Math.random()
          if rand < probability * Math.pow(1 - probability, ind)
            return new individual(participant.individual.tree, participant.individual.maxDepth)
        return new individual(tournament[0].individual.tree, tournament[0].individual.maxDepth)

      # Tournament selection genetic operator
      @tournamentSelection: (individuals, points, func, tournamentSize = 10, probability = 0.8) ->
        @tournamentReproduce(individuals, points, func, tournamentSize, probability)

      # Stochastic Universal Sampling reproduction genetic operator
      ###
      # WARNING:  PERFORMS REPRODUCTION/SELECTION ALL AT ONCE
      ###
      @susReproduce: (individuals, points, func, offspring, distribution = null) ->
        fitnesses = []
        children = []
        if distribution is null
          fitnesses = for individual in individuals
            eval "individual.#{func}(points)"
          sumFitnesses = fitnesses.map((y) -> if isNaN(y) then 0 else y).reduce((pv, cv, index, array) -> pv + cv)
          distribution = for number, index in fitnesses
            cumulativeFitness = fitnesses[0..index].reduce (pv, cv, index, array) -> pv + cv
            cumulativeFitness / sumFitnesses
        distance = 1 / offspring
        pointer = Math.random() * distance
        [lastChild, numChildren] = [0, 0]
        for i in [0...offspring]
          for j in [lastChild...distribution.length]
            if distribution[j] > (pointer * (numChildren + 1))
              lastChild = j
              numChildren = numChildren + 1
              child = new window.individual(individuals[j].tree, individuals[j].maxDepth)
              children.push(child)
              break
        children
        
      # Stochastic Universal Sampling selection genetic operator
      ###
      # WARNING:  PERFORMS REPRODUCTION/SELECTION ALL AT ONCE
      ###
      @susSelection: (individuals, points, func, offspring, distribution = null) ->
        @susReproduce(individuals, points, func, offspring, distribution)

      # Calculates an individual's fitness by its sum of squared-error over points 
      sseFitness: (points, raw = false) ->
        fitnessAtPoints = for point in points
          Math.pow(point.y - this.evaluate(point.x), 2)
        fitness = fitnessAtPoints.reduce (pv, cv, index, array) -> pv + cv
        if isNaN(fitness)
          fitness = Infinity
        return if raw then fitness else 1 / (1 + fitness)

      # Calculates an individual's fitness by its mean squared-error over points
      mseFitness: (points) ->
        fitness = 1 / (1 + (1 / points.length) * this.sseFitness(points, true))
        fitness      

      # Calculates an individual's fitness by scaled fitness 
      # (technique employed in the scaled symbolic regression paper by Keijzer)
      scaledFitness: (points, params = false) ->
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
        # calculate each output's distance from the mean, yAvg
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
        yVar = yVarTerms.reduce (pv, cv, index, array) -> pv + cv
        
        # b = cov(y,t) / var(y)
        b = if yVar is 0 then 1 else ytCov / yVar
        # a = tAvg - b * yAvg
        a = tAvg - b * yAvg

        # If we need a and b (params = true), return them
        if params then return [a, b]
        
        # calculate scaled residuals (target[i] - (a + b * output[i])) ^ 2
        scaledResiduals = for i in [0...points.length]
          Math.pow(ts[i] - (a + b * ys[i]), 2)
        # calculate sum of scaled residuals
        sumScaledResiduals = scaledResiduals.reduce (pv, cv, index, array) -> pv + cv
        
        # Calculate scaled fitness
        fitness = (1 / points.length) * sumScaledResiduals
        return if isNaN(fitness) or fitness is Infinity then 0 else 1 / (1 + fitness)

      # Calculate an individual's fitness by its normalized mean-squared 
      # error over points
      nmseFitness: (points, raw = false) ->
        values = (this.evaluate(point.x) for point in points)
        averageValue = values.reduce((pv, cv, index, array) -> pv + cv) / values.length
        targets = (point.y for point in points)
        averageTarget = targets.reduce((pv, cv, index, array) -> pv + cv) / targets.length
        fitness = (Math.pow(targets[i] - values[i], 2) / (averageTarget * averageValue) for i in [0...values.length]).reduce((pv, cv, index, array) -> pv + cv) / points.length
        if isNaN(fitness)
          fitness = 0
        if raw then fitness else 1 / (1 + fitness)

      # Calculate's an individual's scaled fitness via pareto genetic 
      # programming. Nonlinearity is concurrently minimized alongside 
      # the maximization of the fitness function specified.
      # 
      # Goodness of fit is (by default) calculated via Normalized Mean-Squared Error,
      # and non-linearity is calculated through a visitation-length heuristic
      # as specified in the M. Keijzer and J. Foster paper. 
      paretoFitness: (points, func = 'nmseFitness') -> 
        fitness = if func in ['nmseFitness', 'sseFitness']
          eval "this.#{func}(points, true)"
        else eval "this.#{func}(points)"
        nonlinearity = (this.tree.depthAtPoint(i) for i in [0...this.tree.treeSize()]).reduce((pv, cv, index, array) -> pv + cv) + this.tree.treeSize()
        ret = if isNaN(fitness + nonlinearity) or (fitness + nonlinearity) is Infinity then 0 else (1 / (1 + fitness + nonlinearity))
