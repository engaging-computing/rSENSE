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
# File:         Binary Tree                                              #
#                                                                        #
# Description:  This file defines a modified binary tree that            #
#               will be used to represent prefix expressions in my       #
#               symbolic regression implementation.                      #
##########################################################################


$ ->
  if namespace.controller is 'visualizations' and
  namespace.action in ['displayVis', 'embedVis', 'show']
    window.symregr ?= {}
    symregr.add = (a, b) -> a + b
    symregr.subtract = (a, b) -> a - b
    symregr.multiply = (a, b) -> a * b
    symregr.safeDiv = (a, b) -> if b is 0 then 1 else a / b
    symregr.pow = (a, b) -> Math.pow(a, b)
    symregr.exp = (a) -> Math.exp(a)
    symregr.cos = (a) -> Math.cos(a)
    symregr.sin = (a) -> Math.sin(a)
    symregr.safeLog = (a) -> Math.log(Math.abs(a))
    symregr.safeSqrt = (a) -> Math.sqrt(Math.abs(a))
    class window.BinaryTree extends Object

      # Initial ephemeral constant value on the interval [-1, 1)
      @ephemeralConstant:  Math.random() * 2 - 1

      @terminals = [
        'x', 'ec'
      ]

      @operators = [
        symregr.add, symregr.subtract, symregr.multiply, symregr.safeDiv, symregr.pow,
        symregr.exp, symregr.cos, symregr.sin, symregr.safeLog, symregr.safeSqrt
      ]

      constructor: (parent = null) ->
        @data = null
        @right = null
        @left = null
        @parent = parent

      # Returns deep copy of binary tree object
      @clone: (tree, parent = null) ->
        return tree if tree is null or typeof tree isnt 'object'
        temp = new BinaryTree(parent)
        for key of tree when (typeof(tree[key]) isnt 'function' and key isnt 'parent')
          temp[key] = @clone(tree[key], temp)
        temp['data'] = tree.data
        temp

      # Returns true if a and b are equivalent objects
      # (not necessarily references to the same object in memory).
      @isEqual: (a, b) ->
        [leftEq, rightEq] = [true, true]
        if a is null and b isnt null or a isnt null and b is null
          return false
        if (a.isTerminal() and b.isTerminal()) is true and a.data is b.data
          return true
        if '' + a.data isnt '' + b.data or a.treeSize() isnt b.treeSize() or a.maxDepth() isnt b.maxDepth()
          return false
        if a.left isnt null and b.left isnt null
          leftEq = BinaryTree.isEqual(a.left, b.left)
        if a.right isnt null and b.right isnt null
          rightEq = BinaryTree.isEqual(a.right, b.right)
        leftEq and rightEq

      # Checks if the tree is terminal (i.e., no children)
      isTerminal: ->
        @left is null and @right is null

      # Returns number of nodes in the tree
      treeSize: ->
        @__query((a, b) -> a + b)

      # Returns the maximum depth of the tree
      maxDepth: ->
        @__query(Math.max)

      # Internal method used to abstract the treeSize() and maxDepth()
      # member functions
      ###
      # WARNING:  INTERNAL METHOD.  DO NOT CALL.
      ###
      __query: (combiner) ->
        rest = 0
        if @left? and @left isnt null
          rest = combiner(rest, @left.__query(combiner))
        if @right? and @right isnt null
          rest = combiner(rest, @right.__query(combiner))
        return 1 + rest

      # Inserts a single datum in the tree at @data,
      # or the @data member of the tree located at
      # pos = 'left' or pos = 'right'
      ###
      # WARNING:  MUTATES THE BINARY TREE
      ###
      insertData: (data, pos = null) ->
        if pos is 'left'
          if @data is null
            console.log "Error inserting #{data} into left child of tree."
            return
          if @left is null
            @left = new BinaryTree(@)
          @left.data = data
        else if pos is 'right'
          if @data is null
            console.log "Error inserting #{data} into right child of tree."
            return
          if @right is null
            @right = new BinaryTree(@)
          @right.data = data
        else
          @data = data

      # Delete a single datum in the tree at @data,
      # or the @data member of the tree located at
      # pos = 'left' or pos = 'right'
      ###
      # WARNING:  MUTATES THE BINARY TREE
      ###
      deleteData: (pos = null) ->
        if pos is 'right'
          if @right.isTerminal()
            @right = null
            return
          console.log "Error deleting #{@right.data}, results in invalid binary tree."
          null
        else if pos is 'left'
          if @left.isTerminal()
            @left = null
            return
          console.log "Error deleting #{@left.data}, results in invalid binary tree."
          null
        else
          if @isTerminal()
            @data = null
            return
          console.log "Error deleting #{@data}, results in invalid binary tree."
          null

      # Allows the user to index into the tree, following Preorder traversal:
      # ROOT, left, right
      index: (index) ->
        @__access(index)

      # Determine how far away the node at position 'index' is from the root
      # of the binary tree.  This is used to determine how long the mutation
      # tree at a given point can be to maintain the maximum depth of the
      # tree during the point mutation genetic operation.
      depthAtPoint: (index, curDepth = 1) ->
        @__access(index, false, curDepth)

      # Internal method used to abstract the index and depth at point member
      # functions.
      ###
      # WARNING:  INTERNAL METHOD.  DO NOT CALL
      ###
      __access: (index, value = true, curDepth = 1) ->
        if index is 0
          return if value is true then @ else curDepth
        leftSize = if @left is null then 0 else @left.treeSize()
        rightSize = if @right is null then 0 else @right.treeSize()
        if index > leftSize + rightSize
          -1
        else if index > leftSize
          if @right isnt null then @right.__access(index - leftSize - 1, value, curDepth + 1) else -1
        else
          if @left isnt null then @left.__access(index - 1, value, curDepth + 1) else -1

      # Given a tree, replace it with a randomly-generated tree whose maximum
      # depth is given by maxDepth.
      ###
      # WARNING:  MUTATES THE BINARY TREE
      ###
      generate: (maxDepth = 10, curDepth = 1) ->
        if curDepth is maxDepth
          @insertData(BinaryTree.terminals[Math.floor(Math.random() * BinaryTree.terminals.length)])
        else
          randomGene = Math.floor(Math.random() * (BinaryTree.terminals.length + BinaryTree.operators.length))
          if randomGene < BinaryTree.terminals.length
            @insertData(BinaryTree.terminals[randomGene])
          else
            gene = BinaryTree.operators[randomGene - BinaryTree.terminals.length]
            @insertData(gene)
            @left = new BinaryTree(@)
            @left.generate(maxDepth, curDepth + 1)
            if gene.length isnt 1
              @right = new BinaryTree(@)
              @right.generate(maxDepth, curDepth + 1)

      # Evaluate the Binary tree numerically for a given input value
      evaluate: (x, val = null) ->
        if @data is 'x'
          if val isnt null then val else x
        else if @data is 'ec'
          BinaryTree.ephemeralConstant
        else if typeof(@data) is 'number'
          @data
        else
          if @data.length is 1
            @data(@left.evaluate(x))
          else
            @data(@left.evaluate(x), @right.evaluate(x))

      # Insert the BinaryTree object 'tree' at the location of the BinaryTree
      # specified by index
      ###
      # WARNING:  MUTATES THE BINARY TREE 'THIS', DOES NOT MUTATE ARGUMENT TREE
      ###
      insertTree: (tree, index = 0) ->
        replacementPoint = @index(index)
        if index is null or replacementPoint is -1
          console.log "Error inserting #{tree} at location specified.  Index does not exist in the tree."
          return null
        start = replacementPoint.parent
        if start isnt null
          if start.left isnt null and BinaryTree.isEqual(replacementPoint, start.left)
            start.left = BinaryTree.clone(tree)
          else
            if start.right isnt null and BinaryTree.isEqual(replacementPoint, start.right)
              start.right = BinaryTree.clone(tree)
          start.__updateParents()
        else
          @data = tree.data
          @right = BinaryTree.clone(tree.right)
          @left = BinaryTree.clone(tree.left)
          @parent = null
          @__updateParents()

      # Updates binary tree element's parents to reflect the result of
      # an insertTree merger to parent.right or parent.left
      ###
      # WARNING:  MUTATES THE BINARY TREE
      ###
      ###
      # WARNING:  INTERNAL METHOD.  DO NOT CALL.
      ###
      __updateParents: ->
        if @right isnt null
          @right = BinaryTree.clone(@right, @)
          @right.__updateParents()
        if @left isnt null
          @left = BinaryTree.clone(@left, @)
          @left.__updateParents()

      # Given two parent trees, create two new child trees by crossover.
      # Both parent trees are given a randomly-selected crossover point.
      # The first child is the part of the first parent before its crossover
      # point, and the section of the second parent after its crossover point.
      # The second child is the part of the first parent after its crossover
      # point, and the part of the second parent before its crossover point.

      @crossover: (tree1, tree2) ->
        [tree1a, tree1b] = [BinaryTree.clone(tree1), BinaryTree.clone(tree1)]
        [tree2a, tree2b] = [BinaryTree.clone(tree2), BinaryTree.clone(tree2)]

        [crossoverPointOne, crossoverPointTwo] =
          [Math.floor(Math.random() * tree1.treeSize()), Math.floor(Math.random() * tree2.treeSize())]
        [childOne, childTwo] = [BinaryTree.clone(tree1a), BinaryTree.clone(tree2a)]
        childOne.insertTree(childTwo.index(crossoverPointTwo), crossoverPointOne)
        childTwo.insertTree(tree1b.index(crossoverPointOne), crossoverPointTwo)
        [childOne, childTwo]

      # Given a tree, construct a string representation of the mathematical
      # function the tree describes
      @stringify: (tree) ->

        # Helper method to properly parenthesize nested terms
        parenthesize = (string) ->
          if not isNaN(Number(string)) or string is 'x' then string else "(#{string})"

        switch tree.data
          when symregr.add
            "#{parenthesize(@stringify(tree.left))} + #{parenthesize(@stringify(tree.right))}"
          when symregr.subtract
            "#{parenthesize(@stringify(tree.left))} - #{parenthesize(@stringify(tree.right))}"
          when symregr.multiply
            "#{parenthesize(@stringify(tree.left))} * #{parenthesize(@stringify(tree.right))}"
          when symregr.safeDiv
            "#{parenthesize(@stringify(tree.left))} / #{parenthesize(@stringify(tree.right))}"
          when symregr.pow
            "#{parenthesize(@stringify(tree.left))} <sup>#{parenthesize(@stringify(tree.right))}</sup>"
          when symregr.exp
            "e <sup>#{parenthesize(@stringify(tree.left))}</sup>"
          when symregr.cos
            "cos(#{parenthesize(@stringify(tree.left))})"
          when symregr.sin
            "sin(#{parenthesize(@stringify(tree.left))})"
          when symregr.safeLog
            "log(|#{parenthesize(@stringify(tree.left))}|)"
          when symregr.safeSqrt
            "sqrt(|#{parenthesize(@stringify(tree.left))}|)"
          when 'x'
            'x'
          when 'ec'
            "#{roundToFourSigFigs(BinaryTree.ephemeralConstant)}"
          else
            "#{roundToFourSigFigs(tree.data)}"

      # Given a tree, construct a string of valid coffeescript code that can be 'evaled' to
      # mimic the symbolic regression.
      @codify: (tree) ->
        # Helper method to properly parenthesize nested terms
        parenthesize = (string) ->
          if not isNaN(Number(string)) or string is 'x' then string else "(#{string})"

        getFunc = (tree) ->
          switch tree.data
            when symregr.add
              "symregr.add(#{parenthesize(getFunc(tree.left))}, #{parenthesize(getFunc(tree.right))})"
            when symregr.subtract
              "symregr.subtract(#{parenthesize(getFunc(tree.left))}, #{parenthesize(getFunc(tree.right))})"
            when symregr.multiply
              "symregr.multiply(#{parenthesize(getFunc(tree.left))}, #{parenthesize(getFunc(tree.right))})"
            when symregr.safeDiv
              "symregr.safeDiv(#{parenthesize(getFunc(tree.left))}, #{parenthesize(getFunc(tree.right))})"
            when symregr.pow
              "symregr.pow(#{parenthesize(getFunc(tree.left))}, #{parenthesize(getFunc(tree.right))})"
            when symregr.exp
              "symregr.exp(#{parenthesize(getFunc(tree.left))})"
            when symregr.cos
              "symregr.cos(#{parenthesize(getFunc(tree.left))})"
            when symregr.sin
              "symregr.sin(#{parenthesize(getFunc(tree.left))})"
            when symregr.safeLog
              "symregr.safeLog(#{parenthesize(getFunc(tree.left))})"
            when symregr.safeSqrt
              "symregr.safeSqrt(#{parenthesize(getFunc(tree.left))})"
            when 'x'
              'x'
            when 'ec'
              "#{BinaryTree.ephemeralConstant}"
            else
              "#{tree.data}"

        'return ' + getFunc(tree)
