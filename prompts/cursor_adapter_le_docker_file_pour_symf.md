# Adapter le docker file pour symfony
_Exported on 10/07/2025 at 12:16:43 UTC+2 from Cursor (1.2.2)_

---

**User**

peux tu adapter le docker file pour lancer le legacy et le projet symfony sur la même instance apache

---

**Cursor**

Bien sûr ! Pour faire tourner à la fois ton application legacy (dans le dossier principal) et le projet Symfony (dans le dossier `symfony/`) sur la même instance Apache via Docker, il faut :

1. Configurer Apache pour servir deux "VirtualHosts" ou deux "Alias" pointant vers les deux applications.
2. Adapter le `Dockerfile` pour installer Apache, PHP, et copier les deux projets.
3. Ajouter un fichier de configuration Apache pour router `/symfony` (ou tout autre préfixe) vers le dossier Symfony, et le reste vers le legacy.

Voici comment procéder :

---

### 1. Exemple de Dockerfile

```Dockerfile
FROM php:8.2-apache

# Installation des extensions PHP nécessaires (ajuste selon tes besoins)
RUN docker-php-ext-install pdo pdo_mysql

# Active le module Apache rewrite
RUN a2enmod rewrite

# Copie du legacy (racine) et du projet Symfony
COPY . /var/www/html/
COPY symfony/ /var/www/symfony/

# Copie la config Apache custom
COPY apache-legacy-symfony.conf /etc/apache2/sites-available/000-default.conf

# Droits (optionnel, à adapter selon ton user)
RUN chown -R www-data:www-data /var/www/html /var/www/symfony

WORKDIR /var/www/html
```

---

### 2. Exemple de configuration Apache (`apache-legacy-symfony.conf`)

```apache
<VirtualHost *:80>
    DocumentRoot /var/www/html

    # Legacy: tout sauf /symfony ou /authentication/2fa (à adapter selon tes routes Symfony)
    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>

    # Alias pour Symfony (exemple : /symfony ou route spécifique)
    Alias /symfony /var/www/symfony/public
    <Directory /var/www/symfony/public>
        AllowOverride All
        Require all granted
        FallbackResource /index.php
    </Directory>

    # Exemple pour une route spécifique (ex : /authentication/2fa)
    Alias /authentication/2fa /var/www/symfony/public/authentication/2fa
    <Directory /var/www/symfony/public>
        AllowOverride All
        Require all granted
        FallbackResource /index.php
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

**Remarques :**
- Adapte les `Alias` selon les routes Symfony que tu veux router.
- Si tu veux que tout `/symfony` aille vers Symfony, garde l’alias `/symfony`.
- Si tu veux router des routes précises (comme `/authentication/2fa`), ajoute un alias pour chacune.

---

### 3. docker-compose.yml (optionnel)

Si tu utilises docker-compose, voici un exemple minimal :

```yaml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "8080:80"
    volumes:
      - .:/var/www/html
      - ./symfony:/var/www/symfony
```

---

### 4. Conseils supplémentaires

- N’oublie pas d’installer les dépendances Composer dans `/var/www/symfony` si besoin (ajoute une commande dans le Dockerfile).
- Si tu veux que le legacy soit accessible à la racine (`/`) et Symfony sur `/symfony` ou `/authentication/2fa`, la config ci-dessus suffit.
- Si tu veux router dynamiquement selon l’URI (comme dans ton `Web/index.php`), tu peux laisser la logique PHP, mais Apache sera plus performant pour router directement.

---

Veux-tu que je te génère ces fichiers prêts à l’emploi ? Si oui, précise les routes Symfony à router, ou si tu veux tout `/symfony` ou juste `/authentication/2fa`.

```dockerfile
FROM php:8.2-apache

# Installation des extensions PHP nécessaires (ajuste selon tes besoins)
RUN docker-php-ext-install pdo pdo_mysql

# Active le module Apache rewrite
RUN a2enmod rewrite

# Copie du legacy (racine) et du projet Symfony
COPY . /var/www/html/
COPY symfony/ /var/www/symfony/

# Copie la config Apache custom
COPY apache-legacy-symfony.conf /etc/apache2/sites-available/000-default.conf

# Droits (optionnel, à adapter selon ton user)
RUN chown -R www-data:www-data /var/www/html /var/www/symfony

WORKDIR /var/www/html
```

```plaintext
<VirtualHost *:80>
    DocumentRoot /var/www/html

    # Legacy: tout sauf /symfony ou /authentication/2fa (à adapter selon tes routes Symfony)
    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>

    # Alias pour Symfony (exemple : /symfony ou route spécifique)
    Alias /symfony /var/www/symfony/public
    <Directory /var/www/symfony/public>
        AllowOverride All
        Require all granted
        FallbackResource /index.php
    </Directory>

    # Exemple pour une route spécifique (ex : /authentication/2fa)
    Alias /authentication/2fa /var/www/symfony/public/authentication/2fa
    <Directory /var/www/symfony/public>
        AllowOverride All
        Require all granted
        FallbackResource /index.php
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

```yaml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "8080:80"
    volumes:
      - .:/var/www/html
      - ./symfony:/var/www/symfony
```

