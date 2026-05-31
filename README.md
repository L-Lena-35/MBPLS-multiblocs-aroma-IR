# MBPLS-multiblocs-aroma-IR
Analyse multi-blocs (MBPLS) appliquée à des données Aromes &amp; IR pour prédire l’origine géographique.

Ce projet applique une approche multi‑blocs supervisée (MBPLS) afin d’analyser conjointement deux sources de données analytiques : un bloc Aroma (chromatographie) et un bloc IR (spectroscopie infrarouge). L’objectif est de prédire l’origine géographique d’échantillons alimentaires (vins) en combinant ces deux blocs complémentaires. Le travail comprend la préparation et la fusion des données, l’application d’un modèle MBPLS, l’analyse des composantes latentes, la visualisation des scores, variables et blocs, ainsi que la validation croisée Leave‑One‑Out pour estimer l’erreur de classification.

Les données utilisées proviennent de trois fichiers : AROMA38.csv, IR38.csv et Yorigine.csv. Après renommage des colonnes, fusion des tables et centrage‑réduction du bloc Aroma, la variable Y est transformée en variables indicatrices. La matrice multi‑blocs X est ensuite construite en combinant les deux blocs.

Le modèle MBPLS est appliqué avec différentes options de mise à l’échelle et un nombre maximal de dix composantes. Les résultats incluent la variance expliquée, les scores colorés par origine, les corrélations variables‑composantes, la structure des blocs et les contributions de chaque bloc. Une validation croisée Leave‑One‑Out est réalisée pour évaluer la performance du modèle et déterminer le nombre optimal de composantes.

Certaines fonctions utilisées dans ce projet, telles que MBPLS, MBplotScores, MBplotVars, MBplotBlocks ou MBValidation, ont été développées par un professeur dans le cadre d’un enseignement universitaire. Ces fonctions ne sont pas publiques et ne peuvent donc pas être transmises ni incluses dans ce dépôt pour des raisons de droits d’auteur. Elles doivent être chargées dans l’environnement R avant d’exécuter le script.

Pour reproduire l’analyse, il suffit de télécharger les données, de charger les fonctions fournies dans le cadre du cours, puis d’exécuter le script R. Les figures générées sont enregistrées dans le dossier Graphiques.
