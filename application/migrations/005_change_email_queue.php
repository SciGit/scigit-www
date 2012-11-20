<?

class Migration_Change_email_queue extends CI_Migration
{
  public function up()
  {
    $this->dbforge->drop_column('email_user_queue', 'change_id');
    $this->dbforge->drop_column('email_user_queue', 'send_at');
  }

  public function down()
  {
    $this->dbforge->add_column('email_user_queue', array(
      'change_id' => array('type' => 'INT', 'null' => false),
      'send_at' => array('type' => 'INT', 'null' => false),
    ));
  }
}
