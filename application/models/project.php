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

	public function get_by_name($name) {
		$this->db->like('name', $name);
		$r = $this->db->get($this->proj_table)->result();
		if (empty($r)) return null;
		return $r[0];
	}

  public function get_by_popularity($per_page, $page) {
    // XXX: Yuck. Just use subscribers total as a metric.
    //$query =
    //  "SELECT a.weighting FROM
    //  (SELECT (1/(NOW() - proj_changes.commit_ts)) as weighting, proj_id FROM proj_changes) a
    //  ORDER BY a.weighting DESC";
    $query =
      "SELECT *,
       (SELECT COUNT(*)
       FROM $this->proj_perms_table
       WHERE $this->proj_table.id = $this->proj_perms_table.proj_id) AS member_count
       FROM $this->proj_table
       WHERE public = 1
       ORDER BY member_count DESC";
    return $this->db->query($query)->result();
  }

  public function search_by_name_and_desc($search) {
    $search = mysql_real_escape_string($search);
    $query = "SELECT *,
              (SELECT COUNT(*)
              FROM $this->proj_perms_table
              WHERE $this->proj_table.id = $this->proj_perms_table.proj_id) AS member_count
              FROM $this->proj_table
              WHERE (`name` LIKE '%$search%'
              OR description LIKE '%$search%')
              AND public = 1
              ORDER BY
              CASE WHEN instr(name, '$search') = 1 THEN 1 ELSE 0 END,
              member_count DESC";
    return $this->db->query($query)->result();
  }

	public function create($user_id, $name, $public) {
		$data = array(
			'name' => $name,
			'public' => $public,
			'created_ts' => time(),
		);
		if (!$this->db->insert($this->proj_table, $data)) return null;
		$data['id'] = $this->db->insert_id();
		try {
			$this->load->library('scigit_thrift');
			Scigit_thrift::createRepository($data['id']);
      // XXX: This should use constants and functions from Permission.
			$this->db->insert($this->proj_perms_table, array(
				'proj_id' => $data['id'],
				'user_id' => $user_id,
        'permission' => 16,
			));
		} catch (Exception $e) {
			$this->db->where('id', $data['id']);
			$this->db->delete($this->proj_table);
			log_message('error', 'project: ' . $e->getMessage());
			return null;
		}
		return $data;
	}

  public function set_description($proj_id, $description) {
    $data = array(
      'description' => $description,
    );
    $this->db->where('id', $proj_id);
    $this->db->update($this->proj_table, $data);
    return true;
  }

	public function delete($proj_id) {
		$this->db->where('id', $proj_id);
		$this->db->delete($this->proj_table);

		$this->db->where('proj_id', $proj_id);
		$this->db->delete($this->proj_perms_table);

		try {
			$this->load->library('scigit_thrift');
			Scigit_thrift::deleteRepository($proj_id);
		} catch (Exception $e) {
			log_message('error', 'project: ' . $e->getMessage());
		}
	}
}
