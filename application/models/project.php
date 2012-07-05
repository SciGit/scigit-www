<?

class Project extends CI_Model
{
	public $proj_table = 'projects';
	public $proj_perms_table = 'proj_permissions';

	public function get($proj_id) {
		$this->db->where('id', $proj_id);
		$r = $this->db->get($this->proj_table)->result();
		if (empty($r)) return null;
		return $r[0];
	}

	public function get_for_user($user_id) {
		$this->db->select('*, projects.id as id');
		$this->db->where('user_id', $user_id);
		$this->db->join($this->proj_table, 'proj_id = projects.id');
		return $this->db->get($this->proj_perms_table)->result();
	}

	public function get_user_perms($user_id, $proj_id) {
		$this->db->where('user_id', $user_id);
		$this->db->where('proj_id', $proj_id);
		$r = $this->db->get($this->proj_perms_table)->result();
		if (empty($r)) return null;
		return $r[0];
	}

	public function get_perms($proj_id) {
		$this->db->select("*, $this->proj_perms_table.id as id");
		$this->db->where('proj_id', $proj_id);
		$this->db->join('users', 'users.id = user_id');
		return $this->db->get($this->proj_perms_table)->result();
	}

	public function set_user_perms($user_id, $proj_id, $write, $admin) {
		$data = array(
			'user_id' => $user_id,
			'proj_id' => $proj_id,
			'can_write' => $write,
			'can_admin' => $admin,
		);
		if ($this->get_user_perms($user_id, $proj_id) !== null) {
			$this->db->where('user_id', $user_id);
			$this->db->where('proj_id', $proj_id);
			return $this->db->update($this->proj_perms_table, $data);
		} else {
			return $this->db->insert($this->proj_perms_table, $data);
		}
	}
}
