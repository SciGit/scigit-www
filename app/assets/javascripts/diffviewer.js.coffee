class @DiffViewer
  constructor: (@change_id, @project_id, @commit_hash) ->
    @files = $("#file-listing-#{@change_id}")
    @viewerPane = $('#diff-viewer')

    $.ajax {
      url: "/projects/#{@project_id}/changes/#{@change_id}/diff.json",
      type: "GET",
      cache: false, # PLS DISABLE FOR PRODUCTION
      success: (json) => @displayDiff(json)
      error: (a, b, httpError) => @displayError(httpError)
    }

    @files.html '<li class="nav-header">' +
      '<i class="icon-spin icon-spinner"></i>&nbsp;&nbsp;Loading...</li>'
    @viewerPane.html '<center><i class="icon-spin icon-spinner icon-3x"></i></center>'

  displayDiff: (json) ->
    if !json.files_html? || !json.diff_viewer_html?
      @displayError "Invalid response"
      return

    @files.html json.files_html
    @viewerPane.html json.diff_viewer_html

    for div in @viewerPane.find('.diff-file')
      do (elem = $(div)) ->
        elem.on 'click', '.btn.inline', ->
          elem.find('tbody.inline').show()
          elem.find('tbody.side').hide()
          elem.find('.btn.inline').addClass('active')
          elem.find('.btn.side').removeClass('active')
        elem.on 'click', '.btn.side', ->
          elem.find('tbody.inline').hide()
          elem.find('tbody.side').show()
          elem.find('.btn.inline').removeClass('active')
          elem.find('.btn.side').addClass('active')

  displayError: (error) ->
    @files.html ''
    error_msg = "Error loading the specified change. Please try again later. (#{error})"
    @viewerPane.html "<div class='alert alert-error'>#{error_msg}</div>"
