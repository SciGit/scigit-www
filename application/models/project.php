<?

class Project extends CI_Model
{
	public $proj_table = 'projects';
	public $proj_perms_table = 'proj_permissions';
	public $proj_member_table = 'proj_membership';

	public function get($proj_id) {
		$this->db->where('id', $proj_id);
		$r = $this->db->get($this->proj_table)->result();
		if (empty($r)) return null;
		return $r[0];
	}

	public function get_by_owner($user_id) {
		$this->db->where('owner_id', $user_id);
		return $this->db->get($this->proj_table)->result();
	}

	public function get_by_name($name) {
		$this->db->like('name', $name);
		$r = $this->db->get($this->proj_table)->result();
		if (empty($r)) return null;
		return $r[0];
	}

	public function get_user_accessible($user_id, $public_only = false, $count_only = false) {
		$this->db->select('*, projects.id as id');
		$this->db->where('user_id', $user_id);
    if ($public_only) {
      $this->db->where('public', 1);
    }
		$this->db->join($this->proj_table, 'proj_id = projects.id');
    if ($count_only) {
      return $this->db->count_all_results($this->proj_perms_table);
    }
		return $this->db->get($this->proj_perms_table)->result();
	}

	// Membership = union of subscribed and owned projects.
	// It's assumed that nothing owned is in the membership table
	public function get_user_membership($user_id) {
		$projects = $this->get_user_subscriptions($user_id);
		$this->db->where('owner_id', $user_id);
		foreach ($this->db->get($this->proj_table)->result() as $proj) {
			$projects[] = $proj;
		}
		return $projects;
	}

	// Subscribed = only in proj_membership table.
	public function get_user_subscriptions($user_id, $public_only = false, $count_only = false) {
		$this->db->select('*, projects.id as id');
		$this->db->where('user_id', $user_id);
    if ($public_only) {
      $this->db->where('public', 1);
    }
		$this->db->join($this->proj_table, 'proj_id = projects.id');
    if ($count_only) {
      return $this->db->count_all_results($this->proj_member_table);
    }
		return $this->db->get($this->proj_member_table)->result();
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
       FROM $this->proj_member_table
       WHERE $this->proj_table.id = $this->proj_member_table.proj_id) AS member_count
       FROM $this->proj_table
       WHERE public = 1
       ORDER BY member_count DESC";
    return $this->db->query($query)->result();
  }

  public function search_by_name_and_desc($search) {
    $search = mysql_real_escape_string($search);
    $query = "SELECT *,
              (SELECT COUNT(*)
              FROM $this->proj_member_table
              WHERE $this->proj_table.id = $this->proj_member_table.proj_id) AS member_count
              FROM $this->proj_table
              WHERE (`name` LIKE '%$search%'
              OR description LIKE '%$search%')
              AND public = 1
              ORDER BY
              CASE WHEN instr(name, '$search') = 1 THEN 1 ELSE 0 END,
              member_count DESC";
    return $this->db->query($query)->result();
  }

	public function get_user_perms($user_id, $proj_id) {
		$this->db->where('user_id', $user_id);
		$this->db->where('proj_id', $proj_id);
		$r = $this->db->get($this->proj_perms_table)->result();
		if (empty($r)) return null;
		return $r[0];
	}

	public function get_perms($proj_id, $count_only = false) {
		$this->db->select("*, $this->proj_perms_table.id as id");
		$this->db->where('proj_id', $proj_id);
		$this->db->join('users', 'users.id = user_id');
    if ($count_only) {
      return $this->db->count_all_results($this->proj_perms_table);
    }
		return $this->db->get($this->proj_perms_table)->result();
	}

	public function is_admin($user_id, $proj_id) {
		$this->db->where('user_id', $user_id);
		$this->db->where('proj_id', $proj_id);
		$r = $this->db->get($this->proj_perms_table)->result();
		if (empty($r)) return false;
		return $r[0]->can_admin;
	}

	public function is_member($user_id, $proj_id) {
		$this->db->where('user_id', $user_id);
		$this->db->where('proj_id', $proj_id);
		$r = $this->db->get($this->proj_member_table)->result();
		if (empty($r)) return false;
		return true;
	}

	public function add_member($user_id, $proj_id) {
		$this->db->insert($this->proj_member_table, array(
			'user_id' => $user_id,
			'proj_id' => $proj_id,
		));
	}

	public function delete_member($user_id, $proj_id) {
		$this->db->where('user_id', $user_id);
		$this->db->where('proj_id', $proj_id);
		$this->db->delete($this->proj_member_table);
	}

	public function create($user_id, $name, $public) {
		$data = array(
			'name' => $name,
			'owner_id' => $user_id,
			'public' => $public,
			'created_ts' => time(),
		);
		if (!$this->db->insert($this->proj_table, $data)) return null;
		$data['id'] = $this->db->insert_id();
		try {
			$this->load->library('scigit_thrift');
			Scigit_thrift::createRepository($data['id']);
			$this->db->insert($this->proj_perms_table, array(
				'proj_id' => $data['id'],
				'user_id' => $user_id,
				'can_write' => 1,
				'can_admin' => 1,
			));
		} catch (Exception $e) {
			$this->db->where('id', $data['id']);
			$this->db->delete($this->proj_table);
			log_message('error', 'project: ' . $e->getMessage());
			return null;
		}
		return $data;
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
			$this->db->update($this->proj_perms_table, $data);
		} else {
			$this->db->insert($this->proj_perms_table, $data);
		}
		return true;
	}

  public function set_public($proj_id, $public) {
    $data = array(
      'public' => intval(!!$public),
    );
    $this->db->where('id', $proj_id);
    $this->db->update($this->proj_table, $data);
    return true;
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

		$this->db->where('proj_id', $proj_id);
		$this->db->delete($this->proj_member_table);

		try {
			$this->load->library('scigit_thrift');
			Scigit_thrift::deleteRepository($proj_id);
		} catch (Exception $e) {
			log_message('error', 'project: ' . $e->getMessage());
		}
	}
}
