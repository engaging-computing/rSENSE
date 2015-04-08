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
  if namespace.controller is 'visualizations' and
  namespace.action in ['displayVis', 'embedVis', 'show']
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
    window.INDIVIDUALDEPTH = 4
    # Maximum length of an expression tree
    window.MAXDEPTH = 6
    # Number of individuals in a population at any given time
    # NOTE:  MUST BE A MULTIPLE OF EIGHT TO USE THE
    #        OPTIMIZED VERSION OF THE ALGORITHM CORRECTLY.
    window.POPULATIONSIZE = 100
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
    window.MAXITERS = 100
    # Any individuals with fitness greater than MAXFITNESS
    # will be immediately returned as a candidate solution
    # (termination criteria)
    window.MAXFITNESS = 1
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
      #populant = individual.particleSwarmOptimization(populant, points)
      [a, b] = populant.scaledFitness(points, true)
      scaledTree = new BinaryTree
      scaledTree.insertData(add)
      scaledTree.insertData(multiply, 'right')
      scaledTree.insertData(a, 'left')
      scaledTree.right.insertData(b, 'left')
      scaledTree.right.insertData(1, 'right')
      scaledTree.insertTree(populant.tree, 4)
      return new Individual(scaledTree, Math.max(individualDepth, scaledTree.maxDepth()))

    window.symbolicRegression = (points) ->

      # Stochastic Universal Sampling size is non-configurable for traditional symbolic regression
      susSelectionSize = 2
      susReproductionSize = 1

      # Keep track of location of individuals with max/min fitness within population
      maxIndex = 0

      max = (pv, cv, index, array) ->
        if cv is Math.max(pv, cv) then maxIndex = index
        Math.max(pv, cv)

      # Create initial population
      population = (new Individual(null, INDIVIDUALDEPTH) for i in [0...POPULATIONSIZE])

      # Calculate fitness of initial population
      fitnesses = for populant in population
        eval "populant.#{FITNESS}(points)"
      # Prevent the selection and reproduction of any trees that are too complex
      for pop, i in population
        if pop.tree.maxDepth() >= MAXDEPTH
          fitnesses[i] = 0
      # Determine most fit individual from initial population
      mostFit = fitnesses.reduce max, 0
      bestIndividual = population[maxIndex]

      # Check if the most fit individual from the
      # initial population is sufficiently fit
      if mostFit >= MAXFITNESS
        return unless FITNESS in ['scaledFitness', 'paretoFitness']
          Individual.particleSwarmOptimization(bestIndividual, points)
        else
          scaledIndividual(Individual.particleSwarmOptimization(population[maxIndex], points), points, individualDepth)

      newPopulation = []

      # Else, begin symbolic regression algorithm
      for i in [0...MAXITERS]
        # Initialize empty new population
        newPopulation = []

        ###
        # Begin creation of a new generation of individuals
        ###
        while newPopulation.length isnt POPULATIONSIZE

          # Step 1: Select one individual  for reproduction with probability reproductionProbability
          if Math.random() <= REPRODUCTIONPROBABILITY
            # Perform user-specified reproduction with appropriate arguments
            switch REPRODUCTION
              when 'fpReproduce'
                newPopulation.push(eval("Individual.#{REPRODUCTION}(population, points, FITNESS)"))
              when 'susReproduce'
                newPopulation.push \
                eval("Individual.#{REPRODUCTION}(population, points, FITNESS, susReproductionSize)")[0]
              when 'tournamentReproduce'
                newPopulation.push \
                eval("Individual.#{REPRODUCTION}(population, points, FITNESS, TOURNAMENTSIZE, TOURNAMENTPROBABILITY)")

          # Step 2: First, select two individuals for crossover with probability
          #         crossoverProbability.  If two individuals are selected, use the
          #         crossover methodology specified to produce two new individuals
          if Math.random() <= CROSSOVERPROBABILITY and POPULATIONSIZE - newPopulation.length >= 2
            parents = switch SELECTION
              when 'fpSelection'
                parentOne = eval "Individual.#{SELECTION}(population, points, FITNESS)"
                parentTwo = eval "Individual.#{SELECTION}(population, points, FITNESS)"
                [parentOne, parentTwo]
              when 'susSelection'
                eval "Individual.#{SELECTION}(population, points, FITNESS, susSelectionSize)"
              when 'tournamentSelection'
                parentOne = \
                eval "Individual.#{SELECTION}(population, points, FITNESS, TOURNAMENTSIZE, TOURNAMENTPROBABILITY)"
                parentTwo = \
                eval "Individual.#{SELECTION}(population, points, FITNESS, TOURNAMENTSIZE, TOURNAMENTPROBABILITY)"
                [parentOne, parentTwo]
            children = eval("Individual.#{CROSSOVER}(parents[0], parents[1])")
            newPopulation.push(children[0])
            newPopulation.push(children[1])

          # Step 3:  Select one individual for mutation with probability mutationProbability
          if Math.random() <= MUTATIONPROBABILITY and \
          POPULATIONSIZE - newPopulation.length >= 1 and \
          newPopulation.length isnt 0
            switch SELECTION
              when 'fpSelection'
                for _ in [0...MUTATIONBATCHSIZE]
                  mutant = eval "Individual.#{SELECTION}(population, points, FITNESS, distribution)"
                  newPopulation.push(eval("Individual.#{MUTATION}(mutant)"))
              when 'susSelection'
                mutants = eval "Individual.#{SELECTION}(population, points, FITNESS, susSelectionSize, distribution)"
                for mutant in mutants
                  newPopulation.push(eval("Individual.#{MUTATION}(mutant)"))
              when 'tournamentSelection'
                for _ in [0...MUTATIONBATCHSIZE]
                  mutant = \
                  eval "Individual.#{SELECTION}(population, points, FITNESS, TOURNAMENTSIZE, TOURNAMENTPROBABILITY)"
                  newPopulation.push \
                  eval("Individual.#{MUTATION}(mutant)")
        ###
        # End creation of a new generation of individuals
        ###

        # Set current population to the next generation
        population = newPopulation
        #population = population.map((y) -> Individual.particleSwarmOptimization(y, points))
        # Calculate fitness of the next generation
        fitnesses = for populant in population
          eval "populant.#{FITNESS}(points)"

        # Prevent the selection and reproduction of any trees that are too complex
        for pop, i in population
          if pop.tree.maxDepth() >= MAXDEPTH
            fitnesses[i] = 0

        # Find the most fit individual in current population
        bestFitnessInPopulation = fitnesses.reduce(max, 0)

        # Test primary termination condition
        if bestFitnessInPopulation >= MAXFITNESS
          return unless FITNESS in ['scaledFitness', 'paretoFitness']
            Individual.particleSwarmOptimization(population[maxIndex], points)
          else
            scaledIndividual \
            Individual.particleSwarmOptimization(population[maxIndex], points), points, INDIVIDUALDEPTH

        # Update the fittest individual found if the fittest individual
        # from this generation is more fit than the fittest individual found
        # thus far.
        if bestFitnessInPopulation > eval "bestIndividual.#{FITNESS}(points)"
          bestIndividual = population[maxIndex]

      # The maximum number of iterations have been performed, so we
      # return the fittest individual that has been found.
      unless FITNESS in ['scaledFitness', 'paretoFitness']
        Individual.particleSwarmOptimization(bestIndividual, points)
      else
        scaledIndividual(Individual.particleSwarmOptimization(bestIndividual, points), points, INDIVIDUALDEPTH)

    # Optimized symbolic regression implementation with deterministic population
    # ratios and batch selection and reproduction.  Comments omitted for brevity.
    window.optimizedSymbolicRegression = (points) ->

      maxIndex = 0

      max = (pv, cv, index, array) ->
        if cv is Math.max(pv, cv) then maxIndex = index
        Math.max(pv, cv)

      population = (new Individual(null, INDIVIDUALDEPTH) for i in [0...POPULATIONSIZE])
      #population = population.map((y) -> Individual.particleSwarmOptimization(y, points))
      fitnesses = for populant in population
        eval "populant.#{FITNESS}(points)"

      for pop, i in population
        if pop.tree.maxDepth() >= MAXDEPTH
          fitnesses[i] = 0

      mostFit = fitnesses.reduce max, 0
      bestIndividual = population[maxIndex]

      if mostFit >= MAXFITNESS
        return unless FITNESS in ['scaledFitness', 'paretoFitness']
          Individual.particleSwarmOptimization(bestIndividual, points)
        else
          scaledIndividual(Individual.particleSwarmOptimization(population[maxIndex], points), points, INDIVIDUALDEPTH)

      newPopulation = []
      for i in [0...MAXITERS]
        newPopulation = []
        sumFitnesses = fitnesses.map((y) -> if isNaN(y) then 0 else y).reduce((pv, cv, index, array) -> pv + cv)
        distribution = for _, index in fitnesses
          cumulativeFitness = fitnesses[0..index].reduce (pv, cv, index, array) -> pv + cv
          cumulativeFitness / sumFitnesses
        switch REPRODUCTION
          when 'fpReproduce'
            for _ in [0...REPRODUCTIONBATCHSIZE]
              newPopulation.push \
              eval("Individual.#{REPRODUCTION}(population, points, FITNESS, distribution)")
          when 'susReproduce'
            children = \
            eval "Individual.#{REPRODUCTION}(population, points, FITNESS, REPRODUCTIONBATCHSIZE, distribution)"
            for child in children
              newPopulation.push child
          when 'tournamentReproduce'
            for _ in [0...REPRODUCTIONBATCHSIZE]
              newPopulation.push \
              eval("Individual.#{REPRODUCTION}(population, points, FITNESS, TOURNAMENTSIZE, TOURNAMENTPROBABILITY)")

        parents = []
        switch SELECTION
          when 'fpSelection'
            for _ in [0...(2 * Math.round(CROSSOVERBATCHSIZE / 4))]
              parents.push(eval("Individual.#{SELECTION}(population, points, FITNESS, distribution)"))
              parents.push(eval("Individual.#{SELECTION}(population, points, FITNESS, distribution)"))
          when 'susSelection'
            size = (2 * Math.round(CROSSOVERBATCHSIZE / 4))
            parents = eval "Individual.#{SELECTION}(population, points, FITNESS, size, distribution)"
          when 'tournamentSelection'
            for _ in [0...(2 * Math.round(CROSSOVERBATCHSIZE / 4))]
              parents.push \
              eval("Individual.#{SELECTION}(population, points, FITNESS, TOURNAMENTSIZE, TOURNAMENTPROBABILITY)")
              parents.push \
              eval("Individual.#{SELECTION}(population, points, FITNESS, TOURNAMENTSIZE, TOURNAMENTPROBABILITY)")
        children = []
        for j in [0...parents.length] by 2
          res = eval("Individual.#{CROSSOVER}(parents[j], parents[j+1])")
          children.push res[0]
          children.push res[1]
        newPopulation = newPopulation.concat(children)
        switch SELECTION
          when 'fpSelection'
            for _ in [0...MUTATIONBATCHSIZE]
              mutant = eval "Individual.#{SELECTION}(population, points, FITNESS, distribution)"
              newPopulation.push(eval("Individual.#{MUTATION}(mutant)"))
          when 'susSelection'
            mutants = eval "Individual.#{SELECTION}(population, points, FITNESS, MUTATIONBATCHSIZE, distribution)"
            for mutant in mutants
              newPopulation.push(eval("Individual.#{MUTATION}(mutant)"))
          when 'tournamentSelection'
            for _ in [0...MUTATIONBATCHSIZE]
              mutt = eval "Individual.#{SELECTION}(population, points, FITNESS, TOURNAMENTSIZE, TOURNAMENTPROBABILITY)"
              newPopulation.push(eval("Individual.#{MUTATION}(mutt)"))

        population = newPopulation
        fitnesses = for populant in population
          eval "populant.#{FITNESS}(points)"

        for pop, i in population
          if pop.tree.maxDepth() >= MAXDEPTH
            fitnesses[i] = 0

        bestFitnessInPopulation = fitnesses.reduce(max, 0)
        if bestFitnessInPopulation >= MAXFITNESS
          return unless FITNESS in ['scaledFitness', 'paretoFitness']
            Individual.particleSwarmOptimization(population[maxIndex], points)
          else
            scaledIndividual \
            Individual.particleSwarmOptimization(population[maxIndex], points), points, INDIVIDUALDEPTH
        if bestFitnessInPopulation > eval "bestIndividual.#{FITNESS}(points)"
          bestIndividual = population[maxIndex]

      unless FITNESS in ['scaledFitness', 'paretoFitness']
        Individual.particleSwarmOptimization(bestIndividual, points)
      else
        scaledIndividual(Individual.particleSwarmOptimization(bestIndividual, points), points, INDIVIDUALDEPTH)
