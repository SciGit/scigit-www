class @DiffViewer
  constructor: (change_id, project_id, commit_hash, file) ->
    @req = null
    @load(change_id, project_id, commit_hash, file)

  load: (change_id, project_id, commit_hash, file) ->
    @viewerPane = $('#diff-viewer')
    @files = $("#file-listing-#{change_id}")
    if @req != null
      @req.abort()
    @req = $.ajax {
      url: "/projects/#{project_id}/changes/#{change_id}/diff.json?file=#{file || ''}",
      type: "GET",
      cache: false, # PLS DISABLE FOR PRODUCTION
      success: (json) => @displayDiff(json)
      error: (a, b, httpError) => @displayError(httpError)
    }

    @files.html '<div class="change-type-header">' +
      '<i class="fa fa-spin fa-spinner"></i>&nbsp;&nbsp;Loading...</div>'
    @viewerPane.html '<center><i class="fa fa-spin fa-spinner fa-3x"></i></center>'

  displayDiff: (json) ->
    if !json.files_html? || !json.diff_viewer_html?
      @displayError "Invalid response"
      return

    @files.html json.files_html
    @viewerPane.html json.diff_viewer_html

    for div in @viewerPane.find('.diff-file')
      do (elem = $(div)) ->
        elem.on 'mouseover', 'span.modify, td.modify', ->
          match = $(this).attr('class').match(/modify-[0-9]+/)
          match? && $('.' + match[0]).addClass('hover')
        elem.on 'mouseout', 'span.modify, td.modify', ->
          match = $(this).attr('class').match(/modify-[0-9]+/)
          match? && $('.' + match[0]).removeClass('hover')
        elem.on 'click', '.btn.inline', ->
          elem.find('tbody.inline').removeClass('hidden')
          elem.find('tbody.side').addClass('hidden')
        elem.on 'click', '.btn.side', ->
          elem.find('tbody.inline').addClass('hidden')
          elem.find('tbody.side').removeClass('hidden')

  displayError: (error) ->
    @files.html ''
    error_msg = "Error loading the specified change. Please try again later. (#{error})"
    @viewerPane.html "<div class='alert alert-error'>#{error_msg}</div>"
