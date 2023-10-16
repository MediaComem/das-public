## Conception du dataset de test pour la validation des citations

Le dataset a été construit en plusieurs étape durant. Si vous souhaitez reproduire au mieux un dataset permettant de tester toutes les fonctionnalitées, il vous faudra effectuer l'intégralité du processus de création.

1. Pour chaque dossier des trois types de publication (commercial, non-commercial et others). Prendre aléatoirement une dizaine de fichier par dossier PMC00xxxxx.
2. Choisir aléatoirement un `doi` dans le fichier `config/PLOS-Dataset-Oct8_2023.csv`
3. Checher l'article contenant ce doi ainsi que les citations dans les données venant de `PLOS` et insérer les nouveaux fichiers dans le dataset de test. Compter le nombre de fichier (il faut en déplacer au moins 3, l'article et deux articles de citations). Il y aura n-1 citations.
4. Executé les scripts `parser_main.py`puis `calculate.py`. Une fois les scripts terminés, dans un terminal, exécuté les commandes suivante:
   1.  mongosh --host localhost -u user -p pass
   2.  use contexts
   3.  db.stats_dev.find( { is_plos: true } )
5. Il ne devrait y avoir qu'une entrée (celle que vous avez ajouté). Toutefoirs, comme vous avez pris des données aléatoirement, il se peut qu'il y ait plus d'entrée. Il vous faudra alors vérifier que les dois sont bien dans le fichier `config/PLOS-Dataset-Oct8_2023.csv`.
6. Choisir aléatoirement un `doi` dans le fichier `config/PMC-Dataset-Oct8_2023.csv`
7. Checher l'article contenant ce doi ainsi que les citations dans les données venant de `PLOS` et insérer les nouveaux fichiers dans le dataset de test. Compter le nombre de fichier (il faut en déplacer au moins 3, l'article et deux articles de citations). Il y aura n-1 citations.
8. Executé les scripts `parser_main.py`puis `calculate.py`. Une fois les scripts terminés, dans un terminal, exécuté les commandes suivante:
   1.  mongosh --host localhost -u user -p pass
   2.  use contexts
   3.  db.stats_dev.find( { is_bmc: true } )
9. Il ne devrait y avoir qu'une entrée (celle que vous avez ajouté). Toutefoirs, comme vous avez pris des données aléatoirement, il se peut qu'il y ait plus d'entrée. Il vous faudra alors vérifier que les dois sont bien dans le fichier `config/PMC-Dataset-Oct8_2023.csv`.
10. A cette étape, vous pouvez vérifier le bon fonctionnement des citations. Pour cela, dans un terminal, exécuté les commandes suivantes:
    1.  mongosh --host localhost -u user -p pass
    2.  use contexts
    3.  db.stats_dev.find( { citations_total: { $gt: 0 }, is_plos: true } )
    4.  db.stats_dev.find( { citations_total: { $gt: 0 }, is_bmc: true } )

Il devrait y avoir autant d'entrée que durant les tests 4.3 et 8.3. De plus, le champs citation citations_total doit être égale au nombre de fichier déplacé moins 1 durant les étapes 3 et 7.
La vérification par date est cependant un peu plus complexe. Dans un premier temps, vous pouvez vous assurer que le nombre dans les champs `citations_one`, `citations_two` et `citations_three` sont correctes avec le champs `citation_counts`. En effet, `citations_one` contient le même nombre que l'entrée '0' dans `citation_counts`. `citations_two` doit-être la somme de '0' et '1' et finalement `citations_three`, la somme de '0', '1' et '2'.
Pour valider `citation_counts`, c'est un peu plus fastidieux. Il vous faudre rechercher la date de publication de votre article au mois prêt puis valider avec les dates de publications des articles citant le votre.

## Conception du dataset de test pour la validation du h_index

Avant de pouvoir effectuer cette étape, il faudra avoir créer un datase en suivant la proédure décrite précédement.
Une fois cela fait, nous pouvons commencer la validation du h_index. Dans l'état actuel, le h_index devrait être de 1 pour les tableaux retournés par les commandes `db.stats_dev.find( { citations_total: { $gt: 0 }, is_plos: true } )` et `db.stats_dev.find( { citations_total: { $gt: 0 }, is_bmc: true } )`. Si vous avez des h_index de deux, cela peut-être normal, il faudra alors vérifier dans la table utilisateur si ceux qui ont publié cette article ont publiée d'autres articles pouvant être dans le dataset que vous avez aléatoirement créer. Néanmoins, cela n'est pas nécessaire. Vous pouvez vous focaliser sur un utilisateur n'ayant qu'un h_index de 1 dans le tableau pour tester cette partie. La procédure pour tester le h_index est la suivante:
1. Dans le résultat de `db.stats_dev.find( { citations_total: { $gt: 0 }, is_plos: true } )`, prennez le nom de l'utilisateur souhaité et rechercher le dans le dataset global.
2. Ajouter l'article avec au moins deux citations dans votre dataset de test.
3. Dans un terminal, exécuté les commandes suivantes:
   1. mongosh --host localhost -u user -p pass
   2. use contexts
   3. db.authors_dev.find( { name: 'VotreAuteur'  } )
   4. Vous devriez avoir un h_index de 2
4. Maintenant, reprennez le résultat de `db.stats_dev.find( { citations_total: { $gt: 0 }, is_bmc: true } )`
5. Choisissez un des auteurs de l'article et cherché le dans le dataset global.
6. Ajouter l'article et un seul des articles le citant dans votre dataset de test
7. Dans un terminal, exécuté les commandes suivantes:
   1. mongosh --host localhost -u user -p pass
   2. use contexts
   3. db.authors_dev.find( { name: 'VotreAuteur'  } )
   4. Vous devriez avoir un h_index de 1
8. Maintenant si vous revenez aux résultats de `db.stats_dev.find( { citations_total: { $gt: 0 }, is_plos: true } )` et `db.stats_dev.find( { citations_total: { $gt: 0 }, is_bmc: true } )`. Vous devriez avoir dans le premier cas, votre auteurs choisie avec un h_index de 2 et pour le second, toujours de 1.