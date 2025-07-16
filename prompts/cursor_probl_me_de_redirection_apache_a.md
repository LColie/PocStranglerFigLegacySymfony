# Problème de redirection Apache avec Symfony
_Exported on 10/07/2025 at 12:17:33 UTC+2 from Cursor (1.2.2)_

---

**User**

y a t'il une redirection apache vers Web qui empêche l'accès aux pages du projet symfony

---

**Cursor**

Oui, il y a bien une réécriture d’URL Apache qui cible le dossier Web, ce qui peut empêcher l’accès aux pages du projet Symfony si celui-ci n’est pas prévu pour fonctionner sous /Web/.

Dans le script entrypoint.sh, on trouve ce passage :

```bash
sed \
  -i /var/www/${LB_PATH}/.htaccess \
  -e "s:\(RewriteCond .*\)/Web/:\1\.\*/Web/:" \
  -e "s:\(RewriteRule .*\) /Web/:\1 /${LB_PATH}/Web/:"
```

Cela modifie le fichier .htaccess pour que toutes les règles qui concernent /Web/ soient adaptées au préfixe d’URL (LB_PATH). Typiquement, cela veut dire que toutes les requêtes qui ne ciblent pas explicitement un fichier existant sont redirigées vers le dossier Web, qui sert de racine pour l’application principale (hors Symfony).

Si tu veux accéder à des pages du projet Symfony (par exemple, /symfony/public), il faut :

- Que le .htaccess ne redirige pas toutes les requêtes vers /Web/ ou /${LB_PATH}/Web/.
- Que le VirtualHost Apache permette explicitement l’accès à /symfony/public ou au chemin voulu.
- Que le DocumentRoot ou les règles de réécriture ne masquent pas le dossier symfony.

En résumé : oui, la configuration actuelle peut empêcher l’accès aux pages Symfony si elles ne sont pas explicitement exclues des règles de réécriture ou si le VirtualHost n’est pas adapté. Il faudra ajuster le .htaccess ou la conf Apache pour permettre l’accès à Symfony en parallèle du legacy. Si tu veux de l’aide pour adapter la conf, précise le chemin d’accès souhaité pour Symfony.

```shellscript
sed \
  -i /var/www/${LB_PATH}/.htaccess \
  -e "s:\(RewriteCond .*\)/Web/:\1\.\*/Web/:" \
  -e "s:\(RewriteRule .*\) /Web/:\1 /${LB_PATH}/Web/:"
```

---

**User**

adapte le code pour accepter les routes Web et du projet symfony

---

**Cursor**

Pour permettre l’accès à la fois aux routes legacy (dossier Web) et aux routes du projet Symfony (par exemple, symfony/public), il faut :

1. Adapter le .htaccess pour ne pas rediriger toutes les requêtes vers /Web/.
2. Ajouter une exception pour le dossier symfony (ou le chemin voulu) dans les règles de réécriture.

Voici comment tu peux adapter la partie du script qui modifie le .htaccess :

### 1. Adapter la règle RewriteCond pour exclure Symfony

On veut que les règles de réécriture ne s’appliquent pas si l’URL commence par /symfony (ou un autre préfixe Symfony).

Dans le .htaccess, il faut ajouter une condition du type :
```apache
RewriteCond %{REQUEST_URI} !^/symfony/
```
avant la règle qui redirige vers /Web/.

### 2. Adapter le script entrypoint.sh

Modifie la section qui fait le sed sur le .htaccess pour injecter cette exclusion. Par exemple :

