# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

project_id = null

fetchingChanges = false

fetchAndAppendChanges = (page) ->
  fetchingChanges = true
  $('#changes table tbody').append '<tr id="loading-animation"><td><center><i class="icon-spin icon-spinner icon-3x"></i></center></td></tr>'
  $.ajax '/projects/' + project_id + '/changes/page/' + page,
    type: 'GET',
    success: (data) ->
      $('body').infiniteScrollHelper 'destroy' if !data
      $('#changes table tbody').append data
      fetchingChanges = false
      $('#loading-animation').remove()
    failure: ->
      fetchingChanges = false
      $('#loading-animation').remove()

$(document).on 'ready page:load', () ->
  project_id = $('#project_id').data 'project_id'
  return if !project_id?

  fetchAndAppendChanges 1

  $('body').infiniteScrollHelper
    loadMore: (page) ->
      fetchAndAppendChanges page
    ,
    doneLoading: ->
      return !fetchingChanges
