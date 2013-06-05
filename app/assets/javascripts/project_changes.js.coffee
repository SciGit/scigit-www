# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
#= require diffviewer

project_id = null

loadDiff = (selected) ->
  change_id = selected.data 'change-id'
  commit_hash = selected.data 'commit-hash'
  new DiffViewer(change_id, project_id, commit_hash)

$(document).on 'ready page:load', () ->
  change = $('#selected-change')
  if change.length > 0
    project_id = change.data 'project-id'
    loadDiff change
    cl = $('#change-listing')
    if cl.length > 0
      cl.affix(offset: { top: cl.position().top - 60 })
      cl.on 'click', 'li.change-item', (e) ->
        if !$(this).hasClass('active')
          $('#change-listing .active').removeClass 'active'
          $('#change-listing .in').collapse('toggle')
          $(this).addClass 'active'
          loadDiff $(this).find('a')
        else
          e.preventDefault()
          return true
        return false
