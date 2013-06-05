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
      # cl.affix(offset: { top: cl.position().top - 60 })
      cl.on 'click', 'li.change-list-item', (e) ->
        if e.target.tagName.toLowerCase() == 'a'
          return true
        if !$(this).hasClass('active')
          # deactivate previously active element
          active = $('#change-listing .active')
          if active.length > 0
            active.removeClass 'active'
            message = active.find('.message')
            full = message.data('full-message')
            message.data('full-message', message.html())
            message.html(full)
          $('#change-listing .in').collapse('toggle')
          $('.action button i').removeClass 'icon-minus'
          $('.action button i').addClass 'icon-plus'
          # activate this element
          $(this).addClass 'active'
          message = $(this).find('.message')
          full = message.data('full-message')
          message.data('full-message', message.html())
          message.html(full)
          loadDiff $(this)
        else
          e.preventDefault()
          return true
        return false
      cl.on 'click', '.action button', (e) ->
        icon = $(this).find('i')
        icon.toggleClass 'icon-plus'
        icon.toggleClass 'icon-minus'
