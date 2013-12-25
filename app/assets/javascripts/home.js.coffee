# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready page:load', () ->
  $('[data-toggle*="tooltip"], [rel="tooltip"]').tooltip(container: 'body')
  $('[data-toggle*="popover"]').popover(container: 'body')

  $('.modal').on 'shown.bs.modal', (e) ->
    $(@).find('[data-toggle*="tooltip"], [rel="tooltip"]').tooltip(container: '#' + $(@).attr('id') + ' .modal-content')
    $(@).find('[data-toggle*="popover"]').popover(container: '#' + $(@).attr('id') + ' .modal-content')

  # TODO: These should all be removed in favor of the data-url tag.
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

  # Force reloads of modals where the button clicked to trigger them specifies
  # its own custom remote URL.
  $('[data-toggle="modal"]').click (e) ->
    href = $(@).attr("href")
    target = $($(@).data("target"))
    if href? && href != '#' && href != ''
      target.load(href, -> target.modal("show"))
    else
      target.load(target.data("remote"), -> target.modal("show"))
    e.preventDefault()

  $('[data-url]').click (e) ->
    tags = ["a", "i", "button", "p", "span"]
    if e.target == @ || e.target.tagName.toLowerCase() not in tags
      url = $(@).data('url')
      Turbolinks.visit(url)
