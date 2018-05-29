# Doug Salvati
# Honors project
# Fall 2017

# Coordinates of measurement
x1 = y1 = x2 = y2 = lastx = lasty = -1

iSENSESuccess = (pid) ->
  window.open('https://isenseproject.org/projects/' + pid, '_blank');

drawLine = (x1,y1,x2,y2) ->
  img = new Image()
  img.src = document.getElementById('measure-length-img').src
  img.onload = () ->
    canvas = document.getElementById('measure-length-canvas')
    canvas.height = img.height
    canvas.width = img.width
    ctx = canvas.getContext('2d')
    ctx.clearRect(0, 0, canvas.width, canvas.height)
    ctx.drawImage(img,0,0)
    ctx.beginPath()
    ctx.moveTo(x1, y1)
    ctx.lineTo(x2, y2)
    ctx.strokeStyle = '#00ff00'
    ctx.lineWidth = 5
    ctx.stroke()

$(document).ready ->
  $("#click-object-img").click (e) ->
    x = Math.round(e.pageX - $(this).offset().left)
    y = Math.round(e.pageY - $(this).offset().top)
    $("input[name=x]").val(x)
    $("input[name=y]").val(y)
    $("#click-object-next").show()
  $("#click-object-next").click (e) ->
    $("#click-object").hide()
    $("#measure-length").show()
    document.body.scrollTop = document.documentElement.scrollTop = 0
  $("#measure-length-canvas").bind 'touchmove mousemove', (e) ->
    click_x = if (e.originalEvent.type is "mousemove") then e.pageX else e.originalEvent.touches[0].pageX
    click_y = if (e.originalEvent.type is "mousemove") then e.pageY else e.originalEvent.touches[0].pageY
    if (x1 isnt -1) and (x2 is -1)
      drawLine(x1,y1,click_x - $(this).offset().left, click_y - $(this).offset().top); lastx = click_x; lasty = click_y
  $("#measure-length-canvas").bind 'touchstart mousedown', (e) ->
    #  Selecting 1st point - tap or mouse?
    click_x = if (e.originalEvent.type is "mousedown") then e.pageX else e.originalEvent.touches[0].pageX
    click_y = if (e.originalEvent.type is "mousedown") then e.pageY else e.originalEvent.touches[0].pageY
    x1 = Math.round(click_x - $(this).offset().left)
    y1 = Math.round(click_y - $(this).offset().top)
    $("#measure-length-next").hide()
  if $("#measure-length-img").length
    drawLine(x1,y1,x2,y2)
  $("#measure-length-canvas").bind 'touchend mouseup', (e) ->
    # Selecting 2nd point (need to calc dist)
    click_x = lastx
    click_y = lasty
    x2 = Math.round(click_x - $(this).offset().left)
    y2 = Math.round(click_y - $(this).offset().top)
    if (x1 == x2) and (y1 == y2)
      drawLine(x1,y1,x2,y2)
      x1 = x2 = y1 = y2 = -1
      return
    x_term = Math.pow(x2 - x1, 2)
    y_term = Math.pow(y2 - y1, 2)
    dist = Math.sqrt(x_term + y_term)
    if dist is 0
      dist = 1
    $("input[name=length]").val(Math.round(dist))
    drawLine(x1,y1,x2,y2)
    x1 = y1 = x2 = y2 = -1
    $("#measure-length-next").show()
  $('input[name=video]').change (e) ->
    if e.target.files.length
      $("#upload-next").show()
    else
      $("#upload-next").hide()
  $("#measure-length-next").click (e) ->
    $('#loading-screen').show()
  $("#upload-to-isense").click (e) ->
    $("#isense-form").show()
  $("#isense-use-custom").click (e) ->
    $("#isense-dset-2").val(""); $("#isense-name-2").val("")
    $("#isense-default").hide()
    $("#isense-custom").show()
  $("#isense-cancel").click (e) ->
    $("#isense-form").hide()
  $("#isense-submit").click (e) ->
    $("#isense-form").hide()
    for elt in $('input:visible')
      if !elt.value
        alert "Not everything filled out!"
        return
    # Get key information
    project = $("#isense-pid").val(); project = if project == "" then "3304" else project
    key = $("#isense-key").val(); key = if key == "" then "physics" else key
        # Field matching
    if project == "3304"
      title = $("#isense-dset-2").val(); title = if (title == "" or title == undefined) \
        then $("#isense-dset").val() else title
      yourname = $("#isense-name-2").val(); yourname = if (yourname == "" or yourname == undefined) \
        then $("#isense-name").val() else yourname
      field_matching = ["Time","X-Position","Y-Position","X-Velocity","Y-Velocity","X-Acceleration","Y-Acceleration"]
    else
      title = $("#isense-dset").val()
      yourname = $("#isense-name").val()
      field_matching = [$("#t").val(), $("#x").val(), $("#y").val(), $("#vx").val(), \
        $("#vy").val(), $("#ax").val(), $("#ay").val()]
    urlProject = 'http://isenseproject.org/api/v1/projects/' + project
    responseProject = $.ajax({ type: "GET", url: urlProject, async: false, dataType: "JSON"}).responseText
    fields = JSON.parse(responseProject).fields
    fids = {}
    for field in fields
      name = field.name
      idx = field_matching.indexOf(name)
      fids[idx] = field.id.toString()
    # Format data for iSENSE
    data = {}
    data[fids[0]] = $('#data-table td:nth-child(1)').map(() -> return $(this).text()).get()
    data[fids[1]] = $('#data-table td:nth-child(2)').map(() -> return $(this).text()).get()
    data[fids[2]] = $('#data-table td:nth-child(3)').map(() -> return $(this).text()).get()
    data[fids[3]] = $('#data-table td:nth-child(4)').map(() -> return $(this).text()).get()
    data[fids[4]] = $('#data-table td:nth-child(5)').map(() -> return $(this).text()).get()
    data[fids[5]] = $('#data-table td:nth-child(6)').map(() -> return $(this).text()).get()
    data[fids[6]] = $('#data-table td:nth-child(7)').map(() -> return $(this).text()).get()
    # Perform the upload
    apiUrl = 'https://isenseproject.org/api/v1/projects/' + project + '/jsonDataUpload'
    upload = {
      'title': title,
      'contribution_key': key,
      'contributor_name': yourname,
      'data': data
    }
    $.post(apiUrl, upload, () -> iSENSESuccess(project)).error(() ->
      alert "It failed... please check your details, they must be exact!")
