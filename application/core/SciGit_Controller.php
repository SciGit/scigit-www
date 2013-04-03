<?php

class SciGit_Controller extends CI_Controller
{
  function __construct()
  {
    parent::__construct();

    require "lessc.inc.php";

    $less = new lessc;
    $less->checkedCompile("css/style.less", "css/style.css");
  }

  function json_encode_validation_errors($error_code) {
    if (empty($this->form_validation->_error_array) &&
        empty($this->form_validation->_error_messages)) {
      return null;
    }

    $errors = array();
    $message = '';
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

    foreach ($errors as $error) {
      $message .= '<p>' . $error . '</p>';
    }

    return json_encode(array(
      'error' => $error_code,
      'message' => $message,
    ));
  }
}
