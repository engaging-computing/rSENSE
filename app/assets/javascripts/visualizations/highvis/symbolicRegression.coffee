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

    window.symregr ?= {}

    # Fitness function to be used (scaled mean-squared error)
    symregr.FITNESS = 'scaledFitness'
    # Selection operator to be used (fitness-proportional)
    symregr.SELECTION = 'fpSelection'
    # Reproduction operator to be used (fitness-proportional)
    symregr.REPRODUCTION = 'fpReproduce'
    # Crossover operator to be used (cut-and-splice method)
    symregr.CROSSOVER = 'crossover'
    # Mutation operator to be used (point mutation)
    symregr.MUTATION = 'mutate'
    # Maximum depth of an individual's expression tree
    symregr.IDEPTH = 4
    # Maximum length of an expression tree
    symregr.MDEPTH = 6
    # Number of individuals in a population at any given time
    # NOTE:  MUST BE A MULTIPLE OF EIGHT TO USE THE
    #        OPTIMIZED VERSION OF THE ALGORITHM CORRECTLY.
    symregr.POPSIZE = 100
    # Probability that a child individual is produced through
    # reproduction, and inserted (unmodified) into the next
    # generation of the population
    symregr.REPRODUCTIONPR = .3
    # Probability that two offspring are produced through a genetic
    # crossover operation
    symregr.CROSSOVERPR = .6
    # Probability a mutation occurs, and the mutant is inserted into
    # the next generation of the population
    symregr.MUTATIONPR = .1
    # Maximum number of iterations (simulated generations) to
    # be performed while searching for an adequately-fit
    # candidate solution (termination criteria)
    symregr.MAXITERS = 100
    # Any individuals with fitness greater than MAXFITNESS
    # will be immediately returned as a candidate solution
    # (termination criteria)
    symregr.MAXFITNESS = 1
    # tournament size parameter for tournament selection and reproduction
    symregr.TSIZE = 10
    # Probability that the most fit individual of the tournament is
    # selected during tournament selection and reproduction
    symregr.TPR = 0.8
    ###
    # Batch sizes for optimized symbolic regression implementation;
    # Each new generation contains MBS individuals created
    # by genetic mutation, RBS individuals created by
    # genetic reproduction, etc.
    ###
    symregr.MBS = symregr.MUTATIONPR * symregr.POPSIZE
    symregr.RBS = symregr.REPRODUCTIONPR * symregr.POPSIZE
    symregr.CBS = symregr.CROSSOVERPR * symregr.POPSIZE
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
      [a, b] = populant.scaledFitness(points, true)
      scaledTree = new BinaryTree
      scaledTree.insertData(symregr.add)
      scaledTree.insertData(symregr.multiply, 'right')
      scaledTree.insertData(a, 'left')
      scaledTree.right.insertData(b, 'left')
      scaledTree.right.insertData(1, 'right')
      scaledTree.insertTree(populant.tree, 4)
      return new Individual(scaledTree, Math.max(individualDepth, scaledTree.maxDepth()))

    window.symbolicRegression = (points) ->
      
      # Stochastic Universal Sampling size is non-configurable for traditional symbolic regression
      susSS = 2
      susRS = 1

      # Shorter eval statements
      I = "Individual"

      # Keep track of location of individuals with max/min fitness within population
      maxIndex = 0
      
      max = (pv, cv, index, array) ->
        if cv is Math.max(pv, cv) then maxIndex = index
        Math.max(pv, cv)

      # Create initial population
      population = (new Individual(null, symregr.IDEPTH) for i in [0...symregr.POPSIZE])
      
      # Calculate fitness of initial population
      fitnesses = for populant in population
        eval "populant.#{FITNESS}(points)"
      # Prevent the selection and reproduction of any trees that are too complex
      for pop, i in population
        if pop.tree.maxDepth() >= symregr.MDEPTH
          fitnesses[i] = 0
      # Determine most fit individual from initial population
      mostFit = fitnesses.reduce max, 0
      bestIndividual = population[maxIndex]

      # Check if the most fit individual from the
      # initial population is sufficiently fit
      if mostFit >= symregr.MAXFITNESS
        return unless symregr.FITNESS in ['scaledFitness', 'paretoFitness']
          Individual.particleSwarmOptimization(bestIndividual, points)
        else
          scaledIndividual(Individual.particleSwarmOptimization(population[maxIndex], points), points, individualDepth)
  
      newPopulation = []

      # Else, begin symbolic regression algorithm
      for i in [0...symregr.MAXITERS]
        # Initialize empty new population
        newPopulation = []

        ###
        # Begin creation of a new generation of individuals
        ###
        while newPopulation.length isnt symregr.POPSIZE
          
          # Step 1: Select one individual  for reproduction with probability reproductionProbability
          if Math.random() <= symregr.REPRODUCTIONPR
            # Perform user-specified reproduction with appropriate arguments
            switch symregr.REPRODUCTION
              when 'fpReproduce'
                newPopulation.push(eval("#{I}.#{symregr.REPRODUCTION}(population, points, symregr.FITNESS)"))
              when 'susReproduce'
                newPopulation.push(
                  eval("#{I}.#{symregr.REPRODUCTION}(population, points, symregr.FITNESS, susRS)")[0])
              when 'tournamentReproduce'
                newPopulation.push(
                  eval("#{I}.#{symregr.REPRODUCTION}(population, points, symregr.FITNESS, symregr.TSIZE, symregr.TPR)")
                )

          # Step 2: First, select two individuals for crossover with probability
          #         crossoverProbability.  If two individuals are selected, use the
          #         crossover methodology specified to produce two new individuals
          if Math.random() <= symregr.CROSSOVERPR and symregr.POPSIZE - newPopulation.length >= 2
            parents = switch symregr.SELECTION
              when 'fpSelection'
                parentOne = eval "#{I}.#{symregr.SELECTION}(population, points, symregr.FITNESS)"
                parentTwo = eval "#{I}.#{symregr.SELECTION}(population, points, symregr.FITNESS)"
                [parentOne, parentTwo]
              when 'susSelection'
                eval "#{I}.#{symregr.SELECTION}(population, points, symregr.FITNESS, susSS)"
              when 'tournamentSelection'
                parentOne =
                  eval "#{I}.#{symregr.SELECTION}(population, points, symregr.FITNESS, symregr.TSIZE, symregr.TPR)"
                parentTwo =
                  eval "#{I}.#{symregr.SELECTION}(population, points, symregr.FITNESS, symregr.TSIZE, symregr.TPR)"
                [parentOne, parentTwo]
            children = eval("#{I}.#{symregr.CROSSOVER}(parents[0], parents[1])")
            newPopulation.push(children[0])
            newPopulation.push(children[1])

          # Step 3:  Select one individual for mutation with probability mutationProbability
          if Math.random() <= symregr.MUTATIONPR and
            symregr.POPSIZE - newPopulation.length >= 1 and
              newPopulation.length isnt 0
            switch SELECTION
              when 'fpSelection'
                for _ in [0...symregr.MBS]
                  mutant = eval "#{I}.#{symregr.SELECTION}(population, points, symregr.FITNESS, distribution)"
                  newPopulation.push(eval("#{I}.#{symregr.MUTATION}(mutant)"))
              when 'susSelection'
                mutants = eval "#{I}.#{symregr.SELECTION}(population, points, symregr.FITNESS, susSS, distribution)"
                for mutant in mutants
                  newPopulation.push(eval("#{I}.#{symregr.MUTATION}(mutant)"))
              when 'tournamentSelection'
                for _ in [0...symregr.MBS]
                  mutant =
                    eval "#{I}.#{symregr.SELECTION}(population, points, symregr.FITNESS, symregr.TSIZE, symregr.TPR)"
                  newPopulation.push(
                    eval("#{I}.#{symregr.MUTATION}(mutant)"))
        ###
        # End creation of a new generation of individuals
        ###

        # Set current population to the next generation
        population = newPopulation
        # Calculate fitness of the next generation
        fitnesses = for populant in population
          eval "populant.#{symregr.FITNESS}(points)"
        
        # Prevent the selection and reproduction of any trees that are too complex
        for pop, i in population
          if pop.tree.maxDepth() >= symregr.MDEPTH
            fitnesses[i] = 0
        
        # Find the most fit individual in current population
        bestFitnessInPopulation = fitnesses.reduce(max, 0)
        
        # Test primary termination condition
        if bestFitnessInPopulation >= symregr.MAXFITNESS
          return unless symregr.FITNESS in ['scaledFitness', 'paretoFitness']
            Individual.particleSwarmOptimization(population[maxIndex], points)
          else
            scaledIndividual(
              Individual.particleSwarmOptimization(population[maxIndex], points), points, symregr.IDEPTH)
        
        # Update the fittest individual found if the fittest individual
        # from this generation is more fit than the fittest individual found
        # thus far.
        if bestFitnessInPopulation > eval "bestIndividual.#{symregr.FITNESS}(points)"
          bestIndividual = population[maxIndex]

      # The maximum number of iterations have been performed, so we
      # return the fittest individual that has been found.
      unless symregr.FITNESS in ['scaledFitness', 'paretoFitness']
        Individual.particleSwarmOptimization(bestIndividual, points)
      else
        scaledIndividual(Individual.particleSwarmOptimization(bestIndividual, points), points, symregr.IDEPTH)

    # Optimized symbolic regression implementation with deterministic population
    # ratios and batch selection and reproduction.  Comments omitted for brevity.
    window.optimizedSymbolicRegression = (points) ->
            
      maxIndex = 0
      I = "Individual"
      max = (pv, cv, index, array) ->
        if cv is Math.max(pv, cv) then maxIndex = index
        Math.max(pv, cv)

      population = (new Individual(null, symregr.IDEPTH) for i in [0...symregr.POPSIZE])
      fitnesses = for populant in population
        eval "populant.#{symregr.FITNESS}(points)"
      
      for pop, i in population
        if pop.tree.maxDepth() >= symregr.MDEPTH
          fitnesses[i] = 0

      mostFit = fitnesses.reduce max, 0
      bestIndividual = population[maxIndex]

      if mostFit >= symregr.MAXFITNESS
        return unless symregr.FITNESS in ['scaledFitness', 'paretoFitness']
          Individual.particleSwarmOptimization(bestIndividual, points)
        else
          scaledIndividual(Individual.particleSwarmOptimization(population[maxIndex], points), points, symregr.IDEPTH)
  
      newPopulation = []
      for i in [0...symregr.MAXITERS]
        newPopulation = []
        sumFitnesses = fitnesses.map((y) -> if isNaN(y) then 0 else y).reduce((pv, cv, index, array) -> pv + cv)
        distribution = for _, index in fitnesses
          cumulativeFitness = fitnesses[0..index].reduce (pv, cv, index, array) -> pv + cv
          cumulativeFitness / sumFitnesses
        switch symregr.REPRODUCTION
          when 'fpReproduce'
            for _ in [0...symregr.RBS]
              newPopulation.push(
                eval("#{I}.#{symregr.REPRODUCTION}(population, points, symregr.FITNESS, distribution)"))
          when 'susReproduce'
            children =
              eval "#{I}.#{symregr.REPRODUCTION}(population, points, symregr.FITNESS, symregr.RBS, distribution)"
            for child in children
              newPopulation.push child
          when 'tournamentReproduce'
            for _ in [0...symregr.RBS]
              newPopulation.push(
                eval("#{I}.#{symregr.REPRODUCTION}(population, points, symregr.FITNESS, symregr.TSIZE, symregr.TPR)"))

        parents = []
        switch symregr.SELECTION
          when 'fpSelection'
            for _ in [0...(2 * Math.round(symregr.CBS / 4))]
              parents.push(eval("#{I}.#{symregr.SELECTION}(population, points, symregr.FITNESS, distribution)"))
              parents.push(eval("#{I}.#{symregr.SELECTION}(population, points, symregr.FITNESS, distribution)"))
          when 'susSelection'
            size = (2 * Math.round(symregr.CBS / 4))
            parents = eval "#{I}.#{symregr.SELECTION}(population, points, symregr.FITNESS, size, distribution)"
          when 'tournamentSelection'
            for _ in [0...(2 * Math.round(symregr.CBS / 4))]
              parents.push(
                eval("#{I}.#{symregr.SELECTION}(population, points, symregr.FITNESS, symregr.TSIZE, symregr.TPR)"))
              parents.push(
                eval("#{I}.#{symregr.SELECTION}(population, points, symregr.FITNESS, symregr.TSIZE, symregr.TPR)"))
        children = []
        for j in [0...parents.length] by 2
          res = eval("#{I}.#{symregr.CROSSOVER}(parents[j], parents[j+1])")
          children.push res[0]
          children.push res[1]
        newPopulation = newPopulation.concat(children)
        switch symregr.SELECTION
          when 'fpSelection'
            for _ in [0...symregr.MBS]
              mutant = eval "#{I}.#{symregr.SELECTION}(population, points, symregr.FITNESS, distribution)"
              newPopulation.push(eval("#{I}.#{symregr.MUTATION}(mutant)"))
          when 'susSelection'
            mutants = eval "#{I}.#{symregr.SELECTION}(population, points, symregr.FITNESS, symregr.MBS, distribution)"
            for mutant in mutants
              newPopulation.push(eval("#{I}.#{symregr.MUTATION}(mutant)"))
          when 'tournamentSelection'
            for _ in [0...symregr.MBS]
              mutt = eval "#{I}.#{symregr.SELECTION}(population, points, symregr.FITNESS, symregr.TSIZE, symregr.TPR)"
              newPopulation.push(eval("#{I}.#{symregr.MUTATION}(mutt)"))

        population = newPopulation
        fitnesses = for populant in population
          eval "populant.#{symregr.FITNESS}(points)"
        
        for pop, i in population
          if pop.tree.maxDepth() >= symregr.MDEPTH
            fitnesses[i] = 0

        bestFitnessInPopulation = fitnesses.reduce(max, 0)
        if bestFitnessInPopulation >= symregr.MAXFITNESS
          return unless symregr.FITNESS in ['scaledFitness', 'paretoFitness']
            Individual.particleSwarmOptimization(population[maxIndex], points)
          else
            scaledIndividual(
              Individual.particleSwarmOptimization(population[maxIndex], points), points, symregr.IDEPTH)
        if bestFitnessInPopulation > eval "bestIndividual.#{symregr.FITNESS}(points)"
          bestIndividual = population[maxIndex]

      unless symregr.FITNESS in ['scaledFitness', 'paretoFitness']
        Individual.particleSwarmOptimization(bestIndividual, points)
      else
        scaledIndividual(Individual.particleSwarmOptimization(bestIndividual, points), points, symregr.IDEPTH)
