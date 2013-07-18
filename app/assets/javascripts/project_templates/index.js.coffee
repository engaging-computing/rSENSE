# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if namespace.controller is "project_templates" and namespace.action is "index"

    addItem = (object) ->
      newItem =   "<div class='item'>"

      if(object.mediaSrc)
        newItem += "<img src='#{object.mediaSrc}'></img>"

      newItem +=  "<h4 style='margin-top:0px;'><a href='#{object.url}'>#{object.name}</a>"

      if(object.featured)
        newItem += "<span style='color:#57C142'> (featured)</span>"

      newItem +=  "</h4><b>Owner: </b><a href='#{object.ownerUrl}'>#{object.ownerName}</a><br />"
      newItem +=  "<b>Created: </b>#{object.timeAgoInWords} ago (on #{object.createdAt})<br />"

      newItem +=  "</div>"

      newItem = $(newItem)

      ($ '#project_templates').append(newItem).isotope('insert', newItem)


    ($ "#project_templates_search").submit ->
        $.ajax
          url: this.action
          data: ($ this).serialize()
          dataType: "json"
          success: (data, textStatus)->

            ($ '#project_templates').isotope('remove', $('.item'))

            for object in data
              do (object) ->
                addItem object

            helpers.infinite_scroll(data.length, '#project_templates', '#project_templates_search', '#hidden_pagination', '#load_project_templates', addItem)

            ($ window).resize()

        return false

    ($ '.project_templates_filter_checkbox').click ->
      ($ '#project_templates_search').submit()

    ($ '.project_templates_sort_select').change ->
      ($ '#project_templates_search').submit()

    ($ ".project_templates_sort_select").change ->
      ($ "#project_templates_search").submit()

    helpers.isotope_layout('#project_templates')
    ($ "#project_templates_search").submit()

    ($ window).resize helpers.isotope_layout("#project_templates")