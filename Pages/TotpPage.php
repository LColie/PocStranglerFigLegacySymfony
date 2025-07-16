<?php
session_start();
require_once(ROOT_DIR . 'Pages/Page.php');
require_once(ROOT_DIR . 'Presenters/TotpPresenter.php');

class TotpPage extends Page
{
    private $presenter;

    public function __construct()
    {
        parent::__construct('Totp');
        $this->presenter = new TotpPresenter($this);
    }

    public function PageLoad()
    {
        $this->presenter->PageLoad();
        $this->Display('totp.tpl');
    }

    public function GetTotpCode()
    {
        return $this->GetForm('totp_code');
    }

    public function GetLoginId()
    {
        return $_SESSION['pending_login_id'] ?? null;
    }

    public function SetShowTotpError()
    {
        $this->Set('ShowTotpError', true);
    }
} 