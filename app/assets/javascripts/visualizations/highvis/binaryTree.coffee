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
#               will be used to represent infix expressions in my        #
#               symbolic regression implementation.                      #
##########################################################################


$ ->

  if namespace.controller is "visualizations" and
  namespace.action in ["displayVis", "embedVis", "show"]
    
    class window.binaryTree

      constructor: (parent = null) ->
        @data = null
        @right = null
        @left = null
        @parent = parent
      
      # Returns deep copy of binary tree object
      @clone: (tree, parent = null) ->
        console.log tree
        return tree if tree is null or typeof tree isnt 'object'
        temp = new binaryTree(parent)
        for key of tree when (typeof tree[key] isnt 'function' and key isnt 'parent')
          temp[key] = @clone(tree[key], tree)
        temp

      # Returns true if a and b are equivalent objects 
      # (not necessarily references to the same object in memory).
      @is_equal: (a, b) ->
        recur = false
        if a is null and b is null
          return true
        if Object.keys(a).length == Object.keys(b).length
          for key of a when key isnt 'parent'
            console.log a[key], b[key]
            if typeof(a[key]) is 'object'
              recur = @is_equal(a[key], b[key])
            else if a[key] != b[key]
              return false
        recur

      # Checks if the tree is terminal (i.e., no children)
      is_terminal: ->
        @left is null and @right is null

      # Returns number of nodes in the tree
      treeSize: ->
        if this.is_terminal() is true
          if @data isnt null 
            return 1
          else
            return 0
        else if @left is null and @right isnt null
          1 + @right.treeSize()
        else if @left isnt null and @right is null
          1 + @left.treeSize()
        else
          1 + @left.treeSize() + @right.treeSize()

      # Returns the maximum depth of the tree
      maxDepth: (curDepth = 0) ->
        [a, b, c, d] = [0, 0, 0, 0]
        if @data is null
          a = curDepth
          console.log this
          console.log 0
        else if @data isnt null and this.is_terminal
          console.log this
          console.log 1
          b = curDepth + 1
        else if @right is null
          console.log this
          console.log 1 + @left.maxDepth
          c = @left.maxDepth(curDepth + 1)
        else if @left is null
          console.log this
          console.log 1 + @right.maxDepth
          d = @right.maxDepth(curDepth + 1)
        return Math.max(a, b, c, d)

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
              @left = new binaryTree(this)
              @left.data = data

          else
            console.log "Error inserting #{data} into left child of tree."
        else if pos is 'right'
          if @data isnt null
            if @right is null
              @right = new binaryTree(this)
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
          if @right.is_terminal
            @right = null 
          else
            console.log "Error deleting #{@right.data}, results in invalid binary tree."
        else if pos is 'left'
          if @left.is_terminal
            @left = null
          else
            console.log "Error deleting #{@left.data}, results in invalid binary tree."
        else
          if this.is_terminal
            @data = null
          else
            console.log "Error deleting #{@data}, results in invalid binary tree."

    # Insert a new tree starting at the location specified, or at pos = 'right' or pos = 'left'
    # insertTree: (tree, pos = null) ->
    #   if pos is 'right'
    #     @right = @clone(tree)
    #   else if pos is 'left'
    #     @left = @clone(tree)
    #   else
    #     this = @clone(tree)

