class @DiffViewer
  constructor: (@change_id, @project_id, @commit_hash) ->
    @files = $("#file-listing-#{@change_id}")
    @viewerPane = $('#diff-viewer')

    $.ajax {
      url: "/projects/#{@project_id}/changes/#{@change_id}/diff.json",
      type: "GET",
      cache: false,
      success: (json) => @displayDiff(json)
      error: (a, b, httpError) => @displayError(httpError)
    }

    @viewerPane.html '<center><i class="icon-spin icon-spinner icon-3x"></i></center>'

  displayDiff: (json) ->
    @files.html ''
    @viewerPane.html ''
    fileTypes =
      'createdFiles': 'Created Files',
      'deletedFiles': 'Deleted Files',
      'updatedFiles': 'Updated Files',
    fileNum = 0
    for type, name of fileTypes
      if json[type]?.length > 0
        @files.append "<li class='nav-header'>#{name}</li>"
        for file in json[type]
          elem = $("<li><a href='#change_file#{fileNum++}'>#{file.name}</a></li>")
          @files.append(elem)

    files = json.createdFiles.concat(json.deletedFiles).concat(json.updatedFiles)
    if files.length == 0
      # This shouldn't happen normally.
      @viewerPane.html 'No files were modified in this change.'

    for file, i in files
      pre = $('<pre>', {id: 'change_file' + i, class: 'highlight'})
      table = $('<table>', {class: 'table diff-text'})
      table.append "<tr><th colspan='3'>#{file.name}</th></tr>"
      if file.binary
        link = "scigit://view_change?project_id=#{@project_id}&commit_hash=#{@commit_hash}&filename=#{encodeURI(file.name)}"
        link = $('<a>', {href: link})
        link.html('View changes to this file on the SciGit client.')
        # hack to convert DOM element to HTML
        link = $('<div>').append(link).html()
        table.append "<tr class='message'><td class='content' colspan=3>" +
            "This file cannot be viewed as plain-text. #{link}</td></tr>"
      else
        if file.old_blocks.length == 0
          table.append "<tr class='message'><td class='content' colspan=3>" +
              "This file was empty.</td></tr>"
        else for _, j in file.old_blocks
          old_block = file.old_blocks[j]
          new_block = file.new_blocks[j]
          if !old_block? && !new_block?
            table.append "<tr class='change-omission'><td class='linenumber'>...</td>" +
              "<td class='linenumber'>...</td>" +
              "<td class='content'></td></tr>"
            continue
          block = old_block ? new_block
          type = ''
          type = 'change-addition' if block.type == '+'
          type = 'change-deletion' if block.type == '-'
          for line, k in block.lines
            old_line = if old_block?.start_line? then old_block.start_line + k else ''
            new_line = if new_block?.start_line? then new_block.start_line + k else ''
            table.append "<tr class='#{type}'><td class='linenumber'>#{old_line}</td>" +
              "<td class='linenumber'>#{new_line}</td>" +
              "<td class='content'>#{line}</td></tr>"
      pre.append(table)
      @viewerPane.append pre

  displayError: (error) ->
    @viewerPane.html "<div class='alert alert-error'>Error loading the specified change. Please try again later. (#{error})</div>"
