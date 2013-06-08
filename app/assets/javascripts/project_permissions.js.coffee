# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

hookSubmitAddMember = ->
  submitAddMemberForm = (e) ->
    e.preventDefault()
    window.ajaxFormSubmit($('#addMemberModal'), $('#addMemberForm'))
    return false

  $('#addMemberModal').on('submit', '#addMemberForm', submitAddMemberForm)
  $('#addMemberModal .btnSubmit').click submitAddMemberForm

hookTypeaheadForMemberAdd = ->
  $('#addMemberModal').on 'shown', ->
    checkIfQueryIsValidEmail = ->
      regex = /\S+@\S+\.\S+/
      return regex.test($('#project_permission_user_attributes_email').data('typeahead').query)

    # XXX: Hack. We should investigate why modals are being closed on any
    # button press. It seems that if they don't have an href element,
    # clicking on them closes any currently active modal.
    $('#btnFindMember').click (e) -> e.preventDefault()

    indicateButton = (btnClass, iconClass, showPopover = null) ->
      $('#btnFindMember').removeClass('btn-info btn-success btn-danger btn-primary').addClass(btnClass)
      $('#btnFindMember i').removeClass('icon-search icon-spin icon-spinner icon-remove icon-ok').addClass(iconClass)

      if showPopover == true
        $('#findMember').popover('show')
        $('#project_permission_user_attributes_email').focus()
      else if showPopover == false
        $('#findMember').popover('hide')

    indicateSearch = ->
      indicateButton('btn-info', 'icon-search', false)
    indicateLoading = ->
      indicateButton('btn-primary', 'icon-spin icon-spinner')
    indicateNotFound = (showPopover) ->
      indicateButton('btn-danger', 'icon-remove', showPopover)
    indicateFound = ->
      indicateButton('btn-success', 'icon-ok', false)

    closePopovers = (excludeFindMember = false) ->
      $('#findMember').popover('hide') if !excludeFindMember
      $('#invalidEmailPopover').popover('hide')
      $('#permissionHeader').popover('hide')
      $('#addMemberModal .btnSubmit').popover('hide')

    styleButtonAsAddMember = ->
      closePopovers()
      $('#addMemberModal .btnSubmit').removeClass('btn-success btn-danger disabled').addClass('btn-primary')
                                     .html('Add Member').prop('disabled', false)
                                     .data('invite', false)
    styleButtonAsInvite = ->
      button = $('#addMemberModal .btnSubmit')
      button.removeClass('btn-primary').data('invite', true)

      if $('input[name="project_permission[permission]"]:checked').val() > 0 && checkIfQueryIsValidEmail()
        button.removeClass('btn-danger disabled').addClass('btn-success')
              .html('Invite').prop('disabled', false)
      else
        button.removeClass('btn-success').addClass('btn-danger disabled')
              .html('<i class="icon-remove"></i> Invite').prop('disabled', 'disabled')

    previousResults = []
    findResultWithLabel = (label) ->
      for _, result of previousResults
        if result.label == label
          return result

    $('#findMember').popover
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

    $('#invalidEmailPopover').popover
      html: true,
      title: 'Invalid Email Address',
      trigger: 'manual',
      placement: 'right',
      content: 'Please enter a valid email address (ex. john@gmail.com)'

    hookPermissionButtonClick = ->
      $('#invalidEmailPopover').popover('hide')

      if $('input[name="project_permission[permission]"]:checked').val() > 0
        $('#addMemberModal .btnSubmit').popover('show')
      else
        $('#permissionHeader').popover('show')

        $('.permission .btn').click (e) ->
          return if $(@).attr('disabled') == 'disabled'

          styleButtonAsInvite()

          $('#permissionHeader').popover('hide')
          $('#addMemberModal .btnSubmit').popover('show')

    $('#addMemberModal').on('click', '#btnInviteMember', (e) ->
      $('#findMember').popover('hide')
      styleButtonAsInvite()

      $('#project_permission_user_attributes_email').focus()

      return $('#invalidEmailPopover').popover('show') if !checkIfQueryIsValidEmail()

      indicateFound()

      if $('input[name="project_permission[permission]"]:checked').val() > 0
        $('#new_project_permission').submit()
      else
        hookPermissionButtonClick()
    )

    $('.permission .btn').click (e) ->
      e.preventDefault()
      return if $(@).attr('disabled') == 'disabled'

      $('.permission .btn input[type="radio"]').prop('checked', false)
      $('.permission').addClass('faded')
      $(@).parent('.permission').removeClass('faded')
      $(@).find('input[type="radio"]').prop('checked', 'checked')

    $('#addMemberModal').on('keypress', '#project_permission_user_attributes_email', indicateLoading)

    $('#project_permission_user_attributes_email').typeahead(
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

            if dataLength == 0 && $('#addMemberModal .btnSubmit').data('invite')
              styleButtonAsInvite()
              if checkIfQueryIsValidEmail()
                indicateFound()
                hookPermissionButtonClick()
              else
                indicateNotFound(false) # don't show the "Not Found, Invite" popover
                $('#addMemberModal .btnSubmit').popover('hide')
                $('#permissionHeader').popover('hide')
                $('#invalidEmailPopover').popover('show')
            else
              closePopovers(true) # exclude the "User Not Found" popover
              styleButtonAsAddMember() if dataLength > 0
              switch dataLength
                when 0 then indicateNotFound(true) # show the "Not Found, Invite" popover
                when 1 then indicateFound()
                else indicateSearch()

            # Hack. Focus on the input element after a set of elements is processed.
            setTimeout( ->
              $('#project_permission_user_attributes_email').focus()
            , 50)

            return process(results)
      ,
      updater: (item) ->
        indicateFound()
        return findResultWithLabel(item).email
      ,
    )

$(document).on 'ready page:load', () ->
  hookTypeaheadForMemberAdd()
  hookSubmitAddMember()
