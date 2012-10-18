<?

class Migration_Add_email_queue extends CI_Migration
{
  public function up()
  {
    $this->dbforge->add_field(array(
      'id' => array('type' => 'INT', 'auto_increment' => true),
      'change_id' => array('type' => 'INT', 'null' => false),
    ));

    $this->dbforge->add_key('id', TRUE);
    $this->dbforge->add_key('change_id');
    $this->dbforge->create_table('email_queue');

    $this->dbforge->add_field(array(
      'id' => array('type' => 'INT', 'auto_increment' => true),
      'user_id' => array('type' => 'INT', 'null' => false),
      'change_id' => array('type' => 'INT', 'null' => false),
      'send_at' => array('type' => 'INT', 'null' => false),
    ));

    $this->dbforge->add_key('id', TRUE);
    $this->dbforge->add_key('user_id');
    $this->dbforge->add_key('change_id');
    $this->dbforge->create_table('email_user_queue');
  }

  public function down()
  {
    $this->dbforge->drop_table('email_queue');
    $this->dbforge->drop_table('email_user_queue');
  }
}
