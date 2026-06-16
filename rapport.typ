#set page(
  paper: "a4",
  margin: (x: 2.5cm, top: 2.5cm, bottom: 2.5cm)
)
#set text(
  font: "Liberation Serif",
  size: 11pt,
  lang: "fr"
)

#set par(justify: true)

#place(top + left, scope: "column")[
  #grid(
    columns: (1fr, 1fr), // Deux colonnes égales
    gutter: 1cm,         // Espace horizontal entre les deux logos
    align: center + horizon,
    
    // Premier logo (ex: popo)
    rect(width: 100%, height: 120pt, stroke: 0.5pt + gray, radius: 2pt)[
      #align(center + horizon)[
        #image("images/logos/capa.webp", width: 90%)
      ]
    ],
    
    // Deuxième logo (ex: ITII)
    rect(width: 100%, height: 120pt, stroke: 0.5pt + gray, radius: 2pt)[
      #align(center + horizon)[
        #image("images/logos/ITII.webp", width: 70%)
      ]
    ]
  )

  #v(0.5cm) // Espace vertical entre la ligne du haut et le logo du bas

  // --- BLOC INTERMÉDIAIRE : Le troisième logo plus long et centré ---
  #align(center)[
    // Ajout du '#' devant rect car on est repassé en mode contenu dans les crochets []
    #rect(width: 60%, height: 95pt, stroke: 0.5pt + gray, radius: 2pt)[
      #align(center + horizon)[
        #image("images/logos/popo.webp", width: 95%)
      ]
    ]
  ]

  #v(2cm)
  


  // Section Titre du Rapport
  #align(center)[
    #text(size: 26pt, weight: "bold")[Projet de fin d'études] \
    #v(0.5cm)
    #text(size: 14pt, style: "italic", fill: gray)[TODO: Ajouter le sous-titre du rapport ici] \
  ]

  #v(6cm)

  #line(length: 100%, stroke: 0.5pt + gray)
  #v(0.2cm)
  
  #grid(
    columns: (1fr, 1fr),
    gutter: 1cm,
    [
      #text(size: 10pt, weight: "bold", fill: gray)[AUTEUR] \
      #v(0.1cm)
      #text(size: 12pt, weight: "bold")[Enzo LE BODO] \
      #text(size: 10pt)[Apprenti Ingénieur]
    ],
    [
      #text(size: 10pt, weight: "bold", fill: gray)[ENCADREMENT] \
      #v(0.1cm)
      
      #text(size: 11pt, weight: "bold")[Pierre LEBRETON] \
      #text(size: 9.5pt, style: "italic")[Tuteur Entreprise]
      
      #v(0.3cm)
      
      #text(size: 11pt, weight: "bold")[Matthieu PERREIRA DA SILVA] \
      #text(size: 9.5pt, style: "italic")[Tuteur Académique]
      
      #v(0.3cm)
      
      #text(size: 11pt, weight: "bold")[Bruno THEILLAC] \
      #text(size: 9.5pt, style: "italic")[Référent Apprentissage]
    ]
  )
]

#pagebreak()

#set page(
  header: align(right)[Projet de fin d'études Enzo LE BODO IDIA2026],
  footer: context [
    #align(center)[
      #counter(page).display("1 / 1", both: true)
    ]
  ]
)
#counter(page).update(1)

#set heading(numbering: "1.1.")
#show heading: it => [
  #v(0.5cm)
  #it
  #v(0.2cm)
]

#text(weight: "bold", size: 16pt)[Table des matières]
#v(0.3cm)
#outline(
  title: none,
  indent: 1.5em
)

#pagebreak()


= Introduction <intro>
Ce document sert de guide de référence pour utiliser les fonctionnalités avancées de Typst. Nous verrons comment structurer le document, insérer des éléments complexes et faire des renvois dynamiques. Comme mentionné dans l'introduction (@intro), la structure est entièrement automatisée.

== Contexte
Le secteur de la vidéo à la demande VOD a connu un essor très important notamment avec l’arrivée de nombreuses plateformes de contenu. Contrairement à la TNT où une seule antenne émet un signal capté par un grand nombre de foyers sans coût énergétique supplémentaire par spectateur, la VOD nécessite une connexion point à point. Chaque clic sur "Play" sur Netflix ou Amazon prime génère un flux dédié depuis un serveur (souvent via un Content Delivery Network CDN), augmentant fortement la consommation de bande passante et d'énergie. 
On comprend alors que dans ce contexte les outils de compression visant à diminuer la taille de l’information transmise de manière optimisée : les codecs, deviennent de plus en plus importants. L’évolution de leurs performances à permis de rendre accessible ces services à de nombreuses personnes. Mais la difficulté d’évolution d’architecture côté client rend l'adoption des nouvelles versions plus longue, ce qui pousse souvent à l’utilisation des codecs n'étant pas les plus optimisés. De plus, la limite du paradigme utilisé par ces algorithmes pour transmettre l’information se rapproche. Un courant de recherche émerge visant à tenter de dépasser ces performances en utilisant des codecs neuronaux, un changement de paradigme qui semble prometteur mais qui reste pour le moment uniquement orienté vers la recherche fondamentale, notamment dû à la difficulté d'implémentation de ces méthodes sur les architectures existantes et de par l’évolution très rapide de ce domaine. Le compromis actuel semble donc se trouver dans une utilisation bien pensée des outils existants associée à l’intelligence artificielle visant à améliorer l’existant en apportant une aide permettant de simplifier le travail des algorithmes de compression.

