# Pilote DevOps GlossaPro

Ce dépôt fournit une petite API Node.js et un pipeline exécutable pour apprendre les étapes de livraison. Il ne contient pas le code propriétaire de GlossaFlow ou GlossaLearn. La CI GitLab est la cible recommandée pour GlossaPro ; la CI GitHub permet de publier la démonstration sur un compte accessible.

Le pilote pédagogique est publié dans [walid-kiowy/opc-9](https://github.com/walid-kiowy/opc-9). Consulter [GitHub Actions](https://github.com/walid-kiowy/opc-9/actions) pour les exécutions hébergées. Les preuves locales restent disponibles dans `docs/preuves-locales/`.

## Démarrer en dix minutes

Prérequis : Git, Node.js 22 ou plus, Bash, tar et sha256sum (Linux ou conteneur Linux). Sur macOS, utiliser un conteneur Node pour les scripts Linux.

```sh
git clone https://github.com/walid-kiowy/opc-9.git
cd opc-9
npm test
npm start
# Dans un autre terminal
curl http://127.0.0.1:3000/health
```

L'API écoute seulement en local. `/health` indique que le processus répond ; `/version` indique la version. Cette sonde de démonstration ne vérifie pas une base de données ni les dépendances métier.

## Livrer un changement

1. Créer une branche courte : `git switch -c feat/health-message`.
2. Modifier le code et les tests. Exécuter `npm test`.
3. Committer et pousser la branche ; ouvrir une merge request (GitLab) ou pull request (GitHub).
4. Lire les jobs et corriger les échecs. Demander la revue d'un collègue.
5. Après fusion, le pipeline construit un paquet et teste cette version dans un processus temporaire.

Aucune installation npm n'est nécessaire : le projet utilise uniquement la bibliothèque standard Node. Pour un véritable service Node, committer package-lock.json, utiliser `npm ci`, ajouter le contrôle SCA et adapter le build.

Pour reproduire les contrôles locaux, y compris le refus d’un paquet corrompu :

```sh
bash scripts/verify.sh
```

La commande construit `dist/`, lance un processus temporaire sur le port 3187 puis l’arrête. Elle ne contacte aucune VM et ne prouve pas un déploiement distant. Si le port est occupé, arrêter le processus concerné ou adapter le port du test avec les Ops.

## Étapes du pipeline

- Validation : syntaxe Node/Bash et détection élémentaire de clés accidentelles.
- Tests : comportement HTTP des routes attendues et de la route inconnue.
- Build : paquet tar.gz identifié par le commit ; empreinte SHA-256.
- Intégration : vérifie l'empreinte, extrait le paquet et vérifie la version réellement servie.
- GitLab seulement, optionnel : staging distant puis production manuelle, même paquet, verrou par environnement.

Le garde-fou de secrets est limité. Il ne remplace pas Gitleaks, SAST, l'audit des dépendances ou les scans d'images. Une empreinte ne prouve pas l'identité de l'auteur ; la signature des releases est une extension à prévoir.

## Publier le dépôt

Créer un projet GitLab vide et privé, puis :

```sh
git remote add origin <URL_GITLAB>
git push -u origin main
```

Activer un runner Docker compatible avec `node:22-bookworm`. Aucun secret n'est nécessaire pour les jobs de démonstration. Dans CI/CD > Pipelines, vérifier validate, unit, build et integration puis télécharger l'artefact du job build. Passer le fichier `.gitlab-ci.yml` dans CI Lint de l'instance avant le premier lancement.

Sur GitHub, créer un dépôt vide privé et pousser de la même manière. Le workflow `.github/workflows/ci.yml` s'exécute sur les pull requests et sur main. Le déploiement distant n'est pas implémenté dans ce workflow GitHub. Avant usage sensible, épingler les actions à des SHA vérifiés et les images à des digests.

Après la première CI réussie, configurer la règle de protection de `main` pour exiger une revue et les contrôles du workflow, selon les possibilités du compte. Le commit initial est une exception de bootstrap ; les changements suivants passent par pull request. Ne pas exécuter le code d’une branche non fiable avec des secrets de production.

## Activer le déploiement distant GitLab

Cette partie concerne uniquement une VM de démonstration Linux dédiée. Les scripts sont fournis, mais leur exécution SSH/systemd nécessite une VM et n'a pas été vérifiée dans cet environnement.

Les Ops installent Node 22 à `/usr/bin/node`, créent un compte de service `deploy`, activent son gestionnaire systemd utilisateur permanent (`loginctl enable-linger deploy`) et configurent le réseau. Le port 3000 reste local ; un reverse proxy TLS doit servir l'API si l'on veut y accéder à distance. Pour staging et production, utiliser des VM et clés distinctes.

Copier l'inventaire d'exemple, ajouter un hôte de test, puis exécuter avec Ansible installé :

```sh
ansible-playbook -i infra/ansible/inventory.ini infra/ansible/bootstrap.yml
```

Protéger main ; les modifications de CI et scripts de déploiement doivent recevoir une revue Ops. Selon la licence GitLab, protéger également les environnements. Créer les variables suivantes dans GitLab, protégées et avec un périmètre `staging` ou `production` :

| Variable | Type | Valeur |
|---|---|---|
| DEPLOY_HOST | Variable | Nom DNS de la VM de démonstration |
| DEPLOY_USER | Variable | deploy |
| SSH_PRIVATE_KEY | Fichier | Clé privée propre à l'environnement |
| SSH_KNOWN_HOSTS | Fichier | Empreinte SSH vérifiée par un canal indépendant |

Créer `ENABLE_REMOTE_DEPLOY=true` uniquement après ces vérifications. Les clés ne sont jamais mises dans Git ou dans les artefacts. Ne jamais contourner StrictHostKeyChecking. Le runner doit atteindre les VM et disposer de ssh/scp (présents dans l'image complète choisie, à confirmer sur le runner).

Le job staging déploie automatiquement après la CI sur main. Production attend une action manuelle autorisée. Les deux téléchargent le même artefact build. En cas de santé incorrecte, le script réactive le lien précédent et redémarre le service. Les migrations de base de données sont hors du périmètre de cette API ; ce retour arrière ne les annule pas. Le déploiement redémarre un seul processus et peut interrompre le service : il ne représente pas encore la cible avec réplication et retrait du répartiteur.

## Réagir à un échec

- Tests rouges : lire l'assertion ; reproduire avec `npm test` ; corriger avant fusion.
- Checksum incorrect : reconstruire via le pipeline ; ne pas modifier le paquet.
- SSH refusé : vérifier compte, variable fichier, empreinte et réseau avec les Ops. Ne pas afficher la clé.
- Santé en échec : regarder les journaux via `journalctl --user -u glossapro.service`, comparer la release, contrôler le retour arrière.
- Artefact expiré : reconstruire et revalider une nouvelle release ; conserver les releases livrées dans un dépôt durable avant usage réel.

## Adapter aux produits réels

GlossaFlow : jobs Node/React et Python/TensorFlow distincts, tests contractuels de l'API interne, référence versionnée du modèle et corpus de traduction synthétique. GlossaLearn : jobs Angular, Java/Spring Boot et Flask, scénarios de progression et tests avec MongoDB/Redis isolés. Conserver les versions de tous les composants dans un manifeste de release.

Les applications réelles, le profil de charge, les migrations de données, les contrôles RGAA et les sauvegardes ne sont pas simulés par cette API. Le document technique précise leur mise en œuvre progressive.

## Preuves et limites

Voir `VALIDATION.md` pour les contrôles exécutés localement. Un dépôt local et une archive ne prouvent pas l'exécution d'une CI hébergée : compléter avec l'URL du dépôt et celle d'une exécution réussie après publication.
