<?

function email_project_update($change_id, $to) {
  $CI = &get_instance();
  $change = $CI->change->get($change_id);
  $project = $CI->project->get($change->proj_id);
  $user = $CI->user->get_user_by_id($change->user_id, true);

  $CI->postageapp->from('no-reply@scigit.com');
  $CI->postageapp->to($to->email);
  $CI->postageapp->subject("$project->name change");
  $CI->postageapp->message(
    "$user->username has made a change to $project->name. \"$change->commit_msg\"");

  $CI->postageapp->template('project_update');
  $CI->postageapp->variables(array(
    'site' => 'http://scigit.com',
    'user_id' => $user->id,
    'user_name' => $user->username,
    'proj_id' => $project->id,
    'proj_name' => $project->name,
    'commit_id' => $change->id,
    'commit_msg' => $change->commit_msg,
    'commit_ts' => date("H:i d/m/Y", $change->commit_ts)
  ));

  $CI->postageapp->send();
}