```bash
# Ajoute une exclusion pour /symfony/ dans le .htaccess
if ! test -z "${LB_PATH}"; then
  ## Set server document root 1 directory up
  sed \
    -i /etc/apache2/sites-enabled/000-default.conf \
    -e "s:/var/www/html:/var/www:"

  ## Rename the html directory as the URL prefix
  ln -s /var/www/html "/var/www/${LB_PATH}"
  chown www-data:www-data "/var/www/${LB_PATH}"

  ## Adapt the .htaccess file
  # Ajoute l'exclusion pour /symfony/ juste avant la première RewriteRule qui cible /Web/
  sed -i '/RewriteCond .*\/Web\//i RewriteCond %{REQUEST_URI} !^\/symfony\/' /var/www/${LB_PATH}/.htaccess

  # Puis adapte les règles existantes comme avant
  sed \
    -i /var/www/${LB_PATH}/.htaccess \
    -e "s:\(RewriteCond .*\)/Web/:\1\.\*/Web/:" \
    -e "s:\(RewriteRule .*\) /Web/:\1 /${LB_PATH}/Web/:"
fi
```

### 3. Résultat attendu

- Les requêtes vers /Web/ (legacy) continueront de fonctionner.
- Les requêtes vers /symfony/ (ou le chemin que tu veux) ne seront pas réécrites, donc Apache servira les fichiers Symfony normalement.

Veux-tu que je te génère le diff exact à appliquer dans entrypoint.sh ? Si oui, précise le chemin d’accès Symfony (par défaut, je prends /symfony/).

```plaintext
RewriteCond %{REQUEST_URI} !^/symfony/
```

```shellscript
# Ajoute une exclusion pour /symfony/ dans le .htaccess
if ! test -z "${LB_PATH}"; then
  ## Set server document root 1 directory up
  sed \
    -i /etc/apache2/sites-enabled/000-default.conf \
    -e "s:/var/www/html:/var/www:"

  ## Rename the html directory as the URL prefix
  ln -s /var/www/html "/var/www/${LB_PATH}"
  chown www-data:www-data "/var/www/${LB_PATH}"

  ## Adapt the .htaccess file
  # Ajoute l'exclusion pour /symfony/ juste avant la première RewriteRule qui cible /Web/
  sed -i '/RewriteCond .*\/Web\//i RewriteCond %{REQUEST_URI} !^\/symfony\/' /var/www/${LB_PATH}/.htaccess

  # Puis adapte les règles existantes comme avant
  sed \
    -i /var/www/${LB_PATH}/.htaccess \
    -e "s:\(RewriteCond .*\)/Web/:\1\.\*/Web/:" \
    -e "s:\(RewriteRule .*\) /Web/:\1 /${LB_PATH}/Web/:"
fi
```

---

**User**

probablement à cause du .htaccess, mais j'ai une erreur 404 quand j'appelle cette url : http://localhost/Web/symfony pour accéder à symfony alors que http://localhost/Web affiche bien le legacy

---

**Cursor**

Tu as raison, le problème vient très probablement du fichier `.htaccess` : les règles de réécriture sont faites pour rediriger tout ce qui n’est pas un fichier existant vers le legacy, et donc elles « mangent » les requêtes destinées à Symfony.

### Pourquoi tu as une 404 sur `/Web/symfony`

- Quand tu appelles `/Web/symfony`, la règle de réécriture du legacy prend la main et tente de trouver une ressource `/Web/symfony` dans le legacy, ou redirige vers l’index du legacy, qui ne connaît pas cette route → 404.
- Pour que Symfony soit accessible, il faut que le `.htaccess` laisse passer toutes les requêtes qui commencent par `/Web/symfony` (ou `/symfony` si tu veux l’exposer à la racine).

---

## Solution : Exclure `/Web/symfony` des règles de réécriture

Il faut modifier le `.htaccess` pour ajouter une condition qui dit :  
**« Si l’URL commence par `/Web/symfony`, ne pas appliquer la réécriture legacy. »**

### Exemple de modification à faire dans le script

Ajoute cette ligne juste avant la première règle `RewriteCond` qui cible `/Web/` :

```apache
RewriteCond %{REQUEST_URI} !^/Web/symfony
```

### Comment faire dans `entrypoint.sh`

Ajoute ce sed avant les autres :

```bash
# Ajoute l'exclusion pour /Web/symfony dans le .htaccess
sed -i '/RewriteCond .*\/Web\//i RewriteCond %{REQUEST_URI} !^\/Web\/symfony' /var/www/${LB_PATH}/.htaccess
```

