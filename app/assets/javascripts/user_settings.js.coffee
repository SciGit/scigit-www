$(document).on 'ready page:load', ->
  # Make tabs change the location's hash
  hash = window.location.hash
  hash && $('ul.nav a[href="' + hash + '"]').tab('show')
  console.log hash

  $('#settings-page .nav a').click (e) ->
    $(this).tab('show')
    history.replaceState({}, this.hash, this.hash)
