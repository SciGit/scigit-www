# Submits any form via AJAX. Greys out and disables buttons in the form,
# handles success and error messages, and redirects if necessary.
#
#  param @container    container element which contains any buttons outside
#                      the form that need to be greyed out
#  param @form         the form to be submitted via AJAX
window.ajaxFormSubmit = (container, form) ->
  parseSuccessResponseText = (data) ->
    spinner = '<i class="icon-spin icon-spinner"></i>'
    if data.url?
      setTimeout( ->
        Turbolinks.visit(data.url)
      , 2000)
      return data.notice + ' Loading. ' + spinner
    else
      return data.notice

  parseErrorResponseText = (data) ->
    responseText = data.responseText

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

  parseResponseText = (data, response) ->
    if response == 'success' then parseSuccessResponseText(data) else parseErrorResponseText(data)

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
    success: (data, response) ->
      @complete(data)
      alertSuccess.find('p').html(parseResponseText(data, response))
      alertSuccess.show()
      alertError.hide()
    ,
    error: (data, response) ->
      @complete(data)
      alertSuccess.hide()
      alertError.find('p').html(parseResponseText(data, response))
      alertError.show()
    ,
