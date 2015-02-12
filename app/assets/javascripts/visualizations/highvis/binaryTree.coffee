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
      # Returns number of nodes in the tree
      treeSize: ->
        if @data is null
          0
        else
          1 + @left.treeSize + @right.treeSize

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
      
      # Checks if the tree is terminal (i.e., no children)
      is_terminal: ->
        @left is null and @right is null


