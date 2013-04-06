<?php

class SciGit_Site_Controller extends SciGit_Controller
{
  function __construct()
  {
    parent::__construct();

    require "lessc.inc.php";

    $less = new lessc;
    $less->checkedCompile("css/style.less", "css/style.css");
  }

  function validation_errors() {
    if (empty($this->form_validation->_error_array) &&
        empty($this->form_validation->_error_messages)) {
      return null;
    }

    $errors = array();
    foreach ($this->form_validation->_error_array as $key => $error) {
      if (!in_array($error, $errors, true)) {
        array_push($errors, $error);
      }
    }
    foreach ($this->form_validation->_error_messages as $key => $error) {
      if (!in_array($error, $errors, true)) {
        array_push($errors, $error);
      }
    }

    return $errors;
  }
}
