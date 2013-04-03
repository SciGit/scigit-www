<?

class Migration_Add_auto_generated_to_keys_table extends CI_Migration
{
  public function up()
  {
    $user_pub_keys_add_columns = array(
      'auto_generated' => array(
        'type' => 'INT',
        'null' => false,
        'default' => '1',
      ),
    );
    $this->dbforge->add_column('user_pub_keys', $user_pub_keys_add_columns);
  }

  public function down()
  {
    $user_pub_keys_drop_columns = array(
      'auto_generated',
    );

    foreach ($user_pub_keys_drop_columns as $user_pub_keys_drop_column) {
      $this->dbforge->drop_column('user_pub_keys', $user_pub_keys_drop_column);
    }
  }
}
