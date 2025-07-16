<?php
namespace App\Controller;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class LegacyController
{
    #[Route('/{path}', requirements: ['path' => '.+'], priority: -100)]
    public function legacy(Request $request, string $path): Response
    {
        // Redirige la requête vers le legacy (Web/index.php)
        $_SERVER['REQUEST_URI'] = '/' . $path;
        
        // Changer le répertoire de travail vers la racine de l'application
        $rootDir = __DIR__ . '/../../..';
        chdir($rootDir);
        
     
        // Debug: vérifier si le fichier config.php existe
        if (!file_exists($rootDir . '/config/config.php')) {
            return new Response('Config file not found at: ' . $rootDir . '/config/config.php');
        }
        
        ob_start();
        include __DIR__ . '/../../../Web/index.php';
        $content = ob_get_clean();

        return new Response($content);
    }
} 