# Argumentaire de soutenance

## Ouverture

GlossaPro dispose déjà d'une partie des outils nécessaires. Mon diagnostic distingue les délais de livraison de GlossaFlow et la fiabilité de GlossaLearn. Le changement proposé porte sur les passages de relais, les preuves de qualité et l'exploitation mesurée. Je commence par réduire les risques urgents et tester une livraison reproductible avant de généraliser.

## Parcours de présentation proposé pour quinze minutes

1. Contexte et besoins, 2 minutes : présenter les 8 heures de déploiement et les 30 secondes en pic en précisant leurs périmètres.
2. Diagnostic, 3 minutes : montrer le VSM et les responsabilités. Expliquer que le total S03-S11 de 7 h 30 ne mesure pas les attentes et ne peut pas être additionné sans preuve aux 24 heures d'approbation.
3. Choix, 3 minutes : défendre GitLab CI et Ansible par leur proximité avec l'existant ; conserver Artifactory au pilote et différer une plateforme complexe.
4. Organisation, 2 minutes : présenter les binômes, le rôle des juniors, la revue commune et les décisions selon le risque.
5. Démonstration, 3 minutes : tests, paquet, empreinte et version servie. Identifier clairement l'API pédagogique et les opérations distantes encore à vérifier.
6. Mesure et limites, 2 minutes : présenter les KPI, l'accessibilité, la sobriété et les preuves nécessaires pour généraliser.

## Réponses aux objections probables

**Pourquoi ne pas conserver Jenkins ?** C'est une alternative crédible. GitLab CI réduit une interface d'intégration pour le pilote ; les flux non migrés restent sur Jenkins. La généralisation dépendra des mesures et de l'effort d'exploitation.

**Pourquoi pas Kubernetes dès maintenant ?** Les documents ne décrivent ni compétence suffisante ni dimensionnement requis. Je privilégie un pilote adoptable, puis je réévalue le besoin après mesure et formation.

**Pourquoi ne pas augmenter les serveurs immédiatement ?** La capacité peut être nécessaire, mais les causes des lenteurs ne sont pas démontrées. Le profiling évite de surdimensionner un composant qui n'est pas le goulet. La redondance nécessite aussi des domaines de panne distincts.

**Avez-vous atteint les objectifs ?** Les documents proposent des cibles. Les contrôles locaux et la CI GitHub du pilote sont vérifiés ; les résultats sur GlossaPro nécessitent accès au SI, baseline et pilote réel.

**Deux backends ne suffisent-ils pas pour la redondance ?** Non : Node et TensorFlow, ou Java et Flask, remplissent des fonctions différentes. Il faut répliquer chaque service critique pertinent.

**Comment protégez-vous les données ?** En séparant configurations et secrets, identités et environnements, puis en testant restauration et rotation. Un retour arrière du code ne restaure pas les données modifiées.

**Votre pipeline est-il entièrement prêt pour la production ?** Il initialise les gestes CI et fournit des scripts de déploiement pour une VM dédiée. Les contrôles sécurité complets et l'exécution distante doivent encore être validés. La CI pédagogique ne représente pas le logiciel propriétaire.

## Preuves à préparer avant la soutenance

Conserver l'URL du dépôt, une exécution CI réussie et une en échec, le paquet, son commit, la version servie, la procédure de retour arrière et la validation du mentor. Pour les mesures sur le SI, utiliser le même corpus et le même profil de charge avant et après.

## Traçabilité et adoption

Utiliser les besoins B01 à B08 du rapport et de la proposition pour expliquer le lien entre constat, choix et preuve attendue. Montrer la boucle PDCA : deux améliorations au plus en cours, revue hebdomadaire, bilan à S6 puis S12. Pour la formation, présenter un exercice individuel puis une vérification à deux et six semaines, plutôt qu’un taux de présence seul. Les 60 heures du projet ne représentent pas douze semaines de transformation du SI.

## Démonstration reproductible

Exécuter `bash scripts/verify.sh`. Montrer les deux tests HTTP, le build, le contrôle SHA-256 et la version réellement servie. Le message de checksum en échec est attendu dans le scénario de corruption volontaire ; le script doit ensuite terminer avec succès. Les rapports sont dans `docs/preuves-locales/`. La sonde vérifie le processus pédagogique, sans base ni dépendance métier.

GitHub héberge le pilote dans `walid-kiowy/opc-9`. La première CI a réussi : https://github.com/walid-kiowy/opc-9/actions/runs/37231259317 . Montrer les deux jobs et l’artefact, puis préciser qu’un rollback distant et une restauration n’ont pas été exécutés. La validation du mentor reste à obtenir.
