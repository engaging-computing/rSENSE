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

  if namespace.controller is "visualizations" and
  namespace.action in ["displayVis", "embedVis", "show"]
    window.add = (a, b) -> a + b
    window.subtract = (a, b) -> a - b
    window.multiply = (a, b) -> a * b
    window.safeDiv = (a, b) -> if b is 0 then 1 else a / b
    window.pow = (a, b) -> Math.pow(a, b)
    window.exp = (a) -> Math.exp(a)
    window.cos = (a) -> Math.cos(a)
    window.sin = (a) -> Math.sin(a)
    window.safeLog = (a) -> Math.log(Math.abs(a))
    window.safeSqrt = (a) -> Math.sqrt(Math.abs(a))
    class window.binaryTree extends Object

      # Initial ephemeral constant value on the interval [-1, 1)
      @ephemeralConstant:  Math.random() * 2 - 1

      @terminals = [
        'x', 'ec'
      ]

      @operators = [
        add, subtract, multiply, safeDiv, pow, exp, cos, sin, safeLog, safeSqrt
      ]

      constructor: (parent = null) ->
        @data = null
        @right = null
        @left = null
        @parent = parent

      # Returns deep copy of binary tree object
      @clone: (tree, parent = null) ->
        return tree if tree is null or typeof tree isnt 'object'
        temp = new binaryTree(parent)
        for key of tree when (typeof(tree[key]) isnt 'function' and key isnt 'parent')
          temp[key] = @clone(tree[key], temp)
        temp['data'] = tree.data
        temp

      # Returns true if a and b are equivalent objects 
      # (not necessarily references to the same object in memory).
      @is_equal: (a, b) ->
        [leftEq, rightEq] = [true, true]
        if a is null and b isnt null or a isnt null and b is null
          return false
        if (a.is_terminal() and b.is_terminal()) is true and a.data is b.data
          return true
        if '' + a.data isnt '' + b.data or a.treeSize() isnt b.treeSize() or a.maxDepth() isnt b.maxDepth()
          return false
        if a.left isnt null and b.left isnt null
          leftEq = binaryTree.is_equal(a.left, b.left)
        if a.right isnt null and b.right isnt null
          rightEq = binaryTree.is_equal(a.right, b.right)
        leftEq and rightEq

      # Checks if the tree is terminal (i.e., no children)
      is_terminal: ->
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
        1 + rest
      
      # Inserts a single datum in the tree at @data, 
      # or the @data member of the tree located at 
      # pos = 'left' or pos = 'right'
      ###
      # WARNING:  MUTATES THE BINARY TREE
      ###
      insertData: (data, pos = null) ->
        if pos is 'left'
          if @data isnt null
            if @left is null
              @left = new binaryTree(@)
            @left.data = data

          else
            console.log "Error inserting #{data} into left child of tree."
        else if pos is 'right'
          if @data isnt null
            if @right is null
              @right = new binaryTree(@)
            @right.data = data
          else
            console.log "Error inserting #{data} into right child of tree."
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
          if @right.is_terminal()
            @right = null 
          else
            console.log "Error deleting #{@right.data}, results in invalid binary tree."
            null
        else if pos is 'left'
          if @left.is_terminal()
            @left = null
          else
            console.log "Error deleting #{@left.data}, results in invalid binary tree."
            null
        else
          if @is_terminal()
            @data = null
          else
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
          @insertData(window.binaryTree.terminals[Math.floor(Math.random() * window.binaryTree.terminals.length)])
        else
          randomGene = Math.floor(Math.random() * (binaryTree.terminals.length + binaryTree.operators.length))
          if randomGene < binaryTree.terminals.length
            @insertData(binaryTree.terminals[randomGene])
          else
            gene = binaryTree.operators[randomGene - binaryTree.terminals.length]
            @insertData(gene)
            @left = new binaryTree(@)
            @left.generate(maxDepth, curDepth + 1)
            if gene.length isnt 1
              @right = new binaryTree(@)
              @right.generate(maxDepth, curDepth + 1)

      # Evaluate the Binary tree numerically for a given input value
      evaluate: (x, val = null) ->
        if @data is 'x'
          if val isnt null then val else x
        else if @data is 'ec'
          binaryTree.ephemeralConstant
        else if typeof(@data) is 'number'
          @data
        else
          if @data.length is 1
            @data(@left.evaluate(x))
          else
            @data(@left.evaluate(x), @right.evaluate(x))

      # Insert the binaryTree object 'tree' at the location of the binaryTree 
      # specified by index
      ###
      # WARNING:  MUTATES THE BINARY TREE 'THIS', DOES NOT MUTATE ARGUMENT TREE
      ###
      insertTree: (tree, index = 0) ->
        replacementPoint = @index(index)
        if index is null or replacementPoint is -1
          console.log "Error inserting #{tree} at location specified.  Index does not exist in the tree."
          null
        else
          start = replacementPoint.parent
          if start isnt null
            if start.left isnt null and window.binaryTree.is_equal(replacementPoint, start.left)
              start.left = window.binaryTree.clone(tree)
            else
              if start.right isnt null and window.binaryTree.is_equal(replacementPoint, start.right)
                start.right = window.binaryTree.clone(tree)
            start.__updateParents()
          else

            @data = tree.data
            @right = binaryTree.clone(tree.right)
            @left = binaryTree.clone(tree.left)
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
          @right = window.binaryTree.clone(@right, @)
          @right.__updateParents()
        if @left isnt null
          @left = window.binaryTree.clone(@left, @)
          @left.__updateParents()

      # Given two parent trees, create two new child trees by crossover.
      # Both parent trees are given a randomly-selected crossover point.
      # The first child is the part of the first parent before its crossover
      # point, and the section of the second parent after its crossover point.
      # The second child is the part of the first parent after its crossover
      # point, and the part of the second parent before its crossover point.

      @crossover: (tree1, tree2) ->
        [tree1a, tree1b] = [window.binaryTree.clone(tree1), window.binaryTree.clone(tree1)]
        [tree2a, tree2b] = [window.binaryTree.clone(tree2), window.binaryTree.clone(tree2)]
        
        [crossoverPointOne, crossoverPointTwo] = \
        [Math.floor(Math.random() * tree1.treeSize()), Math.floor(Math.random() * tree2.treeSize())]
        [childOne, childTwo] = [window.binaryTree.clone(tree1a), window.binaryTree.clone(tree2a)]
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
          when window.add
            "#{parenthesize(@stringify(tree.left))} + #{parenthesize(@stringify(tree.right))}"

          when window.subtract
            "#{parenthesize(@stringify(tree.left))} - #{parenthesize(@stringify(tree.right))}"

          when window.multiply
            "#{parenthesize(@stringify(tree.left))} * #{parenthesize(@stringify(tree.right))}"

          when window.safeDiv
            "#{parenthesize(@stringify(tree.left))} / #{parenthesize(@stringify(tree.right))}"

          when window.pow
            "#{parenthesize(@stringify(tree.left))} <sup>#{parenthesize(@stringify(tree.right))}</sup>"

          when window.exp
            "e <sup>#{parenthesize(@stringify(tree.left))}</sup>"
          when window.cos
            "cos(#{parenthesize(@stringify(tree.left))})"
          when window.sin
            "sin(#{parenthesize(@stringify(tree.left))})"
          when window.safeLog
            "log(|#{parenthesize(@stringify(tree.left))}|)"
          when window.safeSqrt
            "sqrt(|#{parenthesize(@stringify(tree.left))}|)"
          when 'x'
            'x'
          when 'ec'
            "#{window.roundToFourSigFigs(binaryTree.ephemeralConstant)}"
          else
            #console.log tree.data
            "#{window.roundToFourSigFigs(tree.data)}"
    
      # Given a tree, construct a string of valid coffeescript code that can be 'evaled' to 
      # mimic the symbolic regression.
      @codify: (tree) ->
      # Helper method to properly parenthesize nested terms
        parenthesize = (string) -> 
          if not isNaN(Number(string)) or string is 'x' then string else "(#{string})"
        
        getFunc = (tree) ->
          switch tree.data
            when window.add
              "window.add(#{parenthesize(getFunc(tree.left))}, #{parenthesize(getFunc(tree.right))})"
              #"#{parenthesize(@stringify(tree.left))} + #{parenthesize(@stringify(tree.right))}"

            when window.subtract
              "window.subtract(#{parenthesize(getFunc(tree.left))}, #{parenthesize(getFunc(tree.right))})"
              #"#{parenthesize(@stringify(tree.left))} - #{parenthesize(@stringify(tree.right))}"

            when window.multiply
              "window.multiply(#{parenthesize(getFunc(tree.left))}, #{parenthesize(getFunc(tree.right))})"
              # "#{parenthesize(@stringify(tree.left))} * #{parenthesize(@stringify(tree.right))}"

            when window.safeDiv
              "window.safeDiv(#{parenthesize(getFunc(tree.left))}, #{parenthesize(getFunc(tree.right))})"
              # "#{parenthesize(@stringify(tree.left))} / #{parenthesize(@stringify(tree.right))}"

            when window.pow
              "window.pow(#{parenthesize(getFunc(tree.left))}, #{parenthesize(getFunc(tree.right))})"
              # "#{parenthesize(@stringify(tree.left))} <sup>#{parenthesize(@stringify(tree.right))}</sup>"

            when window.exp
              "window.exp(#{parenthesize(getFunc(tree.left))})"
              # "e <sup>#{parenthesize(@stringify(tree.left))}</sup>"
            when window.cos
              "window.cos(#{parenthesize(getFunc(tree.left))})"
              # "cos(#{parenthesize(@stringify(tree.left))})"
            when window.sin
              "window.sin(#{parenthesize(getFunc(tree.left))})"
              # "sin(#{parenthesize(@stringify(tree.left))})"
            when window.safeLog
              "window.safeLog(#{parenthesize(getFunc(tree.left))})"
              # "log(|#{parenthesize(@stringify(tree.left))}|)"
            when window.safeSqrt
              "window.safeSqrt(#{parenthesize(getFunc(tree.left))})"
              # "sqrt(|#{parenthesize(@stringify(tree.left))}|)"
            when 'x'
              'x'
            when 'ec'
              "#{binaryTree.ephemeralConstant}"
            else
              #console.log tree.data
              "#{tree.data}"
        'return ' + getFunc(tree)

    #create lambda from codify
    #window.wat = new Function("x", binaryTree.codify(a))
