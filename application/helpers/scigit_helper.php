<?

function is_logged_in() {
	$CI = &get_instance();
	return $CI->tank_auth->is_logged_in(true);
}

function get_user_id() {
	$CI = &get_instance();
	return $CI->tank_auth->get_user_id();
}

