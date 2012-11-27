<?

class Migration_Add_invite_email_queue extends CI_Migration
{
  public function up()
  {
    $this->dbforge->add_field(array(
      'id' => array('type' => 'INT', 'auto_increment' => true),
      'user_id' => array('type' => 'INT', 'null' => false),
      'user_id2' => array('type' => 'INT', 'null' => false),
      'proj_id' => array('type' => 'INT', 'null' => false),
    ));

    $this->dbforge->add_key('id', TRUE);
    $this->dbforge->create_table('email_invite_queue');
  }

  public function down()
  {
    $this->dbforge->drop_table('email_invite_queue');
  }
}
