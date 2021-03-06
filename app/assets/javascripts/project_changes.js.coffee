# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
#= require diffviewer

project_id = null
diff_viewer = null

toggleActive = (active) ->
  active.toggleClass 'active'
  message = active.find('.message')
  full = message.data('full-message')
  message.data('full-message', message.html())
  message.html(full)

resetActives = ->
  active = $('#change-listing .active')
  if active.length > 0
    toggleActive active
  $('#change-listing .in').collapse('toggle')
  $('.action button i').removeClass 'fa-minus'
  $('.action button i').addClass 'fa-plus'

loadDiff = (selected) ->
  change_id = selected.data 'change-id'
  commit_hash = selected.data 'commit-hash'
  match = location.search.match /\?file=(.*)/
  file = if match then match[1] else ''

  url = "/projects/#{project_id}/changes/#{change_id}" + location.search
  history.replaceState null, null, url
  if diff_viewer == null
    diff_viewer = new DiffViewer(change_id, project_id, commit_hash, file)
  else
    diff_viewer.load(change_id, project_id, commit_hash, file)

$(document).on 'ready page:load', () ->
  change = $('#selected-change')
  if change.length > 0
    project_id = change.data 'project-id'
    loadDiff change
    cl = $('#change-listing')
    if cl.length > 0
      #cl.affix(offset: { top: cl.position().top - 60 })
      cl.on 'click', 'li.change-list-item', (e) ->
        if e.target.tagName.toLowerCase() == 'a'
          return true
        if !$(this).hasClass('active')
          resetActives()
          toggleActive $(this)
          loadDiff $(this)
        else
          e.preventDefault()
          return true
        return false
      cl.on 'click', '.action button', (e) ->
        icon = $(this).find('i')
        icon.toggleClass 'fa-plus'
        icon.toggleClass 'fa-minus'
