# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$('[data-toggle~="tooltip"]').tooltip()
$('[data-toggle~="popover"]').popover()

$(document).on 'ready page:load', () ->
  $('#label-projects').click (e) ->
    if e.target == this or e.target.tagName.toLowerCase == 'div'
      Turbolinks.visit this.href

  $('.project').click (e) ->
    if e.target == this or e.target.tagName.toLowerCase == 'div'
      Turbolinks.visit('/projects/' + $(this).data('proj_id'))

  # This needs more work before it functions correctly.
  $('body').on 'click', '.change', (e) ->
    if e.target == this or e.target.tagName.toLowerCase == 'div'
      project_id = $(this).data('proj_id')
      change_id = $(this).data('change_id')
      Turbolinks.visit("/projects/#{project_id}/changes/#{change_id}/" )
  
  # Hack to scroll past the navbar.
  $(window).on 'hashchange', ->
    scrollBy(0, -50)
  # Hack: the above won't fire if you click the same anchor twice.
  # Detect when this happens and manually fire it.
  $('body').on 'click', '.hash-anchor', (e) ->
    window.location.hash = ''
    window.location.hash = $(this).prop('href').split('#')[1] || ''
    return false
