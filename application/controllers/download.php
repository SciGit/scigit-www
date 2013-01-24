<?

class Download extends SciGit_Controller
{
  public function __construct() {
    parent::__construct();
    check_login();
  }

  function send_file($name) {
  }

  public function index() {
    $name = 'SciGit.exe';
    ob_end_clean();
    $path = "static/".$name;
    if (!is_file($path) or connection_status()!=0) return(FALSE);
    header("Cache-Control: no-store, no-cache, must-revalidate");
    header("Cache-Control: post-check=0, pre-check=0", false);
    header("Pragma: no-cache");
    header("Expires: ".gmdate("D, d M Y H:i:s", mktime(date("H")+2, date("i"), date("s"), date("m"), date("d"), date("Y")))." GMT");
    header("Last-Modified: ".gmdate("D, d M Y H:i:s")." GMT");
    header("Content-Type: application/octet-stream");
    header("Content-Length: ".(string)(filesize($path)));
    header("Content-Disposition: inline; filename=$name");
    header("Content-Transfer-Encoding: binary\n");
    if ($file = fopen($path, 'rb')) {
      while(!feof($file) and (connection_status()==0)) {
        print(fread($file, 1024*8));
        flush();
      }
      fclose($file);
    }
    return((connection_status()==0) and !connection_aborted());
  }
}
