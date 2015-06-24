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
$ ->
  if namespace.controller is 'visualizations' and
  namespace.action in ['displayVis', 'embedVis', 'show']

    class window.Photos extends BaseVis
      constructor: (@canvas) ->

      start: ->
        super()

      end: ->
        super()

      # Gets called when the controls are clicked and at start
      update: ->
        # Clear the old canvas
        canvas = '#' + @canvas
        $(canvas).html("")

        # load the Handlebars templates
        grpTemp = HandlebarsTemplates[hbVis('photo/group')]
        picTemp = HandlebarsTemplates[hbVis('photo/pic')]
        lbTemp = HandlebarsTemplates[hbVis('photo/lightbox')]

        # group the media
        groupedMedia = {}
        groupedMedia['all'] = []
        for _, dset of data.metadata
          label = "#{dset.name}(#{dset.dataset_id})"
          groupedMedia[label] = []
          for pic in dset.photos
            groupedMedia[label].push pic
            groupedMedia['all'].push pic

        # determine which data sets are selected based on the groupSelection
        # also, sort them because they move around otherwise
        selectedGroups = data.groupSelection.map (x) ->
          [x, data.groups[x]]
        selectedGroups.sort (x, y) ->
          x[0] > y[0]

        # create the groups to put the photos in
        id = 0
        for group in selectedGroups
          if groupedMedia[group[1]].length == 0
            continue

          groupContext =
            g_id: group[0]
            group_label: group[1]
          groupObj = $(grpTemp(groupContext))

          # put the photos in their correct groups
          for photo in groupedMedia[group[1]]
            photoContext =
              p_id: "pic-#{id}"
              tn_src: photo.tn_src
              src:    photo.src
              p_name: photo.name
              d_name: photo.dataSet.name
              d_id:   photo.dataSet.id
            photoObj = $(picTemp(photoContext))

            # set up the lightbox for each image
            photoObj.click photoContext, (e) ->
              ltboxObj = $(lbTemp(e.data))
              $(canvas).append(ltboxObj)
              $('#target-img').modal
                keyboard: true
              $('#target-img').on 'hidden.bs.modal', ->
                $('#target-img').remove()

            groupObj.children('.group-body').append(photoObj)

            id += 1

          $(canvas).append(groupObj)

      drawControls: ->
        super()

        @drawGroupControls([1, 2])

    if 'Photos' in data.relVis
      globals.photos = new Photos 'photos-canvas'
    else
      globals.photos = new DisabledVis 'photos-canvas'