**Puis laisse les autres sed comme ils sont.**

---

## Résumé du bloc à ajouter

Dans la section :

```bash
## Adapt the .htaccess file
```

Ajoute :

```bash
# Exclure /Web/symfony des règles de réécriture legacy
sed -i '/RewriteCond .*\/Web\//i RewriteCond %{REQUEST_URI} !^\/Web\/symfony' /var/www/${LB_PATH}/.htaccess
```

Juste avant le sed qui adapte les RewriteCond/RewriteRule.

---

## Résultat attendu

- http://localhost/Web → legacy OK
- http://localhost/Web/symfony → Symfony OK (Apache ne réécrit pas, donc Symfony prend la main)

---

Veux-tu que je te génère le patch exact à appliquer dans `entrypoint.sh` ?

```plaintext
RewriteCond %{REQUEST_URI} !^/Web/symfony
```

```shellscript
# Ajoute l'exclusion pour /Web/symfony dans le .htaccess
sed -i '/RewriteCond .*\/Web\//i RewriteCond %{REQUEST_URI} !^\/Web\/symfony' /var/www/${LB_PATH}/.htaccess
```

```shellscript
## Adapt the .htaccess file
```

```shellscript
# Exclure /Web/symfony des règles de réécriture legacy
sed -i '/RewriteCond .*\/Web\//i RewriteCond %{REQUEST_URI} !^\/Web\/symfony' /var/www/${LB_PATH}/.htaccess
```

---

**User**

le sed ne semble pas être bon, ça ne marche pas

---

**Cursor**

Merci pour ton retour. Il y a plusieurs raisons pour lesquelles le sed peut ne pas fonctionner comme attendu :

1. **Le pattern `/RewriteCond .*\/Web\//`** ne matche peut-être pas la ligne exacte dans ton `.htaccess` (il peut y avoir des espaces, des guillemets, etc.).
2. **L’ordre des RewriteCond** : il faut que la condition d’exclusion soit juste avant la RewriteRule qui cible `/Web/`.
3. **Le sed peut être sensible à l’emplacement ou à la syntaxe**.

---

## Diagnostic rapide

Peux-tu me montrer le bloc `RewriteCond`/`RewriteRule` de ton `.htaccess` ?  
Sinon, je vais te proposer une version plus robuste du sed.

---

## Version plus robuste

On va insérer la ligne d’exclusion avant la première ligne contenant `RewriteRule` qui cible `/Web/` (c’est souvent plus fiable).

```bash
sed -i '/RewriteRule .*\/Web\//i RewriteCond %{REQUEST_URI} !^\/Web\/symfony' /var/www/${LB_PATH}/.htaccess
```

**Explication** :  
- On cherche la première `RewriteRule` qui cible `/Web/` et on insère juste avant.

---

## Alternative : Ajout systématique en début de bloc

Si tu veux être sûr que la condition est bien prise en compte, tu peux aussi insérer la condition juste après la ligne `RewriteEngine On` (qui précède normalement les RewriteCond/RewriteRule) :

```bash
sed -i '/RewriteEngine On/a RewriteCond %{REQUEST_URI} !^\/Web\/symfony' /var/www/${LB_PATH}/.htaccess
```

---

## À tester

1. **Essaye la version avec `RewriteRule`** :
   ```bash
   sed -i '/RewriteRule .*\/Web\//i RewriteCond %{REQUEST_URI} !^\/Web\/symfony' /var/www/${LB_PATH}/.htaccess
   ```

2. **Ou la version après `RewriteEngine On`** :
   ```bash
   sed -i '/RewriteEngine On/a RewriteCond %{REQUEST_URI} !^\/Web\/symfony' /var/www/${LB_PATH}/.htaccess
   ```

---

## Vérification

Après modification, vérifie que tu as bien dans ton `.htaccess` :

```apache
RewriteEngine On
RewriteCond %{REQUEST_URI} !^/Web/symfony
RewriteCond ...
RewriteRule ... /Web/...
```

