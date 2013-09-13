# Place all the behaviors and hooks related to the projects index page here.

$ ->
  if namespace.controller is "projects" and namespace.action is "index"

    addItem = (object) ->
      newItem = """
        <div class='item word-break'>
          <h4 class='center' style='margin-top:0px;'><a href='#{object.url}'>#{object.name}</a>
          #{if object.featured then "<span style='color:#57C142'> (featured)</span>" else ""}</h4>
          #{if object.mediaSrc then "<div class='center'><a href='#{object.url}'><img src='#{object.mediaSrc}'></img></a></div>" else ""}
          <b>Owner: </b><a href='#{object.ownerUrl}'>#{object.ownerName}</a><br />
          <b>Created: </b>#{object.timeAgoInWords} ago (on #{object.createdAt})<br />
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

          addProjectButton = ($ "<div id='addProjectButton' style='text-align:center;cursor: pointer;' class='item'><img style='width:66%;' class='hoverimage' src='/assets/green_plus_icon.svg'><br /><h4 style='color:#0a0;'>Create Project</h4></img></div>")

          if logged_in?
            ($ '#projects').append(addProjectButton).isotope('insert', addProjectButton)
            ($ '#addProjectButton').click ->
              $.ajax
                url: "/projects/create"
                data: {}
                dataType: "json"
                success: (data, textStatus) ->
                  helpers.name_popup data, "Project", "project"
                  

          for object in data
            addItem object

          helpers.infinite_scroll(data.length, '#projects', '#projects_search', '#hidden_pagination', '#load_projects', addItem)

      return false

    ($ '.projects_filter_checkbox').click ->
      ($ '#projects_search').submit()

    ($ '.projects_sort_select').change ->
      ($ '#projects_search').submit()

    ($ '#template_checkbox').change ->
      ($ '#projects_search').submit()
      
    ($ window).resize () ->
      helpers.isotope_layout('#projects')

    helpers.isotope_layout('#projects')
    ($ "#projects_search").submit()
