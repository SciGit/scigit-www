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

    $('#projectPrivate').addClass('hide') if projectPublic
    $('#projectPrivate').removeClass('hide') if !projectPublic
    $('#projectPublic').addClass('hide') if !projectPublic
    $('#projectPublic').removeClass('hide') if projectPublic

    $("input[id='hiddenPublic']").prop('checked', projectPublic)
  )

fetchAndAppendChanges = (page) ->
  fetchingChanges = true
  $('#changes table tbody').append '<div class="well-list-item"><div class="well-list-item-inner well-list-item-empty"><center><i class="fa fa-spin fa-spinner fa-3x"></i></center></div></div>'
  $.ajax '/projects/' + project_id + '/changes/page/' + page,
    type: 'GET',
    success: (data) ->
      if !data
        $('body').infiniteScrollHelper 'destroy'
        if page == 1
          $('#changes').append '<div class="well-list-item"><div class="well-list-item-inner well-list-item-empty">No changes have been made yet.</div></div>'
      $('#changes').append data
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

  $('#btnEditDescription').click (e) ->
    $('#description').toggleClass('hide')
    $('#editDescription').toggleClass('hide')
    e.preventDefault()
