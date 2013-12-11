# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

hookSubmitAddMember = ->
  submitAddMemberForm = (e) ->
    e.preventDefault()
    window.ajaxFormSubmit($('#addMemberModal'), $('#addMemberForm'))
    return false

  $('#addMemberModal').on 'submit', '#addMemberForm', submitAddMemberForm
  $('#addMemberModal').on 'click', '.btnSubmit', submitAddMemberForm

hookTypeaheadForMemberAdd = ->
  $('#addMemberModal').on 'shown.bs.modal', ->
    checkIfQueryIsValidEmail = ->
      regex = /\S+@\S+\.\S+/
      return regex.test($('#project_permission_user_attributes_email').val())

    # XXX: Hack. We should investigate why modals are being closed on any
    # button press. It seems that if they don't have an href element,
    # clicking on them closes any currently active modal.
    $('#btnFindMember').click (e) -> e.preventDefault()

    indicateButton = (btnClass, iconClass, showPopover = null) ->
      $('#btnFindMember').removeClass('btn-primary btn-success btn-danger btn-primary').addClass(btnClass)
      $('#btnFindMember i').removeClass('fa-search fa-spin fa-spinner fa-times fa-check').addClass(iconClass)

      if showPopover == true
        $('#findMember').popover('show')
        $('#project_permission_user_attributes_email').focus()
      else if showPopover == false
        $('#findMember').popover('hide')

    indicateSearch = ->
      indicateButton('btn-primary', 'fa-search', false)
    indicateLoading = ->
      indicateButton('btn-primary', 'fa-spin fa-spinner')
    indicateNotFound = (showPopover) ->
      indicateButton('btn-danger', 'fa-times', showPopover)
    indicateFound = ->
      indicateButton('btn-success', 'fa-check', false)

    closePopovers = (excludeFindMember = false) ->
      $('#findMember').popover('hide') if !excludeFindMember
      $('#invalidEmailPopover').popover('hide')
      $('#permissionHeader').popover('hide')
      $('#addMemberModal .btnSubmit').popover('hide')

    styleButtonAsAddMember = ->
      closePopovers()
      $('#addMemberModal .btnSubmit').removeClass('btn-danger disabled').addClass('btn-success')
                                     .html('Add Member')
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
      placement: 'left',
      content: '<div class="text-center"><p>You can invite this person to SciGit</p><a id="btnInviteMember" class="btn btn-success">Invite</a></div>',

    $('#permissionHeader').popover
      html: true,
      title: 'Choose a Permission',
      trigger: 'manual',
      placement: 'left',
      content: 'Please choose a permission for this person that they will get when they join.',

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
      placement: 'left',
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

    # XXX: Temporarily fix radio buttons. When you click on the surrounding button,
    # the radio works ok. But if you click on the radio itself, something in the
    # prop('checked') code is fucking up and it's not getting set.
    setPermissionButtonFading = (button) ->
      $('.permission').addClass('faded')
      $(button).parents('.permission').removeClass('faded')

    $('.permission .btn input[type="radio"]').click (e) ->
      e.stopPropagation()
      return e.preventDefault() if $(@).parents('.btn').attr('disabled') == 'disabled'

      setPermissionButtonFading(@)

    $('.permission .btn').click (e) ->
      e.preventDefault()
      return if $(@).attr('disabled') == 'disabled'

      setPermissionButtonFading(@)
      $('.permission .btn input[type="radio"]').prop('checked', false)
      $(@).find('input[type="radio"]').prop('checked', 'checked')

    $('#addMemberModal').on('keypress', '#project_permission_user_attributes_email', indicateLoading)

    $('#project_permission_user_attributes_email').typeahead(
      name: 'user',
      remote:
        url: $('#project_permission_user_attributes_email').data('target') + '?term=%QUERY',
        filter: (parsedResponse) ->
          console.log parsedResponse

          dataLength = Object.keys(parsedResponse).length

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

          parsedResponse
    ).on('typeahead:selected', (item, items) ->
      $('#project_permission_user_attributes_email').typeahead(
        'setQuery',
        $('#project_permission_user_attributes_email').val().match(/\(([^\)]+)\)/)[1]
      )
      indicateFound()
    )

$(document).on 'ready page:load', () ->
  hookTypeaheadForMemberAdd()
  hookSubmitAddMember()
