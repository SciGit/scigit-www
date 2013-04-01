<?

function email_project_update($change, $to) {
  $CI = &get_instance();
  $project = $CI->project->get($change->proj_id);
  $user = $CI->user->get_user_by_id($change->user_id, true);

  $CI->postageapp->from('no-reply@scigit.com');
  $CI->postageapp->to($to->email);
  $CI->postageapp->subject("$project->name change: $change->commit_msg");

  $CI->postageapp->template('project_update');
  $CI->postageapp->variables(array(
    'site' => 'http://beta.scigit.com',
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

function email_register($user) {
  $CI = &get_instance();

  $CI->postageapp->from('no-reply@scigit.com');
  $CI->postageapp->to($user->email);
  $CI->postageapp->subject("Welcome to SciGit!");

  $CI->postageapp->template('validate_email');
  $CI->postageapp->variables(array(
    'site' => 'http://beta.scigit.com',
    'username' => $user->username,
    'user_id' => $user->id,
    'new_email_key' => $user->new_email_key,
  ));

  $CI->postageapp->send();
}

function email_add_to_project($from_user, $to_user, $project) {
  $CI = &get_instance();

  $CI->postageapp->from('no-reply@scigit.com');
  $CI->postageapp->to($to_user->email);
  $CI->postageapp->subject("Added to project $project->name");

  $CI->postageapp->template('add_to_project');
  $CI->postageapp->variables(array(
    'site' => 'http://beta.scigit.com',
    'user_name' => $from_user->username,
    'user_id' => $from_user->id,
    'proj_name' => $project->name,
    'proj_id' => $project->id,
  ));

  $CI->postageapp->send();
}

function email_invite_to_scigit($from_user, $to_email, $project, $permission) {
  $CI = &get_instance();

  $from_name = $from_user->fullname != null ? $from_user->fullname : $from_user->username;

  $CI->postageapp->from('no-reply@scigit.com');
  $CI->postageapp->to($to_email);
  $CI->postageapp->subject("$from_name has invited you to join SciGit!");

  $CI->postageapp->template('invite_to_scigit');
  $CI->postageapp->variables(array(
    'site' => 'http://beta.scigit.com',
    'user_name' => $from_name,
    'user_id' => $from_user->id,
    'proj_name' => $project->name,
    'proj_id' => $project->id,
    'hash' => $hash,
  ));
}
