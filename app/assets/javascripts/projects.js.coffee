# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

project_id = null

fetchingChanges = false

ajaxFormSubmit = (form) ->
  formData = $(form).serialize()

  btnSubmit = form.find('.btnSubmit')
  btnCancel = form.find('.btnCancel')

  btnSubmit.val('Loading')
  btnSubmit.addClass('disabled')
  btnCancel.addClass('disabled')

  $.ajax
    url: $(form).attr('action'),
    type: 'POST',
    data: formData,
    dataType: 'json',
    complete: (data) ->
      btnSubmit.val('Create')
      btnSubmit.removeClass('disabled')
      btnCancel.removeClass('disabled')
    ,
    success: (data) ->
      @complete(data)
      alert(JSON.stringify(data))
    ,
    error: (data) ->
      @complete(data)
      alert(data)
    ,

hookCreateNewProject = ->
  $('#submitCreateNewProject').click (e) ->
    e.preventDefault()
    ajaxFormSubmit($('#createProjectForm'))
    return false

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

  if loadProjectId()
    initInfiniteScrollHelper() if project_id
    fetchAndAppendChanges 1 if project_id
