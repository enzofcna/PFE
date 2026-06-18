
#align(center)[
  #figure(
    table(
      columns: (auto, 1fr, 1fr),
      inset: 10pt,
      align: (col, row) => if row == 0 { center + horizon } else { left + horizon },
      stroke: (x, y) => if y == 0 { (bottom: 1pt + black) } else { 0.5pt + gray },
      
      // Entêtes (en gras)
      [*Configuration*], [*Précision (%)*], [*Temps de calcul (s)*],
      
      // Lignes de données
      [Modèle Baseline], [84.2], [120],
      [Modèle Optimisé v1], [89.5], [45],
      [Modèle Final v2], [92.1], [12]
    ),
    caption: [Comparaison des performances des différents modèles.]
  ) <tableau_perf>
]

Comme on peut le voir dans le @tableau_perf, la version v2 offre les meilleurs résultats.

== Insertion d'illustrations
Pour ajouter une image, on utilise la fonction `image` encapsulée dans une `figure` pour avoir une légende automatique et une étiquette de référence.
Comme le montre les travaux de Shannon (@shannon1948), le concept d'entropie est central.

#align(center)[
  #figure(
    // Remplacer le rectangle par : image("images/graphe.png", width: 70%)
    rect(width: 60%, height: 120pt, stroke: 0.5pt + black, radius: 4pt)[
      #align(center + horizon)[[Espace Graphique / Image]]
    ],
    caption: [Évolution de la fonction de perte en fonction des époques.]
  ) <graphe_perte>
]

Le @graphe_perte montre une convergence rapide dès la 10ème époque.


#bibliography("ref.bib", style: "ieee", title: "Références bibliographiques")