# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$('[data-toggle~="tooltip"]').tooltip()

$(document).on 'ready page:load', () ->
  $('#label-projects').click (e) ->
    if e.target == this or e.target.tagName.toLowerCase == 'div'
      Turbolinks.visit this.href

  $('.project').click (e) ->
    if e.target == this or e.target.tagName.toLowerCase == 'div'
      Turbolinks.visit('/projects/' + this.getAttribute('data-proj_id'))

  # This needs more work before it functions correctly.
  $('.change').click (e) ->
    if e.target == this or e.target.tagName.toLowerCase == 'div'
      Turbolinks.visit('/changes/view/' + this.getAttribute('data-change_id'))
