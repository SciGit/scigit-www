<?

define('SCIGIT_BASE_PATH_PRE', 'https://');
define('SCIGIT_BASE_PATH_POST', 'scigit.com');

define('SCIGIT_DEVELOPMENT_PATH', 'localhost');
define('SCIGIT_TESTING_PATH', SCIGIT_BASE_PATH_PRE . 'stage.' . SCIGIT_BASE_PATH_POST);
define('SCIGIT_PRODUCTION_PATH', SCIGIT_BASE_PATH_PRE . 'www.' . SCIGIT_BASE_PATH_POST);

function get_hostname() {
  switch (ENVIRONMENT) {
    case 'development':
      return SCIGIT_DEVELOPMENT_PATH;
    case 'testing':
      return SCIGIT_TESTING_PATH;
    case 'production':
      return SCIGIT_PRODUCTION_PATH;
  }
}

function is_ssl() {
  return isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] != 'off';
}