---

Veux-tu que je te propose le bloc exact à insérer dans `entrypoint.sh` ?  
Ou veux-tu me montrer le contenu de ton `.htaccess` pour que je t’adapte la commande ?

```shellscript
sed -i '/RewriteRule .*\/Web\//i RewriteCond %{REQUEST_URI} !^\/Web\/symfony' /var/www/${LB_PATH}/.htaccess
```

```shellscript
sed -i '/RewriteEngine On/a RewriteCond %{REQUEST_URI} !^\/Web\/symfony' /var/www/${LB_PATH}/.htaccess
```

```shellscript
   sed -i '/RewriteRule .*\/Web\//i RewriteCond %{REQUEST_URI} !^\/Web\/symfony' /var/www/${LB_PATH}/.htaccess
```

```shellscript
   sed -i '/RewriteEngine On/a RewriteCond %{REQUEST_URI} !^\/Web\/symfony' /var/www/${LB_PATH}/.htaccess
```

```plaintext
RewriteEngine On
RewriteCond %{REQUEST_URI} !^/Web/symfony
RewriteCond ...
RewriteRule ... /Web/...
```

---

**User**

voici le sed du .htaccess

---

**Cursor**

Merci, tu as partagé le bloc suivant :

```bash
sed \
   -i /var/www/${LB_PATH}/.htaccess \
   -e "s:\(RewriteCond .*\)/Web/:\1\.*\/Web/:" \
   -e "s:\(RewriteRule .*\) /Web/:\1 /${LB_PATH}/Web/:"
```

Ce sed ne fait que remplacer les chemins `/Web/` par le bon préfixe, mais il **n’ajoute pas** la condition d’exclusion pour `/Web/symfony`.  
C’est pour cela que les requêtes `/Web/symfony` sont toujours traitées par les règles legacy.

---

## Ce qu’il faut faire

Il faut **insérer** une ligne :
```apache
RewriteCond %{REQUEST_URI} !^/Web/symfony
```
juste avant la première règle `RewriteRule` qui cible `/Web/`.

---

### Voici le bloc à ajouter dans `entrypoint.sh` :

Juste avant ton sed existant, ajoute :

```bash
# Ajoute l'exclusion pour /Web/symfony dans le .htaccess
sed -i '/RewriteRule .*\/Web\//i RewriteCond %{REQUEST_URI} !^\/Web\/symfony' /var/www/${LB_PATH}/.htaccess
```

Puis laisse ton sed existant :

```bash
sed \
   -i /var/www/${LB_PATH}/.htaccess \
   -e "s:\(RewriteCond .*\)/Web/:\1\.*\/Web/:" \
   -e "s:\(RewriteRule .*\) /Web/:\1 /${LB_PATH}/Web/:"
```

---

## Résumé à insérer

```bash
# Exclure /Web/symfony des règles legacy
sed -i '/RewriteRule .*\/Web\//i RewriteCond %{REQUEST_URI} !^\/Web\/symfony' /var/www/${LB_PATH}/.htaccess

sed \
   -i /var/www/${LB_PATH}/.htaccess \
   -e "s:\(RewriteCond .*\)/Web/:\1\.*\/Web/:" \
   -e "s:\(RewriteRule .*\) /Web/:\1 /${LB_PATH}/Web/:"
```

---

**Après cela, relance ton conteneur et vérifie que http://localhost/Web/symfony fonctionne bien.**

Si tu veux, je peux t’expliquer comment vérifier dans le `.htaccess` que la ligne a bien été ajoutée.

```shellscript
sed \
   -i /var/www/${LB_PATH}/.htaccess \
   -e "s:\(RewriteCond .*\)/Web/:\1\.*\/Web/:" \
   -e "s:\(RewriteRule .*\) /Web/:\1 /${LB_PATH}/Web/:"
```

```plaintext
RewriteCond %{REQUEST_URI} !^/Web/symfony
```