== Problématique
L’objectif est donc d’apporter une aide guidée par l’IA afin d’optimiser les performances des codecs actuels. La complexité d’évolution de l’architecture côté client semble imposer que cette modification se place en amont de la compression, action qui serait alors réalisée par le fournisseur de vidéo. Des projets de recherche traitent des sujets similaires, abordent la possibilité de filtrer les vidéos rendant alors le contenu plus simple à compresser le rendant alors moins lourd. Des visions différentes se retrouvent afin de répondre à ce problème, l’utilisation d’un codec neuronal entraîné à produire des vidéos similaires à celles du codec source. D’autres s’appuient sur des versions simplifiées de ces codecs, en gardant au maximum les opérations des versions d'origine. Il est donc question de savoir quelle serait la meilleure option pour répondre à cette problématique de remplacement de codec.
Les questions autour de ces projets résident dans la manière d’y parvenir. Les algorithmes de compression actuels n’étant pas prévus pour des tâches d’apprentissage et regroupant beaucoup d'opérations non différentiables, trouver un moyen de répliquer un outil qui permet de guider l’apprentissage en remplacement de ces codecs est un premier point bloquant.
D’autres problématiques se posent : l’optimisation de réseaux de neurones liés à la vidéo est souvent associée à des mesures de qualités vidéo simples qui ne perçoivent pas les spécificités liées à la satisfaction visuelle des utilisateurs et donc la vision humaine mais qui permettent un apprentissage efficace et simple.
Un grand nombre de métriques existent mais malgré des performances de corrélation à la vision humaine importantes, elles peuvent parfois devenir trop complexes à optimiser ou non adaptées à cette tâche d’apprentissage.
On cherche donc à déterminer quels métriques utiliser et comment les utiliser dans le contexte d’apprentissage dans le but d’obtenir un résultat le plus fidèle possible à ce que les utilisateurs théoriques pourraient penser de ces images.
L’ajout d’une étape supplémentaire en amont de la compression n’étant pas neutre énergétiquement parlant, une utilisation en production et l’apport de l’optimisation d’un tel outil devrait donc au minimum couvrir son coût d’utilisation. Il est alors important de questionner son coût et ses effets afin d’apporter une réponse à son utilité.

= Présenattion d el'environnement de travail

== L'entreprise
Capacités SAS est une filiale privée de valorisation de la recherche de Nantes Université. Créée en 2005, elle emploie aujourd’hui environ une centaine de collaborateurs. L’entreprise est détenue à 93 % par Nantes Université et 7 % par la chambre de Commerce et d’Industrie de Nantes Saint-Nazaire. L’entreprise est présente sur 3 villes du Grand Ouest : La Roche Sur Yon, Saint Nazaire et Nantes. Capacités est divisé en 13 cellules d'expertise. Les cellules portent des projets d’entreprise au sein des laboratoires auxquelles elles sont rattachées pour avoir accès à une expertise et être au plus près de la découverte scientifique. Elles apportent aussi un support à la recherche lors d’un besoin en ingénierie. Les cellules sont composées de chercheurs, ingénieurs et techniciens. Chaque équipe possède ses propres clients et gère une partie de son budget pour l’attribuer selon les ressources nécessaires. Il existe également des projets inter cellules pour regrouper plusieurs domaines d’expertise sur les sujets pluridisciplinaires. 

== La cellule IXPEL
Je travaille au sein de la cellule IXPEL, qui est intégrée au sein de l’équipe de recherche IPI (Image Perception Interaction) qui appartient au LS2N (Laboratoire des Sciences du Numérique de Nantes). L’équipe est spécialisée dans l’intelligence artificielle appliquée à l’image et la qualité d’expérience. On y retrouve par exemple des sujets liés à l'imagerie médicale, au traitement de documents manuscrits et l’expérience/qualité utilisateur face à du contenu vidéo, l’équipe est reconnue mondialement sur ce dernier sujet ce qui lui permet de travailler en collaboration avec les plus grandes entreprises du secteur et en particulier avec leurs équipes de recherche.

Les clients de notre cellule sont des grandes entreprises du numérique comme Meta, Netflix ou Amazon. L’équipe IPI et la cellule IXPEL sont reconnues pour les tests subjectifs et la qualité expérience c’est notamment pour ce genre de sujets que les projets avec ces entreprises portent. Les tests permettent par exemple de recueillir des données sur la satisfaction d’utilisateurs face à des contenus vidéo, ce qui permet par la suite d’évaluer des méthodes et solutions mises en place. Nous avons également comme client le laboratoire lui-même. Quand le laboratoire montre un besoin de programmation ou autres tâches d'ingénierie pour un des projets en cours, Ils vont alors faire appel à notre cellule si cela reste dans nos domaines de compétences. D’autres clients plus ponctuels peuvent aussi faire appel à notre cellule pour une mise en place d'outils liés à la vision par ordinateur et à l’image plus généralement.

Cet environnement facilite donc les échanges avec le laboratoire ce qui fluidifie l'avancement des projets de recherche mais apporte aussi à notre cellule un lien fort avec les thématiques de recherche actuelles ce qui pour nous est un argument très important car cela montre la possibilité de travailler sur des solutions innovantes. Ce lien est donc bénéfique pour les deux parties.

=== Les membres de la cellule
La cellule est actuellement composée de 8 membres, ce chiffre évolue fréquemment, notamment de par l'arrivée de stagiaires ou encore selon la durée des contrats en cours.
L’équipe se compose actuellement : 
d’un responsable scientifique, un responsable opérationnel (également mon tuteur industriel), deux  ingénieures de recherche (une ancienne doctorante au sein de l’IPI et une ancienne stagiaire) un autre ingénieur de recherche (ancien doctorant dans une autre équipe de recherche), deux apprentis ingénieurs dont je fais partie et un stagiaire.





== Tableaux de données
Les tableaux se définissent via la fonction `table`. Les entêtes sont automatiquement mises en évidence.

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


