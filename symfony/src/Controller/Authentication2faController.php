<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Annotation\Route;
use Endroid\QrCode\QrCode;
use Endroid\QrCode\Writer\PngWriter;
use Endroid\QrCode\ErrorCorrectionLevel\ErrorCorrectionLevelHigh;
use OTPHP\TOTP;

class Authentication2faController extends AbstractController
{
    #[Route('/authentication/2fa/verify', name: 'app_2fa_verify', methods: ['GET', 'POST'])]
    public function verify(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        $code = $data['code'] ?? '';
        $email = $data['email'] ?? '';

        // Récupérer l'utilisateur par email
        $user = $this->getUserByEmail($email);
        
        if (!$user) {
            return new JsonResponse(['success' => false, 'message' => 'Utilisateur non trouvé']);
        }

        // Vérifier le code TOTP
        $isValid = $this->verifyTotpCode($user->totpSecret, $code);
        
        return new JsonResponse(['success' => $isValid]);
    }

    #[Route('/authentication/2fa/generate-qr', name: 'app_2fa_generate_qr', methods: ['GET', 'POST'])]
    public function generateQrCode(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        $email = $data['email'] ?? '';

        if (empty($email)) {
            return new JsonResponse(['success' => false, 'message' => 'Email requis']);
        }

        // Récupérer ou créer l'utilisateur
        $user = $this->getUserByEmail($email);
        
        if (!$user) {
            return new JsonResponse(['success' => false, 'message' => 'Utilisateur non trouvé']);
        }

        // Générer un nouveau secret TOTP s'il n'existe pas
        $totpSecret = $user->totpSecret;
        if (empty($totpSecret)) {
            $totpSecret = $this->generateTotpSecret();
            $this->updateUserTotpSecret($user->id, $totpSecret);
        }

        // Générer le QR code
        $qrCodeUrl = $this->generateQrCodeImage($email, $totpSecret);
        
        return new JsonResponse([
            'success' => true,
            'qr_code_url' => $qrCodeUrl,
            'secret' => $totpSecret
        ]);
    }

    private function generateTotpSecret(): string
    {
        // Utiliser la librairie OTPHP pour générer un secret
        $totp = TOTP::create();
        return $totp->getSecret();
    }

    private function generateQrCodeImage(string $email, string $secret): string
    {
        // Format standard pour les QR codes TOTP
        $issuer = 'TestPopCarte';
        $account = $email;
        
        $otpauthUrl = sprintf(
            'otpauth://totp/%s:%s?secret=%s&issuer=%s',
            urlencode($issuer),
            urlencode($account),
            $secret,
            urlencode($issuer)
        );

        // Créer le QR code
        $qrCode = new QrCode($otpauthUrl);
        $qrCode->setSize(200);
        $qrCode->setMargin(10);
        $qrCode->setErrorCorrectionLevel(new ErrorCorrectionLevelHigh());

        $writer = new PngWriter();
        $result = $writer->write($qrCode);

        // Convertir en base64 pour l'affichage
        $dataUri = $result->getDataUri();
        
        return $dataUri;
    }

    private function verifyTotpCode(string $secret, string $code): bool
    {
        try {
            // Utiliser la librairie OTPHP pour vérifier le code
            $totp = TOTP::create($secret);
            return $totp->verify($code);
        } catch (\Exception $e) {
            // En cas d'erreur, retourner false
            return false;
        }
    }

    private function getUserByEmail(string $email)
    {
        // Initialiser le legacy si besoin
        if (!defined('ROOT_DIR')) {
            define('ROOT_DIR', __DIR__ . '/../../../');
        }
        require_once(ROOT_DIR . 'Domain/Access/namespace.php');

        // Instancier le UserRepository legacy
        $userRepository = new \UserRepository();
        $legacyUser = $userRepository->FindByEmail($email);

        if (!$legacyUser || !$legacyUser->Id()) {
            return null;
        }

        // Adapter l'objet legacy pour le contrôleur Symfony
        $user = new \stdClass();
        $user->id = $legacyUser->Id();
        $user->email = $legacyUser->EmailAddress();
        $user->totpSecret = $legacyUser->GetTotpSecret();
        return $user;
    }

    private function updateUserTotpSecret(int $userId, string $secret): void
    {
        // Simuler la mise à jour en base
        // En réalité, vous utiliseriez votre EntityManager
        // $user = $this->entityManager->getRepository(User::class)->find($userId);
        // $user->setTotpSecret($secret);
        // $this->entityManager->flush();
    }
}
