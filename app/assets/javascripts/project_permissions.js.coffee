# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

hookTypeaheadForMemberAdd = ->
  addTypeaheadForMemberAdd = ->

    previousResults = []
    findResultWithLabel = (label) ->
      for _, result of previousResults
        if result.label == label
          return result

    $('#project_permission_user_email').typeahead(
      source: (query, process) ->
        results = []
        $.ajax
          url: $(@$element[0]).data('target')
          type: 'GET',
          dataType: 'json',
          data: { term: @query }
          success: (data) ->
            previousResults = data

            for _, result of data
              results.push(result.label)

            return process(results)
      ,
      updater: (item) ->
        return findResultWithLabel(item).email
      ,
    )

    $('#addMemberModal').off('shown', addTypeaheadForMemberAdd)

  $('#addMemberModal').on('shown', addTypeaheadForMemberAdd)

$(document).on 'ready page:load', () ->
  hookTypeaheadForMemberAdd()
