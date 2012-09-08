<?

class Change extends CI_Model
{
	public $table = 'proj_changes';

	public function get($id) {
		$this->db->where('id', $id);
		$r = $this->db->get($this->table)->result();
		if (empty($r)) return null;
		return $r[0];
	}

	public function get_by_project($proj_id, $limit = 0) {
		$this->db->select("*, $this->table.id AS id");
		$this->db->where('proj_id', $proj_id);
		$this->db->join('users', 'users.id = user_id');
		$this->db->order_by("$this->table.id DESC");
		if ($limit) {
			$this->db->limit($limit);
		}

		return $this->db->get($this->table)->result();
	}

	public function get_type($id, $path) {
		$change = $this->get($id);
		if ($change == null) return null;
		return scigit_get_type($change->proj_id, $change->commit_hash, $path);
	}

	public function get_file($id, $path) {
		$change = $this->get($id);
		if ($change == null) return null;
		return scigit_get_file($change->proj_id, $change->commit_hash, $path);
	}

	public function get_listing($id, $path) {
		$change = $this->get($id);
		if ($change == null) return null;
		return scigit_get_listing($change->proj_id, $change->commit_hash, $path);
	}
}
