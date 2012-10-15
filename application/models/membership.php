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
  public function get_by_project($proj_id, $include_permissions = false, $count_only = false) {
    $this->db->where("$this->member_table.proj_id", $proj_id);
    if ($include_permissions) {
      $this->db->join($this->permissions_table, "$this->permissions_table.proj_id = $this->member_table.proj_id");
    }
    if ($count_only) {
      return $this->db->count_all_results($this->member_table);
    }
    return $this->db->get($this->member_table)->result();
  }
}
