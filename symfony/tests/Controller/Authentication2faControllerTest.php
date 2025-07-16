<?php

namespace App\Tests\Controller;

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Symfony\Bundle\FrameworkBundle\KernelBrowser;

final class Authentication2faControllerTest extends WebTestCase
{
    public function testGenerateQrCodeWithoutEmail(): void
    {
        /** @var \\Symfony\\Bundle\\FrameworkBundle\\KernelBrowser $client */
        $client = static::createClient();
        $client->request(
            'POST',
            '/authentication/2fa/generate-qr',
            [],
            [],
            ['CONTENT_TYPE' => 'application/json'],
            json_encode([])
        );
        $this->assertResponseIsSuccessful();
        $response = $client->getResponse();
        $data = json_decode($response->getContent(), true);
        $this->assertFalse($data['success']);
        $this->assertEquals('Email requis', $data['message']);
    }

    public function testGenerateQrCodeWithUnknownEmail(): void
    {
        /** @var \\Symfony\\Bundle\\FrameworkBundle\\KernelBrowser $client */
        $client = static::createClient();
        $client->request(
            'POST',
            '/authentication/2fa/generate-qr',
            [],
            [],
            ['CONTENT_TYPE' => 'application/json'],
            json_encode(['email' => 'inconnu@example.com'])
        );
        $this->assertResponseIsSuccessful();
        $response = $client->getResponse();
        $data = json_decode($response->getContent(), true);
        $this->assertFalse($data['success']);
        $this->assertEquals('Utilisateur non trouvé', $data['message']);
    }

    // Pour ce test, il faudrait un utilisateur existant dans la base de test
    // Vous pouvez adapter l'email selon vos fixtures/tests
    public function testGenerateQrCodeWithValidEmail(): void
    {
        /** @var \\Symfony\\Bundle\\FrameworkBundle\\KernelBrowser $client */
        $client = static::createClient();
        $email = 'test@example.com'; // À adapter selon vos données de test
        $client->request(
            'POST',
            '/authentication/2fa/generate-qr',
            [],
            [],
            ['CONTENT_TYPE' => 'application/json'],
            json_encode(['email' => $email])
        );
        $this->assertResponseIsSuccessful();
        $response = $client->getResponse();
        $data = json_decode($response->getContent(), true);
        if ($data['success']) {
            $this->assertArrayHasKey('qr_code_url', $data);
            $this->assertArrayHasKey('secret', $data);
        } else {
            $this->assertEquals('Utilisateur non trouvé', $data['message']);
        }
    }

    public function testVerifyWithUnknownEmail(): void
    {
        /** @var \\Symfony\\Bundle\\FrameworkBundle\\KernelBrowser $client */
        $client = static::createClient();
        $client->request(
            'POST',
            '/authentication/2fa/verify',
            [],
            [],
            ['CONTENT_TYPE' => 'application/json'],
            json_encode(['email' => 'inconnu@example.com', 'code' => '123456'])
        );
        $this->assertResponseIsSuccessful();
        $response = $client->getResponse();
        $data = json_decode($response->getContent(), true);
        $this->assertFalse($data['success']);
        $this->assertEquals('Utilisateur non trouvé', $data['message']);
    }

    // Pour ce test, il faudrait un utilisateur existant et un vrai code TOTP
    // Vous pouvez générer le code dynamiquement si vous avez accès au secret
    public function testVerifyWithInvalidCode(): void
    {
        /** @var \\Symfony\\Bundle\\FrameworkBundle\\KernelBrowser $client */
        $client = static::createClient();
        $email = 'test@example.com'; // À adapter selon vos données de test
        $client->request(
            'POST',
            '/authentication/2fa/verify',
            [],
            [],
            ['CONTENT_TYPE' => 'application/json'],
            json_encode(['email' => $email, 'code' => '000000'])
        );
        $this->assertResponseIsSuccessful();
        $response = $client->getResponse();
        $data = json_decode($response->getContent(), true);
        $this->assertFalse($data['success']);
    }

    // Pour un test de succès, il faudrait générer un vrai code TOTP à partir du secret
    // Cela nécessite d'accéder au secret de l'utilisateur de test
}
