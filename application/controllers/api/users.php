<?

require APPPATH.'/core/SciGit_REST_Controller.php';

class Users extends SciGit_REST_Controller
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

	public function public_keys_put() {
		$user = $this->authenticate();
		$name = $this->get_arg('name');
		$public_key = $this->get_arg('public_key');
		$this->load->model('public_key');
		if (!$name) $this->response(array('name' => 'required'), 400);

		if ($d = $this->public_key->parse_key($public_key)) {
      $key = $this->public_key->get_by_key($d['public_key']);
      if ($key !== null && $key->enabled) {
				$this->response(array('public_key' => 'duplicate_public_key'), 409);
      }
      if ($key !== null) {
        $this->public_key->update($key->id, $name);
        $this->response($d);
      } else if ($this->public_key->create($user->id, $name, $public_key)) {
				$this->response($d);
			} else {
				$this->error(500);
			}
		}
		$this->response(array('public_key' => 'invalid_public_key'), 400);
	}
}
