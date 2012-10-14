<?

function email_project_update($proj_id, $user_id, $change_id) {
  $CI = &get_instance();
  $project = $CI->project->get($proj_id);
  $user = $CI->user->get_user_by_id($user_id, true);
  $change = $CI->change->get($change_id);

  $CI->postageapp->from('test@scigit.com');
  $CI->postageapp->to('doug@sherk.me');
  $CI->postageapp->subject('Test!');
  $CI->postageapp->message('Test message');

  $CI->postageapp->template('project_update');
  $CI->postageapp->variables(array(
    'username' => $user->username,
    'project' => $project->name,
    'commit_msg' => $change->commit_msg,
    'commit_ts' => date("H:i d/m/Y", $change->commit_ts)
  ));

  var_dump($CI->postageapp->send());
}
