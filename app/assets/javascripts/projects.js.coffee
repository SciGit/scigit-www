# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

project_id = null

fetchingChanges = false

parseResponseText = (responseText) ->
  try
    response = $.parseJSON(responseText)
  catch e
    return responseText

  list = '<ul>'
  for field, error of response
    field = field.substr(0, 1).toUpperCase() + field.substr(1)
    list += '<li><strong>' + field + '</strong> ' + error + '</li>'
  list += '</ul>'

  return '<strong>' + field + '</strong> ' + error if Object.keys(response).length <= 1
  return list

ajaxFormSubmit = (container, form) ->
  formData = $(form).serialize()

  btnSubmit = container.find('.btnSubmit')
  btnCancel = container.find('.btnCancel')
  alertSuccess = container.find('.alert-success')
  alertError = container.find('.alert-error')

  btnSubmitText = btnSubmit.html()
  btnSubmit.html('<i class="icon-spin icon-spinner"></i> Loading')
  btnSubmit.addClass('disabled')
  btnCancel.addClass('disabled')

  container.on('click', '.btnSubmit, .btnCancel', ->
    e.preventDefault()
  )

  $.ajax
    url: $(form).attr('action') + '.json',
    type: 'POST',
    data: formData,
    dataType: 'json',
    complete: (data) ->
      btnSubmit.html(btnSubmitText)
      btnSubmit.removeClass('disabled')
      btnCancel.removeClass('disabled')
      container.off('click', '.btnSubmit, .btnCancel')
    ,
    success: (data) ->
      @complete(data)
      alertSuccess.find('p').html(data)
      alertSuccess.show()
      alertError.hide()
      alert(JSON.stringify(data))
    ,
    error: (data) ->
      @complete(data)
      alertSuccess.hide()
      alertError.find('p').html(parseResponseText(data.responseText))
      alertError.show()
      alert(JSON.stringify(data))
    ,

hookCreateNewProject = ->
  $('#createNewProjectModal .btnSubmit').click (e) ->
    e.preventDefault()
    ajaxFormSubmit($('#createNewProjectModal'), $('#createProjectForm'))
    return false

hookCreateNewProjectPublicAndPrivateButtons = ->
  $('#createNewProjectModal').on('click', '#btnPrivate, #btnPublic', (e) ->
    e.preventDefault()

    projectPublic = $(@).attr('id') == 'btnPublic'

    $('#btnPrivate').addClass('active') if !projectPublic
    $('#btnPrivate').removeClass('active') if projectPublic
    $('#btnPublic').addClass('active') if projectPublic
    $('#btnPublic').removeClass('active') if !projectPublic

    $("input[id='hiddenPublic']").prop('checked', projectPublic)
  )

fetchAndAppendChanges = (page) ->
  fetchingChanges = true
  $('#changes table tbody').append '<tr id="loading-animation"><td><center><i class="icon-spin icon-spinner icon-3x"></i></center></td></tr>'
  $.ajax '/projects/' + project_id + '/changes/page/' + page,
    type: 'GET',
    success: (data) ->
      if !data
        $('body').infiniteScrollHelper 'destroy'
        if page == 1
          $('#changes table tbody').append '<tr><td>No changes have been made yet.</td></tr>'
      $('#changes table tbody').append data
      fetchingChanges = false
      $('#loading-animation').remove()
    failure: ->
      fetchingChanges = false
      $('#loading-animation').remove()

loadProjectId = ->
  project_id = $('#project_id').data 'project_id'

initInfiniteScrollHelper = ->
  $('body').infiniteScrollHelper
    loadMore: (page) ->
      fetchAndAppendChanges page
    ,
    doneLoading: ->
      return !fetchingChanges

$(document).on 'ready page:load', () ->
  hookCreateNewProject()
  hookCreateNewProjectPublicAndPrivateButtons()

  if loadProjectId()
    initInfiniteScrollHelper() if project_id
    fetchAndAppendChanges 1 if project_id
