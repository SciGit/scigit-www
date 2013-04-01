<?

class Permission extends CI_Model
{
  public $projects_table = 'projects';
  public $permission_table = 'proj_permissions';

  const NONE = 0;
  const SUBSCRIBER = 1;
  const READ = 2;
  const WRITE = 4;
  const ADMIN = 8;
  const OWNER = 16;

  // Permissions sets. These are combined flags, not new permissions.

  // Any permission that requires that a user be actually added to a project.
  const MEMBER = 30;
  // All permissions together.
  const ALL = 31;

  public function get_permission_literal($permission, $lowercase = false) {
    if ($permission & self::OWNER) {
      return $lowercase ? "owner" : "Owner";
    } else if ($permission & self::ADMIN) {
      return $lowercase ? "administrator" : "Administrator";
    } else if ($permission & self::WRITE) {
      return $lowercase ? "contributor" : "Contributor";
    } else if ($permission & self::READ) {
      return $lowercase ? "reader" : "Reader";
    } else if ($permission & self::SUBSCRIBER) {
      return $lowercase ? "subscriber" : "Subscriber";
    } else {
      return $lowercase ? "none" : "None";
    }
  }

	public function get_by_user_on_project($user_id, $proj_id) {
		$this->db->where('user_id', $user_id);
		$this->db->where('proj_id', $proj_id);
		$r = $this->db->get($this->permission_table)->result();
		if (empty($r)) return null;
		return $r[0];
	}

  public function get_user_accessible($user_id, $public_only = false, $count_only = false) {
    return $this->get_by_user(
      $user_id,
      array('oper' => 'or',
            'permissions' => self::MEMBER));
  }

  // XXX: Remove this!
  public function get_user_membership($user_id, $count_only = false) {
    return $this->get_by_user($user_id);
  }

  public function get_user_subscriptions($user_id, $public_only = false, $count_only = false) {
    return $this->get_by_user(
      $user_id,
      array('oper' => 'and',
            'permissions' => self::SUBSCRIBER));
  }

  public function get_by_user($user_id, $filter = null, $count_only = false) {
    $this->db->where('user_id', $user_id);
    if ($filter) {
      if ($filter['oper'] == 'and') {
        $this->db->where('permission', $filter['permissions']);
      } else if ($filter['oper'] == 'or') {
        $this->db->where('permission &', $filter['permissions']);
      }
    }
		$this->db->join($this->projects_table, 'projects.id = proj_id');
    if ($count_only) {
      return $this->db->count_all_results($this->permission_table);
    }
    return $this->db->get($this->permission_table)->result();
  }

  public function get_by_project($proj_id, $filter = null, $count_only = false) {
    $this->db->where('proj_id', $proj_id);
    if ($filter) {
      if ($filter['oper'] == 'and') {
        $this->db->where('permission', $filter['permissions']);
      } else if ($filter->oper == 'or') {
        $this->db->where('permission &', $filter['permissions']);
      }
    }
		$this->db->join($this->projects_table, 'projects.id = proj_id');
    if ($count_only) {
      return $this->db->count_all_results($this->permission_table);
    }
    return $this->db->get($this->permission_table)->result();
  }

  public function is_owner($user_id, $proj_id) {
    $r = $this->get_by_user_on_project($user_id, $proj_id);
    if (empty($r)) return false;
    return !!($r->permission & (self::OWNER));
  }

	public function is_admin($user_id, $proj_id) {
    $r = $this->get_by_user_on_project($user_id, $proj_id);
    if (empty($r)) return false;
    return !!($r->permission & (self::ADMIN|self::OWNER));
	}

	public function is_member($user_id, $proj_id) {
    $r = $this->get_by_user_on_project($user_id, $proj_id);
		if (empty($r)) return false;
    return !!($r->permission & (self::MEMBER));
  }

	public function is_subscribed($user_id, $proj_id) {
    $r = $this->get_by_user_on_project($user_id, $proj_id);
		if (empty($r)) return false;
    return !!($r->permission & (self::SUBSCRIBER));
  }

  public function add_permission($user_id, $proj_id, $permission) {
    $this->db->insert($this->permission_table, array(
      'user_id' => $user_id,
      'proj_id' => $proj_id,
      'permission' => $permission,
    ));
  }

  public function delete_permission($user_id, $proj_id) {
		$this->db->where('user_id', $user_id);
		$this->db->where('proj_id', $proj_id);
		$this->db->delete($this->permission_table);
  }

	public function set_user_perms($user_id, $proj_id, $permission) {
		$data = array(
			'user_id' => $user_id,
			'proj_id' => $proj_id,
      'permission' => $permission,
		);
		if ($this->get_by_user_on_project($user_id, $proj_id) !== null) {
			$this->db->where('user_id', $user_id);
			$this->db->where('proj_id', $proj_id);
			$this->db->update($this->permission_table, $data);
		} else {
			$this->db->insert($this->permission_table, $data);
		}
		return true;
	}
}
