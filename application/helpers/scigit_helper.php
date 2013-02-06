<?

define('SCIGIT_DIR', '/var/scigit');
define('SCIGIT_REPO_DIR', '/var/scigit/repos');
define('SCIGIT_REPO_LIMIT', 16 * 1024 * 1024);

function is_ssl() {
  return isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] != 'off';
}

function get_user_id() {
  $CI = &get_instance();
  return $CI->tank_auth->get_user_id();
}

function check_login() {
  $CI = &get_instance();
  if (!$CI->tank_auth->is_logged_in(true)) {
    $http = (is_ssl() ? 'https' : 'http') . '://' . $_SERVER['HTTP_HOST'];
    $url = $http . '/' . $CI->uri->uri_string();
    $CI->session->set_flashdata('referer', $url);
    redirect($CI->config->item('secure_site_url') . '/auth/login');
  }
}

function is_logged_in() {
  $CI = &get_instance();
  return $CI->tank_auth->is_logged_in(true);
}

function get_user_username() {
  $CI = &get_instance();
  $user_id = $CI->tank_auth->get_user_id();
  $user = $CI->user->get_user_by_id($user_id, true);
  return $user->username;
}

function get_user_fullname() {
  $CI = &get_instance();
  $user_id = $CI->tank_auth->get_user_id();
  $user = $CI->user->get_user_by_id($user_id, true);
  return $user->fullname;
}

function check_project_perms($proj_id) {
  $CI = &get_instance();
  $proj = $CI->project->get($proj_id);
   if ($proj == null) {
    show_404();
  }
  if ($proj->public) return;
  $perm = $CI->permission->get_by_user_on_project(get_user_id(), $proj_id);
  if ($perm == null) {
    show_403();
  }
}

function check_project_admin($proj_id) {
  $CI = &get_instance();
 	if (!$CI->permission->is_admin(get_user_id(), $proj_id)) {
    show_403();
  }
}

function show_403() {
  show_error('Not authorized.', 403);
}

function format_user_fulltitle($user) {
  $fulltitle = "";
  if ($user->fullname) {
    $fulltitle .= $user->fullname;
    if ($user->title || $user->organization) {
      $fulltitle .= ", ";
    }
  }
  if ($user->title) {
    $fulltitle .= $user->title;
    if ($user->organization) {
      $fulltitle .= " at ";
    }
  }
  if ($user->organization) {
    $fulltitle .= $user->organization;
  }
  return $fulltitle;
}

class Node {
  public $path;
  public $name;
  public $type;
  public $size;
}

/* Getting repository files. */
function scigit_get_type($proj_id, $commit_hash, $path) {
  for ($i = strlen($path)-1; $i >= 0 && $path[$i] == '/'; $i--);
  $path = substr($path, 0, $i+1);

  $dir = SCIGIT_REPO_DIR . '/r' . $proj_id;
  $escape_path = escapeshellarg($path);
  exec("cd $dir; git ls-tree $commit_hash $escape_path", $listing);
  if (count($listing) == 1) {
    list($_, $type, $_, $_) = preg_split("/\\s+/", $listing[0]);
    return $type == 'blob' ? 'file' : 'dir';
  }
  return null;
}

function scigit_get_file($proj_id, $commit_hash, $path) {
  $dir = SCIGIT_REPO_DIR . '/r' . $proj_id;
  $escape_path = escapeshellarg($path);
	$handle = popen("cd $dir; git show $commit_hash:$escape_path", 'r');
	$output = '';
	while (!feof($handle)) {
		$output .= fread($handle, 1024);
	}
	return $output;
}

function scigit_get_listing($proj_id, $commit_hash, $path) {
  if ($path != '' && $path[strlen($path)-1] != '/') {
    $path .= '/';
  }

  $dir = SCIGIT_REPO_DIR . '/r' . $proj_id;
  $escape_path = escapeshellarg($path);
  exec("cd $dir; git ls-tree -l $commit_hash $escape_path", $listing);
  $ret = array();
  foreach ($listing as $item) {
    list($perm, $type, $hash, $size, $name) = preg_split("/\\s+/", $item, 5);
    $node = new Node();
    $name = exec("echo $name");
    $node->path = $name;
    $node->name = array_pop(explode('/', $name));
    $node->type = $type == 'blob' ? 'file' : 'dir';
    $node->size = $size;
    $ret[] = $node;
  }
  return $ret;
}

function scigit_get_diff($proj_id, $commit_hash, $path) {
  $dir = SCIGIT_REPO_DIR . '/r' . $proj_id;
  $escape_path = escapeshellarg($path);
	$handle = popen("cd $dir; git diff $commit_hash:$escape_path", 'r');
	$output = '';
	while (!feof($handle)) {
		$output .= fread($handle, 1024);
	}
	return $output;
}

function get_os() {
  $os_list = array(
    // Match user agent string with operating systems
    'iPhone' => '(iPhone)',
    'Windows 3.11' => 'Win16',
    'Windows 95' => '(Windows 95)|(Win95)|(Windows_95)',
    'Windows 98' => '(Windows 98)|(Win98)',
    'Windows 2000' => '(Windows NT 5.0)|(Windows 2000)',
    'Windows XP' => '(Windows NT 5.1)|(Windows XP)',
    'Windows Server 2003' => '(Windows NT 5.2)',
    'Windows Vista' => '(Windows NT 6.0)',
    'Windows 7' => '(Windows NT 7.0)',
    'Windows NT 4.0' => '(Windows NT 4.0)|(WinNT4.0)|(WinNT)|(Windows NT)',
    'Windows ME' => 'Windows ME',
    'Open BSD' => 'OpenBSD',
    'Sun OS' => 'SunOS',
    'Linux' => '(Linux)|(X11)',
    'Mac OS' => '(Safari)',
    'Mac OS' => '(Mac_PowerPC)|(Macintosh)|(Darwin)',
    'QNX' => 'QNX',
    'BeOS' => 'BeOS',
    'OS/2' => 'OS/2',
    'Search Bot'=>'(nuhk)|(Googlebot)|(Yammybot)|(Openbot)|(Slurp)|(MSNBot)|(Ask Jeeves/Teoma)|(ia_archiver)',
    'Unknown' => 'kjasjdfjkasdf',
  );

  // Loop through the array of user agents and matching operating systems
  foreach($os_list as $cur_os => $match) {
    // Find a match
    if (preg_match('/' . $match . '/i', $_SERVER['HTTP_USER_AGENT'])) {
      // We found the correct match
      break;
    }
  }

  return $cur_os;
}

function is_os_supported() {
  return strpos(get_os(), 'Windows') !== FALSE;
}

function time_ago($timestamp){
  $difference = time() - $timestamp;
  $unit = '';
  if($difference < 60)
    $unit = 'second';
  else{
    $difference = round($difference / 60);
    if($difference < 60)
      $unit = 'minute';
    else{
      $difference = round($difference / 60);
      if($difference < 24)
        $unit = 'hour';
      else{
        $difference = round($difference / 24);
        if($difference < 7)
          $unit = 'day';
        else {
          $difference = round($difference / 7);
          if ($difference < 4) {
            $unit = 'week';
          } else {
            $difference = round($difference / 4);
            if ($difference < 12) {
              $unit = 'month';
            } else {
              $difference = round($difference / 12);
              $unit = 'year';
            }
          }
        }
      }
    }
  }

  return "$difference $unit" .
        ($difference == 1 ? '' : 's') . ' ago';
}
