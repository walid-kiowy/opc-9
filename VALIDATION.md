# Validation du 4 octobre 2026

Les opérations suivantes ont été exécutées localement :

| Contrôle | Résultat |
|---|---|
| Tests Node | Deux tests réussis ; santé/version HTTP et rejet des routes inconnues |
| Build | Paquet tar.gz et empreinte SHA-256 créés |
| Test du paquet | Empreinte valide et version réellement servie vérifiée |
| Paquet corrompu volontairement | Rejeté avec un code de sortie non nul |
| Syntaxe Bash | Quatre scripts vérifiés avec bash -n |
| YAML | CI GitLab, workflow GitHub et playbook Ansible analysés |
| Garde-fou pédagogique secrets | Contrôle réussi sur les fichiers du dépôt |

La commande `bash scripts/verify.sh` reproduit syntaxe, garde-fou, tests, build, paquet servi et rejet du paquet corrompu. Le YAML est contrôlé séparément lors de la préparation du dossier. Les rapports locaux et le SHA du dépôt sont joints dans `docs/preuves-locales/`.

La lecture YAML n'est pas une validation CI Lint GitLab ni un test serveur de GitHub Actions. Le scan limité ne certifie pas l'absence de tous secrets ou vulnérabilités. Les tests ont utilisé le runtime Node fourni dans cet environnement ; les images CI doivent encore être exécutées sur un runner.

Non exécutés : publication distante, CI hébergée, connexion SSH, bootstrap Ansible et service systemd, déploiement sur une VM, retour arrière distant, restauration de données, mesure de performance des véritables produits. Aucun résultat de ces opérations n'est inventé.

Destination pédagogique retenue : GitHub, à créer plus tard. Voir `docs/publication-github.md` pour les champs de preuve à compléter. La validation du mentor reste également à obtenir.
