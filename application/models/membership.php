<?

class Membership extends CI_Model
{
  public $member_table = 'proj_membership';

  public function get($member_id) {
    $this->db->where('id', $member_id);
		$r = $this->db->get($this->proj_table)->result();
		if (empty($r)) return null;
		return $r[0];
  }

  public function get_by_project($proj_id, $count_only) {
    $this->db->where('proj_id', $proj_id);
    if ($count_only) {
      return $this->db->count_all_results($this->member_table);
    }
    return $this->db->get($this->member_table)->result();
  }
}
