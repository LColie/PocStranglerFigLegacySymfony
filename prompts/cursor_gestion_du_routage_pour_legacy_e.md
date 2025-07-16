# Gestion du routage pour legacy et Symfony
_Exported on 16/07/2025 at 16:32:40 UTC+2 from Cursor (1.2.4)_

---

**User**

propose moi un index.php permettant de gérer le routage autant vers le legacy que le projet symfony à venir

---

**Cursor**

Bien sûr ! Voici une proposition d’architecture pour un fichier `index.php` qui permet de router les requêtes soit vers l’application legacy (comme actuellement), soit vers un projet Symfony à venir. L’idée est de détecter, selon l’URL ou un préfixe (par exemple `/api`, `/admin`, etc.), si la requête doit être traitée par Symfony ou par le code legacy.

### Exemple de logique de routage

1. **Détection du contexte** :  
   - Si l’URL commence par `/symfony` (ou `/api`, ou tout autre préfixe que tu choisiras), on délègue à Symfony.
   - Sinon, on continue avec le legacy.

2. **Appel du front controller Symfony** :  
   - On inclut le fichier d’entrée de Symfony (`public/index.php` du projet Symfony).

3. **Sinon, on garde le comportement legacy**.

---

### Exemple de code pour `Web/index.php`

```php
<?php
define('ROOT_DIR', '../');

// 1. Détection du routage Symfony
$requestUri = $_SERVER['REQUEST_URI'];

// À adapter selon le dossier ou le sous-domaine de ton projet Symfony
$symfonyPrefix = '/symfony'; // ou '/api', '/admin', etc.

if (strpos($requestUri, $symfonyPrefix) === 0) {
    // 2. Inclusion du front controller Symfony
    // Chemin à adapter selon l’emplacement de Symfony
    require_once ROOT_DIR . 'symfony/public/index.php';
    exit;
}

// 3. Legacy (comportement existant)
if (!file_exists(ROOT_DIR . 'config/config.php')) {
    die('Missing config/config.php. Please refer to the installation instructions.');
}

require_once(ROOT_DIR . 'Pages/LoginPage.php');
require_once(ROOT_DIR . 'Presenters/LoginPresenter.php');

$page = new LoginPage();

if ($page->LoggingIn()) {
    $page->Login();
}

if ($page->ChangingLanguage()) {
    $page->ChangeLanguage();
}

$page->PageLoad();
```

---

### À adapter selon ton projet

- Modifie la variable `$symfonyPrefix` selon le chemin que tu veux réserver à Symfony.
- Le chemin vers le front controller Symfony (`symfony/public/index.php`) doit être ajusté selon l’emplacement réel de ton projet Symfony.
- Si tu veux router selon un sous-domaine ou d’autres critères, la logique peut être adaptée.

Veux-tu que je l’implémente directement dans ton fichier `Web/index.php` avec un préfixe particulier (par exemple `/symfony` ou `/api`) ? Si oui, précise le préfixe ou la règle de routage souhaitée.

```php
<?php
define('ROOT_DIR', '../');

// 1. Détection du routage Symfony
$requestUri = $_SERVER['REQUEST_URI'];

// À adapter selon le dossier ou le sous-domaine de ton projet Symfony
$symfonyPrefix = '/symfony'; // ou '/api', '/admin', etc.

if (strpos($requestUri, $symfonyPrefix) === 0) {
    // 2. Inclusion du front controller Symfony
    // Chemin à adapter selon l’emplacement de Symfony
    require_once ROOT_DIR . 'symfony/public/index.php';
    exit;
}

// 3. Legacy (comportement existant)
if (!file_exists(ROOT_DIR . 'config/config.php')) {
    die('Missing config/config.php. Please refer to the installation instructions.');
}

require_once(ROOT_DIR . 'Pages/LoginPage.php');
require_once(ROOT_DIR . 'Presenters/LoginPresenter.php');

$page = new LoginPage();

if ($page->LoggingIn()) {
    $page->Login();
}

if ($page->ChangingLanguage()) {
    $page->ChangeLanguage();
}

$page->PageLoad();
```

