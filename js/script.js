var decodeValidationErrors = function(errors) {
  var message = '';
  for (var error in errors) {
    message += '<p>' + errors[error] + '</p>';
  }
  return message;
}
