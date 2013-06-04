# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

hookTypeaheadForMemberAdd = ->
  addTypeaheadForMemberAdd = ->

    indicateButton = (btnClass, iconClass, showPopover = null) ->
      $('#btnFindMember').removeClass('btn-info btn-success btn-danger btn-primary').addClass(btnClass)
                         .html('<i class="' + iconClass + '"></i>')

      if showPopover == true
        $('#btnFindMember').popover('show')
      else if showPopover == false
        $('#btnFindMember').popover('hide')

    indicateSearch = ->
      indicateButton('btn-info', 'icon-search', false)
    indicateLoading = ->
      indicateButton('btn-primary', 'icon-spin icon-spinner')
    indicateNotFound = ->
      indicateButton('btn-danger', 'icon-remove', true)
    indicateFound = ->
      indicateButton('btn-success', 'icon-ok', false)

    previousResults = []
    findResultWithLabel = (label) ->
      for _, result of previousResults
        if result.label == label
          return result

    $('#btnFindMember').popover
      html: true,
      title: 'Not Found',
      trigger: 'manual',
      content: '<div class="text-center"><p>You can invite this person to SciGit</p><a id="btnInviteMember" class="btn btn-success">Invite</a></div>',

    $('#permissionHeader').popover
      html: true,
      title: 'Choose a Permission',
      trigger: 'manual',
      placement: 'right',
      content: '<h6>Please choose a permission for this person when they join</h6>',

    $('#addMemberModal .btnSubmit').popover
      html: true,
      title: 'Ready to Invite',
      trigger: 'manual',
      placement: 'left',
      content: 'You are ready to invite this person!',

    $('#addMemberModal').on('click', '#btnInviteMember', (e) ->
      $('#btnFindMember').popover('hide')

      if $('input[name="project_permission[permission]"]:checked').val() > 0
        indicateFound()
        $('#new_project_permission').submit()
      else
        $('#permissionHeader').popover('show')

        $('.permission .btn').click (e) ->
          return if $(@).attr('disabled') == 'disabled'

          $('#permissionHeader').popover('hide')
          $('#addMemberModal .btnSubmit').popover('show')
          indicateFound()
    )

    $('.permission .btn').click (e) ->
      e.preventDefault()
      return if $(@).attr('disabled') == 'disabled'

      $('.permission .btn input[type="radio"]').prop('checked', false)
      $(@).find('input[type="radio"]').prop('checked', 'checked')

    $('#addMemberModal').on('keypress', '#project_permission_user_email', indicateLoading)

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

            dataLength = Object.keys(data).length
            switch Object.keys(data).length
              when 0 then indicateNotFound()
              when 1 then indicateFound()
              else indicateSearch()

            return process(results)
      ,
      updater: (item) ->
        indicateFound()
        return findResultWithLabel(item).email
      ,
    )

    $('#addMemberModal').off('shown', addTypeaheadForMemberAdd)

  $('#addMemberModal').on('shown', addTypeaheadForMemberAdd)

$(document).on 'ready page:load', () ->
  hookTypeaheadForMemberAdd()
