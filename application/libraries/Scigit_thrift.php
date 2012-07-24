<?php

$GLOBALS['THRIFT_ROOT'] = APPPATH . 'libraries/thrift';
require_once $GLOBALS['THRIFT_ROOT'].'/Thrift.php';
require_once $GLOBALS['THRIFT_ROOT'].'/protocol/TBinaryProtocol.php';
require_once $GLOBALS['THRIFT_ROOT'].'/transport/TSocket.php';
require_once $GLOBALS['THRIFT_ROOT'].'/transport/TBufferedTransport.php';
require_once $GLOBALS['THRIFT_ROOT'].'/packages/scigit/RepositoryManager.php';

class Scigit_thrift
{
	public static $socket, $transport, $protocol;
	public static $client;

	public static function init() {
		self::$socket = new TSocket('localhost', 9090);
		self::$transport = new TBufferedTransport(self::$socket);
		self::$protocol = new TBinaryProtocol(self::$transport);
		self::$client = new RepositoryManagerClient(self::$protocol);
		self::$transport->open();
	}

	public static function createRepository($repo_id) {
		self::$client->createRepository($repo_id);
	}

	public static function deleteRepository($repo_id) {
		self::$client->deleteRepository($repo_id);
	}

	public static function addPublicKey($key_id, $user_id, $public_key) {
		self::$client->addPublicKey($key_id, $user_id, $public_key);
	}

	public static function deletePublicKey($key_id, $user_id, $public_key) {
		self::$client->deletePublicKey($key_id, $user_id, $public_key);
	}
}

Scigit_thrift::init();
