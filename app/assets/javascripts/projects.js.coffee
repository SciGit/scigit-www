# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

project_id = null

fetchingChanges = false

hookSubmitCreateNewProject = ->
  submitCreateNewProject = (e) ->
    e.preventDefault()
    window.ajaxFormSubmit($('#createNewProjectModal'), $('#createNewProjectForm'))
    return false

  $('#createNewProjectModal').on('submit', '#createNewProjectForm', submitCreateNewProject)
  $('#createNewProjectModal').on('click', '.btnSubmit', submitCreateNewProject)

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
  hookSubmitCreateNewProject()
  hookCreateNewProjectPublicAndPrivateButtons()

  if loadProjectId()
    initInfiniteScrollHelper() if project_id
    fetchAndAppendChanges 1 if project_id
