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
    //'site' => 'http://scigit.com',
    'site' => 'http://localhost',
    'user_id' => $user->id,
    'user_name' => $user->username,
    'proj_id' => $project->id,
    'proj_name' => $project->name,
    'commit_id' => $change->id,
    'commit_msg' => $change->commit_msg,
    'commit_ts' => date("H:i d/m/Y", $change->commit_ts)
  ));

  var_dump($CI->postageapp->send());
}
