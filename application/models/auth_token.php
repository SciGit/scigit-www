<?

class Auth_token extends CI_Model
{
	public $table = 'user_auth_tokens';
	public $expiry_time = 86400; // 1 day

	public function authenticate($user_id, $token) {
		$this->db->where('user_id', $user_id);
		$this->db->where('auth_token' , $token);
		$r = $this->db->get($this->table)->result();
		if (empty($r) || $r[0]->expiry_ts < time()) return false;
		return true;
	}

	public function delete($user_id, $auth_token) {
		$this->db->where('user_id' , $user_id);
		$this->db->where('auth_token', $auth_token);
		$this->db->delete($this->table);
		return $this->db->affected_rows();
	}

	public function create($user_id) {
		$this->db->where('expiry_ts <', time());
		$this->db->delete($this->table);

		$expiry_ts = time() + $this->expiry_time;

		// Renew if it's from the same IP
		$this->db->where('user_id', $user_id);
		$this->db->where('ip_address', $this->input->ip_address());
		$r = $this->db->get($this->table)->result();
		if (count($r)) {
			$t = $r[0];
			$this->db->where('id', $t->id);
			$this->db->update($this->table, array(
				'expiry_ts' => $expiry_ts
			));
			return array('auth_token' => $t->auth_token, 
			 						 'expiry_ts' => $expiry_ts);
		}

		// Practically impossible, but just in case
		while (1) {
			$token = md5(microtime() . rand() . $user_id);
			$this->db->where('user_id', $user_id);
			$this->db->where('auth_token', $token);
			$r = $this->db->get($this->table)->result();
			if (empty($r)) {
				break;
			}
		}

		$data = array(
			'user_id' => $user_id,
			'auth_token' => $token,
			'ip_address' => $this->input->ip_address(),
			'created_ts' => time(),
			'expiry_ts' => $expiry_ts,
		);

		if ($this->db->insert($this->table, $data)) {
			return array('auth_token' => $token, 'expiry_ts' => $expiry_ts);
		}
		return null;
	}
}
