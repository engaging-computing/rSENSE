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
        #console.trace()
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
          for populant in individuals
            individualFitness = eval "populant.#{func}(points)"
            sumFitnesses = sumFitnesses + individualFitness
            individualFitnesses.push individualFitness
          individualFitnesses = individualFitnesses.map((y) -> if isNaN y then 0 else y)
          distribution = for number, index in individualFitnesses
            cumulativeFitness = individualFitnesses[0..index].reduce (pv, cv, index, array) -> pv + cv
            cumulativeFitness / sumFitnesses
        rand = Math.random()
        for probability, i in distribution
          if rand < probability
            indiv = individuals[i]
            return new individual(indiv.tree, indiv.maxDepth)

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
          Math.pow(point.y - @evaluate(point.x), 2)
        fitness = fitnessAtPoints.reduce (pv, cv, index, array) -> pv + cv
        if isNaN(fitness)
          fitness = Infinity
        return if raw then fitness else 1 / (1 + fitness)

      # Calculates an individual's fitness by its mean squared-error over points
      mseFitness: (points) ->
        fitness = 1 / (1 + (1 / points.length) * @sseFitness(points, true))
        fitness      

      # Calculates an individual's fitness by scaled fitness 
      # (technique employed in the scaled symbolic regression paper by Keijzer)
      scaledFitness: (points, params = false) ->
        # define inputs (xs), targets (ts), and outputs (ys)
        xs = (point.x for point in points)
        ys = (@evaluate(point.x) for point in points)
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
        values = (@evaluate(point.x) for point in points)
        averageValue = values.reduce((pv, cv, index, array) -> pv + cv) / values.length
        targets = (point.y for point in points)
        averageTarget = targets.reduce((pv, cv, index, array) -> pv + cv) / targets.length
        fitness = (Math.pow(targets[i] - values[i], 2) / (averageTarget * averageValue) for i in [0...values.length]).reduce((pv, cv, index, array) -> pv + cv) / points.length
        if isNaN(fitness)
          fitness = 0
        if raw then fitness else 1 / (1 + fitness)

      # Calculate's an individual's fitness via pareto genetic 
      # programming. Nonlinearity is concurrently minimized alongside 
      # the maximization of the fitness function specified.
      # 
      # Goodness of fit is (by default) calculated via Normalized Mean-Squared Error,
      # and non-linearity is calculated through a visitation-length heuristic
      # as specified in the M. Keijzer and J. Foster paper. 
      paretoFitness: (points, func = 'scaledFitness') -> 
        nonLinearity = (tree) ->
          return 0 if tree is null
          #console.log add, subtract, multiply, safeDiv
          switch tree.data
            when window.add, window.subtract, window.multiply, window.safeDiv
              tree.treeSize() * (nonLinearity(tree.left) + nonLinearity(tree.right))
            when window.sin, window.cos
              3 * tree.treeSize() * (nonLinearity(tree.left) + nonLinearity(tree.right))
            when window.safeSqrt, window.pow, window.exp, window.safeLog
              2 * tree.treeSize() * (nonLinearity(tree.left) + nonLinearity(tree.right))
            else 1
        #console.log @
        fitness = Math.pow(eval("this.#{func}(points)"), -1) - 1
        #console.log fitness
        #test = new individual(@tree)
        #console.log "test tree is: ", @tree
        #console.log @tree
        #temp = binaryTree.clone(@tree)
        #nonlinearity = nonLinearity(@tree)
        #console.log "temp == @tree? ", binaryTree.is_equal(temp, @tree)
        #console.log "nonlinearity is: ", nonlinearity
        nonlinearity = nonLinearity(@tree)#1 #(@tree.depthAtPoint(i) for i in [0...@tree.treeSize()]).reduce((pv, cv, index, array) -> pv + cv) + this.tree.treeSize()
        #console.log nonlinearity
        ret = if isNaN(fitness + nonlinearity) or (fitness + nonlinearity) is Infinity then 0 else (1 / fitness + nonlinearity)#(1 / (1 + fitness + Math.pow(nonlinearity, 10))
        #console.log 'fitness:', fitness, 'nonlinearity: ', nonlinearity 
        #console.log ret
        ret
      ###
      # Particle Swarm Optimization is a nonlinear optimization strategy used to enhance
      # the performance of symbolic regression.  The terminal set consists of the 
      # dependent variable, x, and a single constant referred to in the literature as the 
      # ephemeral constant.  PSO finds a near-optimal value of these ephemeral constants 
      # to maximize the individual's fitness, separating the task of identifying the correct
      # function, and the constant values it contains.
      ###
      ###
      # WARNING:  MUTATES THE INDIVIDUAL
      ###
      @particleSwarmOptimization: (populant, points, fitness = 'scaledFitness', maxFitness = 1, numParticles = 50, maxPosition = 1000, minPosition = -1000, maxVelocity = 50, minVelocity = -50, maxIterations = 200, numNeighborhoods = 5, c1 = 2, c2 = 2) ->
        
        tree = populant.tree
        treeValues = for i in [0...tree.treeSize()]
          value = tree.index(i)
          if value.data is 'ec' or typeof(value.data) is 'number' then value.data else null
        #console.log treeValues
        constants = []
        for value, index in treeValues
          if value isnt null then constants.push {value: value, index, index}
        return populant if constants.length is 0
        #console.log  constants
        particles = []
        for i in [0...numParticles]
          dimensions = for j in [0...constants.length]
            index = constants[j].index
            velocity = Math.random() * (maxVelocity - minVelocity) + minVelocity
            position = Math.random() * (maxPosition - minPosition) + minPosition
            {velocity: velocity, position: position, personalBest: position, index: index}
          particles.push {neighborhood: i % numNeighborhoods, dimensions: dimensions}
        #console.log particles
        neighborhoodBests = (-Infinity for i in [0...numNeighborhoods])
        dimensionBests = (-Infinity for i in [0...numNeighborhoods])
        for particle in particles
          evaluationPoint = new individual(tree)
          for dimension in particle.dimensions
            evaluationPoint.tree.index(dimension.index).insertData(dimension.position)
          #console.log evaluationPoint
          currentFitness = eval "evaluationPoint.#{fitness}(points)"
          particle.bestFitness = currentFitness
          if currentFitness >= maxFitness
            return evaluationPoint
          #console.log "particle.neighborhood: #{particle.neighborhood}"
          #console.log "current Fitness: #{currentFitness}", "neighborhoodBests[particle.neighborhood]: #{neighborhoodBests[particle.neighborhood]}"
          if currentFitness >= neighborhoodBests[particle.neighborhood]
            neighborhoodBests[particle.neighborhood] = currentFitness
            dimensionBests[particle.neighborhood] = (dim.position for dim in particle.dimensions)
        #console.log neighborhoodBests        
        for i in [0...maxIterations]
          for particle in particles
            evaluationPoint = new individual(tree, populant.maxDepth)
            for dimension, index in particle.dimensions
              dimension.velocity = Math.min(Math.max(dimension.velocity + (Math.random() * c1 * (dimension.personalBest - dimension.position)) + (Math.random() * c2 * (dimensionBests[particle.neighborhood][index] - dimension.position)), minVelocity), maxVelocity)
              dimension.position = Math.max(Math.min(dimension.position + dimension.velocity, maxVelocity), minVelocity)
              #console.log "DIMENSION POSITION: #{dimension.position}"
              evaluationPoint.tree.index(dimension.index).insertData(dimension.position)
            currentFitness = eval "evaluationPoint.#{fitness}(points)"
            if currentFitness > particle.bestFitness
              particle.bestFitness = currentFitness
              for dimension, index in particle.dimensions
                dimension.personalBest = dimension.position
            if currentFitness >= maxFitness              
              return new individual(evaluationPoint.tree, populant.maxDepth)
            if currentFitness > neighborhoodBests[particle.neighborhood]
              neighborhoodBests[particle.neighborhood] = currentFitness
              dimensionBests[particle.neighborhood] = (dim.position for dim in particle.dimensions)
        [bestIndex, bestFitness] = [0, 0]
        for fitness, index in neighborhoodBests
          if neighborhoodBests[i] >= bestFitness
            bestIndex = index
            bestFitness = fitness
        result = new individual(tree, populant.maxDepth)
        for constant, index in constants
          result.tree.index(constant.index).insertData(dimensionBests[bestIndex][index])
        result