```shellscript
# Ajoute l'exclusion pour /Web/symfony dans le .htaccess
sed -i '/RewriteRule .*\/Web\//i RewriteCond %{REQUEST_URI} !^\/Web\/symfony' /var/www/${LB_PATH}/.htaccess
```

```shellscript
sed \
   -i /var/www/${LB_PATH}/.htaccess \
   -e "s:\(RewriteCond .*\)/Web/:\1\.*\/Web/:" \
   -e "s:\(RewriteRule .*\) /Web/:\1 /${LB_PATH}/Web/:"
```

```shellscript
# Exclure /Web/symfony des règles legacy
sed -i '/RewriteRule .*\/Web\//i RewriteCond %{REQUEST_URI} !^\/Web\/symfony' /var/www/${LB_PATH}/.htaccess

sed \
   -i /var/www/${LB_PATH}/.htaccess \
   -e "s:\(RewriteCond .*\)/Web/:\1\.*\/Web/:" \
   -e "s:\(RewriteRule .*\) /Web/:\1 /${LB_PATH}/Web/:"
```

---

**User**

peux tu me donner le contenu complet du .htaccess stp

---

**Cursor**

Bien sûr ! Voici un exemple de contenu complet pour un fichier `.htaccess` qui :

- Permet l’accès normal au legacy via `/Web`
- Laisse passer toutes les requêtes commençant par `/Web/symfony` (pour Symfony)
- Applique les règles de réécriture legacy uniquement pour le reste

Adapte le chemin si besoin (par exemple si tu utilises un préfixe différent).

---

```apache
# Activer le moteur de réécriture
RewriteEngine On

# Ne pas réécrire les requêtes pour Symfony
RewriteCond %{REQUEST_URI} !^/Web/symfony

# Si la requête n'est pas un fichier ou un dossier existant
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d

# Rediriger tout vers le legacy (index.php ou autre)
RewriteRule ^(.*)$ /Web/index.php [QSA,L]
```

---

### Explications

- `RewriteEngine On` : active la réécriture d’URL.
- `RewriteCond %{REQUEST_URI} !^/Web/symfony` : si l’URL commence par `/Web/symfony`, on ne fait pas la réécriture legacy (donc Symfony prend la main).
- Les deux conditions suivantes évitent de réécrire si le fichier ou le dossier existe déjà.
- La `RewriteRule` envoie tout le reste vers le legacy.

---

### Si tu utilises un sous-dossier (exemple : `/booking/Web`)

Il faut adapter les chemins dans les conditions et la règle, par exemple :

```apache
RewriteCond %{REQUEST_URI} !^/booking/Web/symfony
...
RewriteRule ^(.*)$ /booking/Web/index.php [QSA,L]
```

---

Si tu veux le `.htaccess` généré à partir de ton script (avec `${LB_PATH}`), donne-moi la valeur de `${LB_PATH}` ou le chemin exact que tu utilises, et je te le fournis adapté !

```plaintext
# Activer le moteur de réécriture
RewriteEngine On

# Ne pas réécrire les requêtes pour Symfony
RewriteCond %{REQUEST_URI} !^/Web/symfony

# Si la requête n'est pas un fichier ou un dossier existant
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d

# Rediriger tout vers le legacy (index.php ou autre)
RewriteRule ^(.*)$ /Web/index.php [QSA,L]
```

```plaintext
RewriteCond %{REQUEST_URI} !^/booking/Web/symfony
...
RewriteRule ^(.*)$ /booking/Web/index.php [QSA,L]
```

---

**User**

donne moi le .htaccess généré avec ce code

---

**Cursor**

Bien sûr ! Voici à quoi ressemblera le fichier `.htaccess` généré par ce code, en supposant un fichier de base classique pour le legacy, et en prenant en compte l’ajout automatique de la ligne d’exclusion pour `/Web/symfony` par le sed.

Supposons que le `.htaccess` d’origine ressemble à ceci :

```apache
RewriteEngine On

RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_URI} /Web/
RewriteRule ^(.*)$ /Web/index.php [QSA,L]
```

Après exécution de :

