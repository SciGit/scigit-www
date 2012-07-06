<?

class Users extends REST_Controller
{
	public function profile_get() {
		$user = $this->authenticate();
		$id = $this->get_arg('user_id');
		if (!$id) $this->error(400);
		if ($profile = $this->user->get_user_by_id($id, 1)) {
			$this->response(array(
				'id' => $profile->id,
				'username' => $profile->username,
				'email' => $profile->email,	
			));
		} else {
			$this->error(404);
		}
	}
}
