<?php
require_once(ROOT_DIR . 'lib/Config/namespace.php');
require_once(ROOT_DIR . 'lib/Common/namespace.php');
require_once(ROOT_DIR . 'lib/Application/Authentication/namespace.php');

class TotpPresenter
{
    /**
     * @var TotpPage
     */
    private $page = null;

    /**
     * @var IWebAuthentication
     */
    private $authentication = null;

    /**
     * @param TotpPage $page
     */
    public function __construct($page, $authentication = null)
    {
        $this->page = $page;
        $this->SetAuthentication($authentication);
    }

    private function SetAuthentication($authentication)
    {
        if (is_null($authentication)) {
            $this->authentication = new WebAuthentication(
                PluginManager::Instance()->LoadAuthentication(),
                ServiceLocator::GetServer()
            );
        } else {
            $this->authentication = $authentication;
        }
    }

    public function PageLoad()
    {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $email = $this->page->GetLoginId();
            $code = $this->page->GetTotpCode();
            if ($this->verify2faWithSymfony($email, $code)) {
                // Authentification complète : connecter l'utilisateur
                $context = new WebLoginContext(
                    new LoginData(
                        // TODO: récupérer les paramètres de la page login
                        // $this->_page->GetPersistLogin(),
                        // $this->_page->GetSelectedLanguage()
                        false,
                        'fr'
                    )
                );
                $this->authentication->Login($email, $context);
                unset($_SESSION['pending_login_id']);
                $this->page->Redirect('index.php');
            } else {
                $this->page->SetShowTotpError();
            }
        }
    }

    private function verify2faWithSymfony($email, $code) {
        $url = 'http://localhost/authentication/2fa/verify';
        $data = json_encode(['email' => $email, 'code' => $code]);
        
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            'Content-Length: ' . strlen($data)
        ]);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
        
        $result = curl_exec($ch);

        if ($result === false) {
            curl_close($ch);
            return false;
        }
        $response = json_decode($result, true);
        curl_close($ch);
        // return "response : " . print_r($response, true);
        return isset($response['success']) && $response['success'] === true;
    }
} 