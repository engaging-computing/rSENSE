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
# File:         Symbolic Regression                                      #
#                                                                        #
# Description:  This file contains the symbolic regression               #
#               algorithm used to calculate regression functions         #
##########################################################################

$ ->

  if namespace.controller is "visualizations" and
  namespace.action in ["displayVis", "embedVis", "show"]
    
    ###
    # Begin constant declarations. The following constants are used
    # when the user does not specify the algorithm parameters desired.
    ###

    # Fitness function to be used (scaled mean-squared error)
    window.FITNESS = 'scaledFitness'
    # Selection operator to be used (fitness-proportional)
    window.SELECTION = 'fpSelection'
    # Reproduction operator to be used (fitness-proportional)
    window.REPRODUCTION = 'fpReproduce'
    # Crossover operator to be used (cut-and-splice method)
    window.CROSSOVER = 'crossover'
    # Mutation operator to be used (point mutation)
    window.MUTATION = 'mutate'
    # Maximum depth of an individual's expression tree
    window.INDIVIDUALDEPTH = 5
    # Number of individuals in a population at any given time
    # NOTE:  MUST BE A MULTIPLE OF EIGHT TO USE THE 
    #        OPTIMIZED VERSION OF THE ALGORITHM CORRECTLY.
    window.POPULATIONSIZE = 200
    # Probability that a child individual is produced through
    # reproduction, and inserted (unmodified) into the next 
    # generation of the population
    window.REPRODUCTIONPROBABILITY = .3
    # Probability that two offspring are produced through a genetic
    # crossover operation
    window.CROSSOVERPROBABILITY = .6    
    # Probability a mutation occurs, and the mutant is inserted into
    # the next generation of the population
    window.MUTATIONPROBABILITY = .1
    # Maximum number of iterations (simulated generations) to 
    # be performed while searching for an adequately-fit
    # candidate solution (termination criteria)
    window.MAXITERS = 200
    # Any individuals with fitness greater than MAXFITNESS
    # will be immediately returned as a candidate solution
    # (termination criteria)
    window.MAXFITNESS = 0.95
    # tournament size parameter for tournament selection and reproduction
    window.TOURNAMENTSIZE = 10
    # Probability that the most fit individual of the tournament is 
    # selected during tournament selection and reproduction
    window.TOURNAMENTPROBABILITY = 0.8
    ###
    # Batch sizes for optimized symbolic regression implementation;
    # Each new generation contains MUTATIONBATCHSIZE individuals created
    # by genetic mutation, REPRODUCTIONBATCHSIZE individuals created by
    # genetic reproduction, etc.
    ###
    window.MUTATIONBATCHSIZE = MUTATIONPROBABILITY * POPULATIONSIZE
    window.REPRODUCTIONBATCHSIZE = REPRODUCTIONPROBABILITY * POPULATIONSIZE
    window.CROSSOVERBATCHSIZE = CROSSOVERPROBABILITY * POPULATIONSIZE
    ###
    # End batch size declarations for optimized symbolic regression implementation
    ###
    ###
    # End constant declarations.
    ###
    
    ###
    # Return the scaled expression tree calculated by scaled fitness
    ###
    scaledIndividual = (populant, points, individualDepth) ->
      populant = individual.particleSwarmOptimization(populant, points)
      for i in [0...populant.tree.treeSize()]
        if populant.tree.index(i).data is 'ec'
          console.log 'done goofd'
      [a, b] = populant.scaledFitness(points, true)
      scaledTree = new binaryTree
      scaledTree.insertData(add)
      scaledTree.insertData(multiply, 'right')
      scaledTree.insertData(a, 'left')
      scaledTree.right.insertData(b, 'left')
      scaledTree.right.insertData(1, 'right')
      scaledTree.insertTree(populant.tree, 4)
      return new individual(scaledTree, Math.max(individualDepth, scaledTree.maxDepth()))

    window.symbolicRegression = (points, fitness = null, selection = null, reproduction = null, crossover = null, mutation = null, individualDepth = null, populationSize = null, reproductionProbability = null, crossoverProbability = null, mutationProbability = null, maxIters = null, maxFitness = null, tournamentSize = null, tournamentProbability = null) ->
      
      ###
      # Initialize algorithm parameters; use default values defined above if the 
      # user does not specify a certain argument.  Defined redundantly for clarity.
      ###
      fitness = if fitness is null then FITNESS else fitness
      selection = if selection is null then SELECTION else selection
      reproduction = if reproduction is null then REPRODUCTION else reproduction
      crossover = if crossover is null then CROSSOVER else crossover
      mutation = if mutation is null then MUTATION else mutation
      individualDepth = if individualDepth is null then INDIVIDUALDEPTH else individualDepth
      populationSize = if populationSize is null then POPULATIONSIZE else populationSize
      reproductionProbability = if reproductionProbability is null then REPRODUCTIONPROBABILITY else reproductionProbability
      crossoverProbability = if crossoverProbability is null then CROSSOVERPROBABILITY else crossoverProbability
      mutationProbability = if mutationProbability is null then MUTATIONPROBABILITY else mutationProbability
      maxIters = if maxIters is null then MAXITERS else maxIters
      maxFitness = if maxFitness is null then MAXFITNESS else maxFitness
      tournamentSize = if tournamentSize is null then TOURNAMENTSIZE else tournamentSize
      tournamentProbability = if tournamentProbability is null then TOURNAMENTPROBABILITY else tournamentProbability
      bestIndividual = null
      
      # Stochastic Universal Sampling size is non-configurable for traditional symbolic regression
      susSelectionSize = 2
      susReproductionSize = 1

      # Keep track of location of individuals with max/min fitness within population
      maxIndex = 0
      
      max = (pv, cv, index, array) -> 
        if cv is Math.max(pv, cv) then maxIndex = index
        Math.max(pv, cv)

      # Create initial population
      population = (new individual(null, individualDepth) for i in [0...populationSize])
      
      # Calculate fitness of initial population
      fitnesses = for populant in population
        eval "populant.#{fitness}(points)"
      
      # Determine most fit individual from initial population
      mostFit = fitnesses.reduce max, 0
      bestIndividual = population[maxIndex]

      # Check if the most fit individual from the 
      # initial population is sufficiently fit 
      if mostFit >= maxFitness
        return if fitness isnt 'scaledFitness' 
          individual.particleSwarmOptimization(bestIndividual, points)
        else
          scaledIndividual(individual.particleSwarmOptimization(population[maxIndex]), points, individualDepth)
  
      newPopulation = []

      # Else, begin symbolic regression algorithm
      for i in [0...maxIters]
        # Initialize empty new population
        newPopulation = []

        ###
        # Begin creation of a new generation of individuals
        ###
        while newPopulation.length isnt populationSize
          
          # Step 1: Select one individual  for reproduction with probability reproductionProbability
          if Math.random() <= reproductionProbability
            # Perform user-specified reproduction with appropriate arguments
            switch reproduction
              when 'fpReproduce'
                newPopulation.push(eval("individual.#{reproduction}(population, points, fitness)"))
              when 'susReproduce'
                newPopulation.push(eval("individual.#{reproduction}(population, points, fitness, susReproductionSize)")[0])
              when 'tournamentReproduce'
                newPopulation.push(eval("individual.#{reproduction}(population, points, fitness, tournamentSize, tournamentProbability)"))

          # Step 2: First, select two individuals for crossover with probability 
          #         crossoverProbability.  If two individuals are selected, use the
          #         crossover methodology specified to produce two new individuals
          if Math.random() <= crossoverProbability and populationSize - newPopulation.length >= 2
            parents = switch selection
              when 'fpSelection'
                parentOne = eval "individual.#{selection}(population, points, fitness)"
                parentTwo = eval "individual.#{selection}(population, points, fitness)"
                [parentOne, parentTwo]
              when 'susSelection'
                eval "individual.#{selection}(population, points, fitness, susSelectionSize)"
              when 'tournamentSelection'
                parentOne = eval "individual.#{selection}(population, points, fitness, tournamentSize, tournamentProbability)"
                parentTwo = eval "individual.#{selection}(population, points, fitness, tournamentSize, tournamentProbability)"
                [parentOne, parentTwo]
            children = eval("individual.#{crossover}(parents[0], parents[1])")
            newPopulation.push(children[0])
            newPopulation.push(children[1])            

          # Step 3:  Select one individual for mutation with probability mutationProbability
          if Math.random() <= mutationProbability and populationSize - newPopulation.length >= 1 and newPopulation.length isnt 0
            mutant = population[Math.floor(Math.random() * population.length)]
            newPopulation.push(eval("individual.#{mutation}(mutant)"))
        ###
        # End creation of a new generation of individuals
        ###

        # Set current population to the next generation
        population = newPopulation
        #population = population.map((y) -> individual.particleSwarmOptimization(y, points))
        # Calculate fitness of the next generation
        fitnesses = for populant in population
          eval "populant.#{fitness}(points)"
        # Find the most fit individual in current population
        bestFitnessInPopulation = fitnesses.reduce(max, 0)
        
        # Test primary termination condition
        if bestFitnessInPopulation >= maxFitness
          return if fitness isnt 'scaledFitness' 
            individual.particleSwarmOptimization(population[maxIndex], points)
          else
            scaledIndividual(individual.particleSwarmOptimization(population[maxIndex], points), points, individualDepth)
        
        # Update the fittest individual found if the fittest individual
        # from this generation is more fit than the fittest individual found
        # thus far. 
        if bestFitnessInPopulation > eval "bestIndividual.#{fitness}(points)" 
          bestIndividual = population[maxIndex]

      # The maximum number of iterations have been performed, so we
      # return the fittest individual that has been found. 
      if fitness isnt 'scaledFitness'
        individual.particleSwarmOptimization(bestIndividual, points)
      else
        scaledIndividual(individual.particleSwarmOptimization(bestIndividual, points), points, individualDepth)

    # Optimized symbolic regression implementation with deterministic population
    # ratios and batch selection and reproduction.  Comments omitted for brevity.
    window.optimizedSymbolicRegression = (points, fitness = null, selection = null, reproduction = null, crossover = null, mutation = null, individualDepth = null, populationSize = null, reproductionProbability = null, crossoverProbability = null, mutationProbability = null, maxIters = null, maxFitness = null, tournamentSize = null, tournamentProbability = null) ->
      
      fitness = if fitness is null then FITNESS else fitness
      selection = if selection is null then SELECTION else selection
      reproduction = if reproduction is null then REPRODUCTION else reproduction
      crossover = if crossover is null then CROSSOVER else crossover
      mutation = if mutation is null then MUTATION else mutation
      individualDepth = if individualDepth is null then INDIVIDUALDEPTH else individualDepth
      populationSize = if populationSize is null then POPULATIONSIZE else populationSize
      reproductionBatchSize = if reproductionProbability is null then REPRODUCTIONBATCHSIZE else reproductionProbability * populationSize
      crossoverBatchSize = if crossoverProbability is null then CROSSOVERBATCHSIZE else crossoverProbability * populationSize
      mutationBatchSize = if mutationProbability is null then MUTATIONBATCHSIZE else mutationProbability * populationSize
      maxIters = if maxIters is null then MAXITERS else maxIters
      maxFitness = if maxFitness is null then MAXFITNESS else maxFitness
      tournamentSize = if tournamentSize is null then TOURNAMENTSIZE else tournamentSize
      tournamentProbability = if tournamentProbability is null then TOURNAMENTPROBABILITY else tournamentProbability
      bestIndividual = null
      
      maxIndex = 0
      
      max = (pv, cv, index, array) -> 
        if cv is Math.max(pv, cv) then maxIndex = index
        Math.max(pv, cv)

      population = (new individual(null, individualDepth) for i in [0...populationSize])
      #population = population.map((y) -> individual.particleSwarmOptimization(y, points))
      fitnesses = for populant in population
        eval "populant.#{fitness}(points)"
      
      mostFit = fitnesses.reduce max, 0
      bestIndividual = population[maxIndex]

      if mostFit >= maxFitness
        return if fitness isnt 'scaledFitness' 
          bestIndividual
        else
          scaledIndividual(population[maxIndex], points, individualDepth)
  
      newPopulation = []

      for i in [0...maxIters]

        newPopulation = []

        sumFitnesses = fitnesses.map((y) -> if isNaN(y) then 0 else y).reduce((pv, cv, index, array) -> pv + cv)
        distribution = for _, index in fitnesses
          cumulativeFitness = fitnesses[0..index].reduce (pv, cv, index, array) -> pv + cv
          cumulativeFitness / sumFitnesses
        switch reproduction
          when 'fpReproduce'
            for _ in [0...reproductionBatchSize]
              newPopulation.push(eval("individual.#{reproduction}(population, points, fitness, distribution)"))
          when 'susReproduce'
            children = eval "individual.#{reproduction}(population, points, fitness, reproductionBatchSize, distribution)"
            for child in children
              newPopulation.push child
          when 'tournamentReproduce'
            for _ in [0...reproductionBatchSize]
              newPopulation.push(eval("individual.#{reproduction}(population, points, fitness, tournamentSize, tournamentProbability)"))

        parents = []
        switch selection
          when 'fpSelection'
            for _ in [0...(2 * Math.round(crossoverBatchSize / 4))]
              parents.push(eval("individual.#{selection}(population, points, fitness, distribution)"))
              parents.push(eval("individual.#{selection}(population, points, fitness, distribution)")) 
          when 'susSelection'
            parents = eval "individual.#{selection}(population, points, fitness, (2 * Math.round(crossoverBatchSize / 4)), distribution)"
          when 'tournamentSelection'
            for _ in [0...(2 * Math.round(crossoverBatchSize / 4))]
              parents.push(eval("individual.#{selection}(population, points, fitness, tournamentSize, tournamentProbability)"))
              parents.push(eval("individual.#{selection}(population, points, fitness, tournamentSize, tournamentProbability)"))
        children = []
        for j in [0...parents.length] by 2
          res = eval("individual.#{crossover}(parents[j], parents[j+1])")
          children.push res[0]
          children.push res[1]
        newPopulation = newPopulation.concat(children)            

        switch selection
          when 'fpSelection'
            for _ in [0...mutationBatchSize]
              mutant = eval "individual.#{selection}(population, points, fitness, distribution)"
              newPopulation.push(eval("individual.#{mutation}(mutant)"))
          when 'susSelection'
            mutants = eval "individual.#{selection}(population, points, fitness, mutationBatchSize, distribution)"
            for mutant in mutants
              newPopulation.push(eval("individual.#{mutation}(mutant)"))
          when 'tournamentSelection'
            for _ in [0...mutationBatchSize]
              mutant = eval "individual.#{selection}(population, points, fitness, tournamentSize, tournamentProbability)"
              newPopulation.push(eval("individual.#{mutation}(mutant)"))

        bestFitnessInPopulation = fitnesses.reduce(max, 0)
        if bestFitnessInPopulation >= maxFitness
          return if fitness isnt 'scaledFitness' 
            population[maxIndex]
          else
            scaledIndividual(population[maxIndex], points, individualDepth)
        if bestFitnessInPopulation > eval "bestIndividual.#{fitness}(points)" 
          bestIndividual = population[maxIndex]

      if fitness isnt 'scaledFitness'
        bestIndividual
      else
        scaledIndividual(bestIndividual, points, individualDepth)

    window.points = for i in [0...20]
      {x: i, y: Math.sqrt(i)}
    #window.result = window.optimizedSymbolicRegression(points)

