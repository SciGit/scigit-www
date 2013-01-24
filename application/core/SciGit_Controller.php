<?php

class SciGit_Controller extends CI_Controller
{
  function __construct()
  {
    parent::__construct();

    require "lessc.inc.php";

    $less = new lessc;
    $less->checkedCompile("css/style.less", "css/style2.css");
  }
}