```bash
sed -i '/RewriteCond .*\/Web\//i RewriteCond %{REQUEST_URI} !^\/Web\/symfony' /var/www/${LB_PATH}/.htaccess
sed \
   -i /var/www/${LB_PATH}/.htaccess \
   -e "s:\(RewriteCond .*\)/Web/:\1\.*\/Web/:" \
   -e "s:\(RewriteRule .*\) /Web/:\1 /${LB_PATH}/Web/:"
```

Et si, par exemple, `${LB_PATH}` vaut `Web`, le résultat sera :

---

```apache
RewriteEngine On

RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_URI} !^/Web/symfony
RewriteCond %{REQUEST_URI} .*/Web/
RewriteRule ^(.*)$ /Web/Web/index.php [QSA,L]
```

---

### Explications

- La ligne `RewriteCond %{REQUEST_URI} !^/Web/symfony` a été insérée juste avant la condition sur `/Web/`.
- La condition `/Web/` a été transformée en `.*/Web/` par le sed.
- La règle `RewriteRule` a été adaptée pour inclure le préfixe `/Web/` devant le chemin legacy (donc `/Web/Web/index.php` si `${LB_PATH}=Web`).

---

### À adapter selon ton `${LB_PATH}`

- Si `${LB_PATH}` vaut `booking`, la règle finale serait :
  ```apache
  RewriteRule ^(.*)$ /booking/Web/index.php [QSA,L]
  ```

- Si `${LB_PATH}` est vide, la règle serait :
  ```apache
  RewriteRule ^(.*)$ /Web/index.php [QSA,L]
  ```

---

### Remarque

Si tu veux que le chemin ne double pas `/Web/` (ex : `/Web/Web/index.php`), il faut ajuster la logique du script ou la valeur de `${LB_PATH}`.

---

Si tu veux le `.htaccess` généré pour une valeur précise de `${LB_PATH}`, donne-moi la valeur exacte et je te donne le contenu final adapté !

```plaintext
RewriteEngine On

RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_URI} /Web/
RewriteRule ^(.*)$ /Web/index.php [QSA,L]
```

```shellscript
sed -i '/RewriteCond .*\/Web\//i RewriteCond %{REQUEST_URI} !^\/Web\/symfony' /var/www/${LB_PATH}/.htaccess
sed \
   -i /var/www/${LB_PATH}/.htaccess \
   -e "s:\(RewriteCond .*\)/Web/:\1\.*\/Web/:" \
   -e "s:\(RewriteRule .*\) /Web/:\1 /${LB_PATH}/Web/:"
```

```plaintext
RewriteEngine On

RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_URI} !^/Web/symfony
RewriteCond %{REQUEST_URI} .*/Web/
RewriteRule ^(.*)$ /Web/Web/index.php [QSA,L]
```

```plaintext
  RewriteRule ^(.*)$ /booking/Web/index.php [QSA,L]
```

```plaintext
  RewriteRule ^(.*)$ /Web/index.php [QSA,L]
```

---

**User**

LB_PATH est vide et tu oublies la règle pour symfony dans le htaccess final

---

**Cursor**

Merci pour la précision !  
Si `LB_PATH` est vide, alors `/var/www/${LB_PATH}/.htaccess` correspond à `/var/www/.htaccess` et les substitutions ne changent pas le chemin `/Web/` dans les règles.

Tu as raison : pour que Symfony fonctionne, il faut non seulement exclure `/Web/symfony` des règles legacy, mais aussi ajouter une règle qui redirige explicitement `/Web/symfony` (et ses sous-routes) vers le front controller de Symfony, typiquement `/Web/symfony/public/index.php`.

---

## .htaccess final recommandé

Voici un exemple de `.htaccess` qui :

- Laisse passer les fichiers et dossiers existants
- Redirige tout ce qui commence par `/Web/symfony` vers Symfony
- Redirige le reste vers le legacy

