# 🚀 Installation locale de ce Poc LibreBooking avec Docker

Ce guide explique comment installer et lancer LibreBooking en local à l’aide de Docker et docker-compose.

## Prérequis

- [Docker](https://www.docker.com/get-started) (version 20+ recommandée)
- [docker-compose](https://docs.docker.com/compose/) (souvent inclus avec Docker Desktop)
- (Optionnel) [git](https://git-scm.com/) pour cloner le dépôt

## 1. Récupérer le code source

Clonez le dépôt principal :

```bash
git clone https://github.com/LibreBooking/app.git
cd app
```

## 2. Lancer l’application avec Docker

Assurez-vous d’être dans le dossier racine du projet (là où se trouve le fichier `docker-compose.yml`).

Lancez les conteneurs :

```bash
docker-compose up -d
```

Cela va :
- Construire les images Docker si nécessaire
- Démarrer les services requis (web, base de données, etc.)

## 3. Accéder à l’application

Après quelques secondes, l’application sera accessible à l’adresse suivante :

```
http://localhost/Web/
```
login : 
- user@example.com / user
- admin@example.com / admin
(forcer éventuellement le mot de passe en SHA1 en base vu que les pass par défaut ne sont pas indiqués)

> Le port peut varier selon la configuration de votre `docker-compose.yml`.

## 4. Comptes de test

Des comptes de test sont généralement créés automatiquement. Si ce n’est pas le cas, reportez-vous à la documentation ou créez un compte via l’interface.

## 5. Arrêter l’application

Pour arrêter les conteneurs :

```bash
docker-compose down
```

## 6. Ressources complémentaires

- [README.md](./README.md) — Présentation générale, fonctionnalités, liens utiles
- [doc/INSTALLATION.md](doc/INSTALLATION.md) — Guide d’installation avancée (si besoin)
- [Wiki du projet](https://github.com/LibreBooking/app/wiki)
- [Support Discord](https://discord.gg/4TGThPtmX8)

---

**Remarque** :  
Pour toute question ou problème, consultez la section [Community & Support](./README.md#community--support) du README ou ouvrez une issue sur GitHub. 