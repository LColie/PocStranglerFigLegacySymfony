<?php
define('ROOT_DIR', '../');

require_once(ROOT_DIR . 'Pages/TotpPage.php');

$page = new TotpPage();
$page->PageLoad();