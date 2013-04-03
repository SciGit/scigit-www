<?

class Migration_Add_enabled_to_keys_table extends CI_Migration
{
  public function up()
  {
    $user_pub_keys_add_columns = array(
      'enabled' => array(
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
      'enabled',
    );

    foreach ($user_pub_keys_drop_columns as $user_pub_keys_drop_column) {
      $this->dbforge->drop_column('user_pub_keys', $user_pub_keys_drop_column);
    }
  }
}
