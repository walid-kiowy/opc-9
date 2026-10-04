# Publier la démonstration sur GitHub

Le dépôt cible est https://github.com/walid-kiowy/opc-9, créé le 4 octobre 2026. L’accès de l’intégration a été corrigé et le pipeline a été publié. La première CI a réussi : https://github.com/walid-kiowy/opc-9/actions/runs/37231259317 . Les étapes ci-dessous permettent de reproduire la publication ou de préparer un nouveau dépôt. GlossaPro conserve GitLab comme cible dans la stratégie ; le sujet initial accepte GitLab ou GitHub pour le pipeline pédagogique.

## Préparer le dépôt

1. Utiliser le dépôt vide `walid-kiowy/opc-9` déjà créé. Il est public. Les fichiers fournis concernent uniquement la démonstration pédagogique ; aucun code propriétaire ou secret ne doit y être ajouté.
2. Extraire l’archive puis ouvrir un terminal dans `glossapro-pipeline`.
3. Sur Linux avec Node 22, exécuter `bash scripts/verify.sh`.
4. Initialiser Git si l’archive ne contient pas d’historique :

```sh
git init -b main
git add .
git commit -m "Initialiser le pilote DevOps GlossaPro"
git remote add origin https://github.com/walid-kiowy/opc-9.git
git push -u origin main
```

Renseigner son identité Git personnelle si Git la demande. Utiliser l’authentification GitHub habituelle ; ne pas mettre de jeton dans la commande, le README ou les fichiers du dépôt. Si `origin` existe déjà, vérifier `git remote -v` avant de le modifier.

## Vérifier la CI

Dans l’onglet Actions, ouvrir le workflow `GlossaPro pilot CI` déclenché par le push sur `main`. Les jobs `validate-test` puis `build-integration` doivent réussir. Le deuxième job lance temporairement le paquet construit, vérifie la version servie et publie `release-<SHA>`. Télécharger l’artefact et vérifier le SHA-256 depuis son répertoire :

```sh
sha256sum -c release.tar.gz.sha256
```

La CI ne demande aucun secret de déploiement. Le token du workflow est limité à la lecture du contenu. La rétention de l’artefact est de 30 jours, dans les limites de la politique du dépôt. La CI ne déploie pas sur une VM ; les scripts distants et la configuration GitLab sont fournis séparément.

## Montrer un échec puis une correction

Créer une branche `demo/test-bloquant`, modifier temporairement l’attendu `test-release` dans l’assertion du test HTTP puis ouvrir une pull request. Vérifier que le test échoue et que le build est bloqué. Corriger l’attendu dans un deuxième commit et vérifier le succès de la même pull request. Ne fusionner que la correction complète. Conserver les deux URLs d’exécution et leurs commits.

## Preuves à compléter

| Preuve | État au 4 octobre 2026 |
|---|---|
| URL du dépôt GitHub | https://github.com/walid-kiowy/opc-9 |
| SHA du commit testé | 20f6b6298e533a3db60fd2e4541bae4debe53b94 |
| URL de CI réussie | https://github.com/walid-kiowy/opc-9/actions/runs/37231259317 |
| URL de CI en échec puis corrigée | À compléter sur la branche de démonstration |
| Artefact et empreinte | Artefact publié par la CI ; digest GitHub disponible dans VALIDATION.md |
| Staging et production distants | Non exécutés |
| Validation du mentor | À obtenir |

Documentation officielle consultée le 4 octobre 2026 : [syntaxe des workflows](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax) et [artefacts de workflow](https://docs.github.com/en/actions/concepts/workflows-and-actions/workflow-artifacts).
