# Adapter le docker file pour symfony
_Exported on 10/07/2025 at 12:17:11 UTC+2 from Cursor (1.2.2)_

---

**User**

peux tu adapter le docker file pour lancer le legacy et le projet symfony sur la même instance apache

---

**Cursor**

Bien sûr ! Voici comment tu peux adapter ton Dockerfile pour faire tourner à la fois ton application legacy (dans `/var/www/html`) et ton projet Symfony (dans `/var/www/symfony` par exemple) sur la même instance Apache.

### Étapes principales :
1. **Copier les deux projets dans l’image** (ou cloner/télécharger selon ton process).
2. **Configurer Apache pour servir deux VirtualHosts** :  
   - Le legacy sur `/` (ou `/legacy`)
   - Symfony sur `/symfony` (ou `/api`, `/app`, etc.)
3. **Activer les modules nécessaires** (déjà fait dans ton Dockerfile).
4. **Adapter les permissions et dépendances**.

---

### Exemple d’adaptation du Dockerfile

Je vais te donner les grandes lignes à ajouter/modifier :

#### 1. Copier Symfony dans l’image

Ajoute après la partie legacy :

```dockerfile
# Copier le projet Symfony
COPY symfony/ /var/www/symfony/
RUN chown -R www-data:www-data /var/www/symfony
```
Ou adapte si tu veux le cloner/télécharger.

#### 2. Installer les dépendances Symfony

Ajoute après la copie :

```dockerfile
RUN cd /var/www/symfony && composer install --no-interaction --optimize-autoloader
```

#### 3. Créer un VirtualHost Apache pour Symfony

Ajoute un fichier de conf Apache :

```dockerfile
COPY ci/apache-symfony.conf /etc/apache2/sites-available/symfony.conf
RUN a2ensite symfony
```

**Exemple de contenu pour `ci/apache-symfony.conf`** :

```apache
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/html

    # Legacy app sur /
    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>

    # Symfony sur /symfony
    Alias /symfony /var/www/symfony/public
    <Directory /var/www/symfony/public>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

#### 4. Désactiver le site par défaut si besoin

```dockerfile
RUN a2dissite 000-default
```

#### 5. Redémarrage Apache (géré par le CMD)

---

### Résumé des ajouts à faire

- Copier le code Symfony dans `/var/www/symfony`
- Installer les dépendances Symfony
- Ajouter un VirtualHost Apache qui :
  - Sert `/` depuis `/var/www/html` (legacy)
  - Sert `/symfony` depuis `/var/www/symfony/public`
- Activer ce site Apache

---

### À faire côté code

- Crée le fichier `ci/apache-symfony.conf` (ou un nom équivalent)
- Vérifie que les permissions sont correctes
- Adapte les chemins si besoin

---

Veux-tu que je te génère le Dockerfile complet modifié et le fichier de conf Apache ?

```dockerfile
# Copier le projet Symfony
COPY symfony/ /var/www/symfony/
RUN chown -R www-data:www-data /var/www/symfony
```

```dockerfile
RUN cd /var/www/symfony && composer install --no-interaction --optimize-autoloader
```

```dockerfile
COPY ci/apache-symfony.conf /etc/apache2/sites-available/symfony.conf
RUN a2ensite symfony
```

```plaintext
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/html

    # Legacy app sur /
    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>

    # Symfony sur /symfony
    Alias /symfony /var/www/symfony/public
    <Directory /var/www/symfony/public>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

```dockerfile
RUN a2dissite 000-default
```

---

**User**

Créer le fichier ci/apache-symfony.conf comme indiqué

---

**Cursor**

```properties
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/html

    # Application legacy sur /
    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>

    # Application Symfony sur /symfony
    Alias /symfony /var/www/html/symfony/public
    <Directory /var/www/html/symfony/public>
        AllowOverride All
        Require all granted
        Options FollowSymLinks
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

```

Le fichier `ci/apache-symfony.conf` a été créé pour configurer Apache afin de servir l'application legacy sur `/` et Symfony sur `/symfony`.  
Tu peux maintenant construire et lancer ton conteneur : Apache servira les deux applications sur la même instance.

Si tu veux personnaliser le chemin d'accès à Symfony (par exemple `/api` au lieu de `/symfony`), il suffit de modifier l'alias dans ce fichier.

Dis-moi si tu veux d'autres ajustements ou une aide pour les tests !

---

**User**

que fait cette commande

---

**Cursor**

La commande suivante :

```sh
sed \
  -i /etc/apache2/sites-enabled/000-default.conf \
  -e "s:/var/www/html:/var/www:"
```

**Explication en français :**

