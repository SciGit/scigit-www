# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  project_id = $('#project_id').data('project_id')
  alert project_id
  return if !project_id?

  $('.changes').infinitescroll({
    dataType: 'json',
    appendCallback: false,
  }, (json, opts) ->
    alert 'end'
    page = opts.state.currPage;
    $.ajax '/project_changes/project/' + project_id + '/page/' + page,
      type: 'GET',
      data: { id: id },
      success: (data) ->
        alert data
  );
