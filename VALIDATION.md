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

Non exécutés : connexion SSH, bootstrap Ansible et service systemd, déploiement sur une VM, retour arrière distant, restauration de données, mesure de performance des véritables produits. Aucun résultat de ces opérations n'est inventé.

Destination pédagogique : [walid-kiowy/opc-9](https://github.com/walid-kiowy/opc-9), publié le 4 octobre 2026. Voir `docs/publication-github.md` pour les champs de preuve à compléter. La validation du mentor reste également à obtenir.

## Exécution GitHub Actions réussie

- Dépôt : https://github.com/walid-kiowy/opc-9
- Commit testé : `20f6b6298e533a3db60fd2e4541bae4debe53b94`
- CI : https://github.com/walid-kiowy/opc-9/actions/runs/37231259317
- Conclusion : success ; jobs validate-test et build-integration réussis.
- Artefact : `release-20f6b6298e533a3db60fd2e4541bae4debe53b94` ; 1300 octets.
- Digest de l’archive GitHub : `sha256:f4fc38e0e02ff8a459663ca1b7dcc90807e772cb1a95ba9725ea2f1777653d39`.

Cette CI vérifie les tests HTTP, la syntaxe, le garde-fou élémentaire de secrets, le build et la version réellement servie par le paquet temporaire. Elle ne démontre pas un déploiement sur VM ni les performances des produits GlossaPro. Le digest ci-dessus concerne l’archive GitHub ; le paquet interne dispose de son propre fichier SHA-256.
