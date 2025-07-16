# Intégration TOTP (Two-Factor Authentication)

## Architecture

L'authentification à deux facteurs (TOTP) est gérée par une architecture hybride :
- **Interface utilisateur** : Legacy (PHP)
- **Génération QR Code et validation** : Symfony (PHP moderne)

## Composants

### 1. Legacy (Interface utilisateur)

#### Pages et Templates
- `tpl/MyAccount/profile.tpl` : Interface d'activation TOTP avec QR code
- **Appel direct** : JavaScript appelle directement l'API Symfony

#### Base de données
- Table `users` avec colonnes `totp_enabled` et `totp_secret`
- Commandes SQL : `UpdateUserTotpSecretCommand`, `UPDATE_USER_TOTP_SECRET`

### 2. Symfony (Logique métier)

#### Contrôleur
- `symfony/src/Controller/Authentication2faController.php`
- Endpoints :
  - `POST /authentication/2fa/generate-qr` : Génère le QR code TOTP
  - `POST /authentication/2fa/verify` : Vérifie le code TOTP

#### Dépendances
```json
{
    "endroid/qr-code": "^4.0",
    "otphp/otphp": "^11.0",
    "scheb/2fa-totp": "^7.11"
}
```
- **otphp/otphp** : utilisé explicitement pour la génération et la vérification des codes TOTP dans le contrôleur Symfony.
- **endroid/qr-code** : utilisé pour générer le QR code à scanner.
- **scheb/2fa-totp** : présent pour une intégration native 2FA avec Symfony, mais non utilisé directement dans le code actuel, installé en prévision d'une simplification du flow côté symfony.

### Tester l'API
```bash
# Générer un QR code
curl -X POST http://localhost:8000/authentication/2fa/generate-qr \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com"}'

# Vérifier un code
curl -X POST http://localhost:8000/authentication/2fa/verify \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","code":"123456"}'
```

## Flux utilisateur

### Activation TOTP
1. L'utilisateur va dans son profil (legacy)
2. Il coche "Activer l'authentification à deux facteurs"
3. Le JavaScript appelle **directement** l'API Symfony `/authentication/2fa/generate-qr`
4. Symfony génère le secret TOTP et le QR code
5. Le QR code s'affiche dans l'interface legacy
6. L'utilisateur scanne le QR code avec son application
7. Il sauvegarde son profil pour activer définitivement le TOTP

### Connexion avec TOTP
1. L'utilisateur saisit son identifiant et mot de passe (legacy)
2. Si TOTP activé, il est redirigé vers `totp.php`
3. Il saisit le code TOTP généré par son application
4. Le code est vérifié via l'API Symfony `/authentication/2fa/verify`
5. Si correct, il est connecté

## Avantages de l'appel direct

- **Performance** : Une requête HTTP en moins (pas d'intermédiaire)
- **Simplicité** : Moins de code à maintenir
- **Cohérence** : Toute la logique TOTP centralisée dans Symfony
- **Sécurité** : Moins de points d'entrée exposés

## Configuration CORS (si nécessaire)

Si le legacy et Symfony sont sur des domaines/ports différents, configurer CORS dans Symfony :

```php
// symfony/config/packages/nelmio_cors.yaml
nelmio_cors:
    defaults:
        origin_regex: true
        allow_origin: ['%env(CORS_ALLOW_ORIGIN)%']
        allow_methods: ['GET', 'OPTIONS', 'POST', 'PUT', 'PATCH', 'DELETE']
        allow_headers: ['Content-Type', 'Authorization']
        expose_headers: ['Link']
        max_age: 3600
```

## Sécurité

- **Secret TOTP** : Généré automatiquement (32 caractères base32)
- **Format QR code** : Standard `otpauth://totp/` compatible avec toutes les applications
- **Validation** : Utilise la librairie **OTPHP** (`otphp/otphp`) pour la génération et la vérification des codes TOTP
- **Stockage** : Secret chiffré en base de données

## Configuration

### Variables d'environnement
```bash
# URL de l'API Symfony (dans le legacy)
SYMFONY_API_URL=http://localhost:8000
```

### Personnalisation
- **Nom de l'application** : Modifier `$issuer` dans `generateQrCodeImage()`
- **Taille du QR code** : Modifier `setSize(200)` dans le contrôleur Symfony
- **Format de sortie** : Changer `PngWriter()` pour d'autres formats

## Dépannage

### Erreurs courantes
1. **Dépendances manquantes** : Exécuter `./install-dependencies.sh`
2. **Serveur Symfony non démarré** : Vérifier que le serveur tourne sur le bon port
3. **CORS** : Configurer les en-têtes CORS si nécessaire
4. **Base de données** : Vérifier que les colonnes TOTP existent dans la table `users`

### Logs
- **Legacy** : Vérifier les logs PHP/Apache
- **Symfony** : Vérifier `var/log/dev.log` ou `var/log/prod.log` 