- `sed` est un utilitaire de manipulation de texte en ligne de commande.
- `-i` indique que la modification se fait directement dans le fichier (`/etc/apache2/sites-enabled/000-default.conf`).
- `-e "s:/var/www/html:/var/www:"` est une expression de substitution :  
  Elle remplace toutes les occurrences de `/var/www/html` par `/var/www` dans ce fichier.

**Concrètement :**
- Cette commande modifie la configuration du site Apache par défaut pour que le `DocumentRoot` (et tout autre chemin contenant `/var/www/html`) pointe désormais vers `/var/www` au lieu de `/var/www/html`.

**Attention :**
- Si tu utilises un VirtualHost personnalisé (comme `symfony.conf`), cette commande n’aura d’effet que si le site par défaut (`000-default.conf`) est encore activé.
- Cela peut provoquer des conflits ou des comportements inattendus si plusieurs VirtualHosts utilisent des `DocumentRoot` différents.

Veux-tu que je vérifie si cette commande est encore utile dans ta configuration actuelle ?

```shellscript
sed \
  -i /etc/apache2/sites-enabled/000-default.conf \
  -e "s:/var/www/html:/var/www:"
```

---

**User**

Oui vérifie

---

**Cursor**

Après analyse, voici la situation :

- La commande :
  ```sh
  sed -i /etc/apache2/sites-enabled/000-default.conf -e "s:/var/www/html:/var/www:"
  ```
  n’est exécutée **que si la variable d’environnement `LB_PATH` est définie** (voir : `if ! test -z "${LB_PATH}"; then ...`).

- Cette commande modifie le site Apache par défaut (`000-default.conf`) pour changer le `DocumentRoot` de `/var/www/html` vers `/var/www`.

- **Or, dans ton Dockerfile, tu n’as pas de commande qui désactive explicitement le site par défaut (`a2dissite 000-default`)**.  
  Tu actives seulement le site `symfony` :
  ```dockerfile
  RUN a2ensite symfony
  ```

- Donc, **le site par défaut reste actif** (sauf si Apache, dans ta base d’image, le désactive par défaut, ce qui n’est pas le cas habituel).

---

### Conclusion

- **La commande sed est utile uniquement si :**
  - Le site par défaut (`000-default.conf`) est activé (ce qui est le cas ici).
  - Tu utilises la variable d’environnement `LB_PATH` pour servir l’application legacy sous un préfixe d’URL (ex : `/booking`).

- **Si tu ne veux servir que via le VirtualHost `symfony.conf`**, il serait plus propre de désactiver le site par défaut dans le Dockerfile :
  ```dockerfile
  RUN a2dissite 000-default
  ```
  Et dans ce cas, la commande sed deviendrait inutile.

---

Veux-tu :
- Garder le site par défaut (et donc la commande sed) ?
- Ou désactiver le site par défaut et ne servir que via `symfony.conf` (plus propre pour ton cas multi-apps) ?

```shellscript
  sed -i /etc/apache2/sites-enabled/000-default.conf -e "s:/var/www/html:/var/www:"
```

```dockerfile
  RUN a2ensite symfony
```

```dockerfile
  RUN a2dissite 000-default
```

---

**User**

désactiver le site par défaut

---

**Cursor**

```dockerfile
RUN a2ensite symfony
RUN a2dissite 000-default

```

Le site Apache par défaut (`000-default`) est maintenant désactivé dans le Dockerfile.  
Tu peux donc supprimer la commande `sed` qui modifiait ce fichier dans `entrypoint.sh`, car elle n’aura plus aucun effet.

Souhaites-tu que je m’en occupe également ?

---

**User**

Oui

---

**Cursor**

```shellscript
# A URL path prefix was set
if ! test -z "${LB_PATH}"; then
  ## Set server document root 1 directory up
  # sed \
  #   -i /etc/apache2/sites-enabled/000-default.conf \
  #   -e "s:/var/www/html:/var/www:"

  ## Rename the html directory as the URL prefix
  ln -s /var/www/html "/var/www/${LB_PATH}"
  chown www-data:www-data "/var/www/${LB_PATH}"

  ## Adapt the .htaccess file
  sed \
     -i /var/www/${LB_PATH}/.htaccess \
     -e "s:\(RewriteCond .*\)/Web/:\1\.*\/Web/:" \
    -e "s:\(RewriteRule .*\) /Web/:\1 /${LB_PATH}/Web/:"
fi

```

La commande qui modifiait le site par défaut avec `sed` a bien été supprimée de `entrypoint.sh`.  
Ta configuration est maintenant propre : seul le VirtualHost `symfony.conf` sera utilisé par Apache.

Si tu as d’autres questions ou besoins d’ajustements, n’hésite pas !

