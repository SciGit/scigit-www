<?

require_once '/var/scigit/include/scigit.php';

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

function check_project_perms($proj_id) {
	$CI = &get_instance();
	if ($CI->project->get($proj_id) == null) {
		show_404();
	}
	$perm = $CI->project->get_user_perms(get_user_id(), $proj_id);
	if ($perm == null) {
		show_403();
	}
}

function check_project_admin($proj_id) {
	$CI = &get_instance();
	$perm = $CI->project->get_user_perms(get_user_id(), $proj_id);
	if ($perm == null) {
		show_404();
	}
	if (!$perm->can_admin) {
		show_403();
	}
}

function show_403() {
	show_error('Not authorized.', 403);
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
	exec("cd $dir; git show $commit_hash:$escape_path", $file);
	return implode("\n", $file);
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