```apache
RewriteEngine On

# Laisser passer les fichiers et dossiers existants
RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]

# Rediriger tout ce qui commence par /Web/symfony vers Symfony (public/index.php)
RewriteCond %{REQUEST_URI} ^/Web/symfony
RewriteRule ^Web/symfony(/.*)?$ /Web/symfony/public/index.php [QSA,L]

# Règles legacy (exclure /Web/symfony)
RewriteCond %{REQUEST_URI} !^/Web/symfony
RewriteCond %{REQUEST_URI} .*/Web/
RewriteRule ^(.*)$ /Web/index.php [QSA,L]
```

---

### Explications

- Les deux premières conditions laissent passer les fichiers/dossiers existants (pas de réécriture).
- La règle Symfony : toute URL commençant par `/Web/symfony` est envoyée vers le front controller Symfony.
- Les règles legacy s’appliquent à tout le reste, sauf `/Web/symfony`.

---

## À faire dans ton entrypoint.sh

Pour générer ce `.htaccess`, il vaut mieux le créer explicitement ou t’assurer que les sed aboutissent à ce résultat.  
Sinon, tu peux remplacer le contenu du `.htaccess` par ce bloc lors du build.

Veux-tu que je te propose le sed ou le script pour générer exactement ce `.htaccess` ?

```plaintext
RewriteEngine On

# Laisser passer les fichiers et dossiers existants
RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]

# Rediriger tout ce qui commence par /Web/symfony vers Symfony (public/index.php)
RewriteCond %{REQUEST_URI} ^/Web/symfony
RewriteRule ^Web/symfony(/.*)?$ /Web/symfony/public/index.php [QSA,L]

# Règles legacy (exclure /Web/symfony)
RewriteCond %{REQUEST_URI} !^/Web/symfony
RewriteCond %{REQUEST_URI} .*/Web/
RewriteRule ^(.*)$ /Web/index.php [QSA,L]
```

---

**User**

Mieux, j'ai une erreur 500 maintenant, est-ce qu'il n'y a pas un souci de compatibilité entre htaccess et symfony ?

---

**Cursor**

Très bonne question ! Oui, il peut y avoir des soucis de compatibilité entre le `.htaccess` du legacy et Symfony, surtout si :

- Le `.htaccess` legacy interfère avec la gestion des URLs de Symfony.
- Les droits d’accès ou la configuration Apache ne permettent pas à Symfony de fonctionner correctement (ex : accès à `public/`, variables d’environnement, etc.).
- Le front controller de Symfony (`public/index.php`) n’est pas bien ciblé ou accessible.

---

## Points de compatibilité à vérifier

1. **Symfony doit être servi depuis son dossier `public/`**  
   L’URL doit pointer vers `/Web/symfony/public` ou alors la règle de réécriture doit router toutes les requêtes `/Web/symfony` vers `/Web/symfony/public/index.php`.

2. **Le `.htaccess` de Symfony**  
   Symfony fournit son propre `.htaccess` dans `public/`. Il doit être présent et Apache doit autoriser les overrides (`AllowOverride All`).

3. **Variables d’environnement**  
   Symfony a parfois besoin de variables d’environnement (APP_ENV, etc.) qui doivent être définies.

4. **Droits d’accès**  
   Les fichiers doivent être lisibles par l’utilisateur Apache.

---

## Exemple de configuration pour `/Web/symfony`

Dans le `.htaccess` principal (à la racine du legacy), il faut :

```apache
RewriteEngine On

# Laisser passer les fichiers et dossiers existants
RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]

# Rediriger tout ce qui commence par /Web/symfony vers le front controller Symfony
RewriteCond %{REQUEST_URI} ^/Web/symfony
RewriteRule ^Web/symfony(/.*)?$ /Web/symfony/public/index.php [QSA,L]

# Règles legacy
RewriteCond %{REQUEST_URI} !^/Web/symfony
RewriteCond %{REQUEST_URI} .*/Web/
RewriteRule ^(.*)$ /Web/index.php [QSA,L]
```

Et dans `/Web/symfony/public/.htaccess` (fourni par Symfony) :

