<?

class Migration_Rename_invites_table extends CI_Migration
{
  public function up()
  {
    $this->db->query("ALTER TABLE email_invite_queue RENAME email_add_to_project_queue;");
  }

  public function down()
  {
    $this->db->query("ALTER TABLE email_add_to_project_queue RENAME email_invite_queue;");
  }
}
