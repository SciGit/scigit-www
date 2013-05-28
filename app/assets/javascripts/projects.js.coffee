# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

project_id = null

fetchingChanges = false

fetchAndAppendChanges = (page) ->
  fetchingChanges = true
  $.ajax '/projects/' + project_id + '/changes/page/' + page,
    type: 'GET',
    success: (data) ->
      $('body').infiniteScrollHelper 'destroy' if !data
      $('#changes table tbody').append data
      fetchingChanges = false
    failure: ->
      fetchingChanges = false

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
