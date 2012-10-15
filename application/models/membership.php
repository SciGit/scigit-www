<?

class Membership extends CI_Model
{
  public $member_table = 'proj_membership';
  public $permissions_table = 'proj_permissions';

  public function get($member_id) {
    $this->db->where('id', $member_id);
		$r = $this->db->get($this->proj_table)->result();
		if (empty($r)) return null;
		return $r[0];
  }

  // Synthetically includes users with permissions on this project if the
  // $include_permissions flag is set.
  public function get_by_project($proj_id, $include_permissions = false) {
    if ($include_permissions) {
      $query = "(SELECT id, proj_id, user_id FROM proj_membership WHERE proj_id=$proj_id)
                UNION
                (SELECT id, proj_id, user_id FROM proj_permissions WHERE proj_id=$proj_id)";

      return $this->db->query($query)->result();
    }

    $this->db->where('proj_id', $proj_id);
    return $this->db->get($member_table)->result();
  }
}