```apache
# .htaccess standard Symfony
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^(.*)$ index.php [QSA,L]
</IfModule>
```

---

## Causes fréquentes d’erreur 500

- **mod_rewrite non activé** ou `AllowOverride` non autorisé dans la conf Apache.
- **Permissions** sur les fichiers/dossiers (vérifie que `var/` et `vendor/` sont accessibles).
- **Erreur PHP** dans Symfony (regarde les logs dans `var/log/` ou le log Apache).
- **Variables d’environnement manquantes** (ex : pas de `.env` ou de config adaptée).

---

## Que faire ?

1. **Vérifie les logs Apache et Symfony** pour l’erreur exacte.
2. **Teste l’accès direct à `/Web/symfony/public/`** pour voir si tu as une erreur différente.
3. **Vérifie la présence du `.htaccess` dans `public/`** et que `mod_rewrite` est bien activé.
4. **Vérifie les permissions** sur tous les fichiers Symfony.

---

Veux-tu que je t’aide à diagnostiquer l’erreur 500 en lisant les logs ou en vérifiant la conf Apache ?  
Ou veux-tu un script pour générer le `.htaccess` complet et compatible ?

```plaintext
RewriteEngine On

# Laisser passer les fichiers et dossiers existants
RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]

# Rediriger tout ce qui commence par /Web/symfony vers le front controller Symfony
RewriteCond %{REQUEST_URI} ^/Web/symfony
RewriteRule ^Web/symfony(/.*)?$ /Web/symfony/public/index.php [QSA,L]

# Règles legacy
RewriteCond %{REQUEST_URI} !^/Web/symfony
RewriteCond %{REQUEST_URI} .*/Web/
RewriteRule ^(.*)$ /Web/index.php [QSA,L]
```

```plaintext
# .htaccess standard Symfony
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^(.*)$ index.php [QSA,L]
</IfModule>
```

---

**User**

ne faudrait il pas un package spécifique pour rendre symfony compatible avec apache ?

---

**Cursor**

Non, Symfony est déjà compatible avec Apache par défaut ! Le `.htaccess` que tu as dans `symfony/public/.htaccess` est le fichier standard fourni par Symfony et il est conçu pour fonctionner avec Apache.

Le problème ne vient probablement pas d'un package manquant, mais plutôt de la configuration ou de l'environnement. Voici les points à vérifier :

## 1. Vérifier que mod_rewrite est activé


## 2. Vérifier les logs d'erreur

L'erreur 500 peut venir de plusieurs sources. Peux-tu vérifier :

- **Les logs Apache** : `/var/log/apache2/error.log` dans le conteneur
- **Les logs Symfony** : `symfony/var/log/dev.log` ou `prod.log`

## 3. Vérifier la configuration Apache

Le problème peut venir de la configuration Apache qui n'autorise pas les `.htaccess` :

```apache
<Directory /var/www/html>
    AllowOverride All
    Require all granted
</Directory>
```

## 4. Vérifier les permissions

Les dossiers `symfony/var/` et `symfony/vendor/` doivent être accessibles par l'utilisateur Apache.

## 5. Vérifier l'environnement Symfony

Symfony a besoin d'un fichier `.env` ou d'une configuration d'environnement. Vérifie que :
- Le fichier `.env` existe dans `symfony/`
- Les variables d'environnement sont correctement définies
- Le cache Symfony est accessible en écriture

## Solution recommandée

Au lieu de modifier le `.htaccess` principal, je te suggère de :

1. **Créer un VirtualHost séparé** pour Symfony
2. **Ou utiliser un sous-dossier avec sa propre configuration Apache**

Veux-tu que je t'aide à :
- Vérifier les logs d'erreur pour identifier le problème exact ?
- Créer une configuration Apache séparée pour Symfony ?
- Ou diagnostiquer l'environnement Symfony ?

Peux-tu me dire quelle erreur exacte tu vois dans les logs ?

```plaintext
<Directory /var/www/html>
    AllowOverride All
    Require all granted
</Directory>
```

