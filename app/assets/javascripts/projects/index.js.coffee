# Place all the behaviors and hooks related to the projects index page here.

$ ->
  if namespace.controller is "projects" and namespace.action is "index"

    ($ '.mainContent').on 'click', 'div.clickableItem', (event) ->
      window.location = ($ event.currentTarget).children('a').attr 'href'

    addItem = (object) ->
      newItem = """
        <div class='item clickableItem'>
          <a href='#{object.url}'></a>
          #{if object.mediaSrc then "<div class='caroucell' style='height:120px; background-image:url(#{object.mediaSrc})'></div>" else ""}
          <div style="padding:7px">
            <div style="font-size:1.2em; font-weight:bold;">#{object.name} #{if object.featured then "<span style='color:#57C142'> (featured)</span>" else ""}</div>
            by <a href='#{object.ownerUrl}'>#{object.ownerName}</a><br />
            on #{object.createdAt}<br />
            <div style="display:table; width:100%; margin-top:10px;">
              <div style="display:table-cell"><i class="fa fa-flask"/> #{object.dataSetCount}</div>
              <div style="display:table-cell"><i class="fa fa-eye"/> #{object.viewCount}</div>
              <div style="display:table-cell"><i class="fa fa-thumbs-up"/> #{object.likeCount}</div>
            </div>
          </div>
       </div>
      """
      newItem = ($ newItem)

      ($ '#projects').append(newItem).isotope('insert', newItem)


    ($ '#projects_search').submit ->

      ($ '#hidden_pagination').val(1)

      dataObject = ($ this).serialize()
      dataObject += "&per_page=#{constants.INFINITE_SCROLL_ITEMS_PER}"

      $.ajax
        url: this.action
        data: dataObject
        dataType: "json"
        success: (data, textStatus)->

          ($ '#projects').isotope('remove', ($ '.item'))

          for object in data
            addItem object

          helpers.infinite_scroll(data.length, '#projects', '#projects_search', '#hidden_pagination', '#load_projects', addItem)

      return false

    ($ '.projects_filter_checkbox').click ->
      ($ '#projects_search').submit()
    
    ($ '.projects_sort_select').change ->
      ($ '#projects_search').submit()

    ($ '#template_checkbox').click ->
      ($ '#projects_search').submit()
    
    ($ '#curated_checkbox').click ->
      ($ '#projects_search').submit()
      
    relayout = ->
      helpers.isotope_layout('#projects')
    
    ($ window).resize () ->
      setTimeout(relayout,750)

    helpers.isotope_layout('#projects')
    ($ "#projects_search").submit()
    
    ($ '#addProjectButton').click ->
      $.ajax
        url: "/projects/create"
        data: {}
        dataType: "json"
        success: (data, textStatus) ->
          helpers.name_popup data, "Project", "project"