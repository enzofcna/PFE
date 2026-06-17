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
    #text(size: 26pt, weight: "bold")[Projet de fin d'étude] \
    #v(0.5cm)
    #text(size: 14pt, style: "italic")[TODO: Ajouter le sous-titre du rapport ici] \
  ]

  #v(6cm)

  #line(length: 100%, stroke: 1.5pt + gray)
  #v(0.2cm)
  
  #grid(
    columns: (1fr, 1fr),
    gutter: 1cm,
    [
      #text(size: 10pt, weight: "bold")[AUTEUR] \
      #v(0.1cm)
      
      #text(size: 12pt, weight: "bold")[Enzo LE BODO] \
      #text(size: 10pt)[Apprenti Ingénieur]
    ],
    [
      #text(size: 10pt, weight: "bold")[ENCADREMENT] \
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
  header: align(right)[Projet de fin d'étude Enzo LE BODO IDIA2026],
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


= Organisation du projet

== Contexte du projet
Ce projet est en lien avec Amazon Elemental, filiale d’Amazon. Ce groupe s'intéresse aux problématiques liées à la vidéo notamment dû aux différents services qu’ils proposent tel que prime vidéo. Ce projet prend part dans une collaboration à plus long terme et fait suite à d’autres projets en lien avec cet organisme.
Ce projet a pour ambition d’étudier le sujet de l’IA dans le cadre de l’optimisation vidéo, cela prend la forme d’une preuve de concept, où les études réalisées seront présentées à l’entreprise cliente afin de définir la faisabilité d’une telle optimisation. Pour ce faire différents jalons sont posés, quels outils permettent au mieux d’évaluer la qualité d’un contenu vidéo. Par la suite des FOM (Figure Of Merit) devront définir les méthodes d’évaluation de la réussite d’une optimisation. Ces premiers jalons donnent une base solide qui sera réutilisable pour les étapes d’optimisation. D’autres aspects du projet consiste aussi dans l’évaluation des méthodes d’optimisation par IA. C’est d’ailleurs dans cette partie que ce projet de fin d’étude prend place, le but est de définir les outils possibles pour ce genre d'optimisation, comment répondre aux différentes problématiques posées par les outils de codage vidéo classiques pour l’apprentissage. Il sera alors question d’implémenter des solutions et d’évaluer leurs performances et pertinence dans le projet. Ces tests sont aussi liés à l’évaluation des différents outils de mesures de qualité car ils seront la clé d’un apprentissage réussi.
Par la suite, une fois les différentes études menées sur l’outillage nécessaire à une optimisation réussie, l’objectif final sera de réaliser, sur des cas contrôlés d'image, de mettre ces outils en œuvre afin d’évaluer les possibles optimisations obtenues.
Il est important de rappeler que ce PFE s’intègre dans le projet et que différentes analyses seront réalisées plus tard, dans la suite du projet.

== Planning

== Les membres du projet

Dans la section précédente nous avons évoqué les différents membres de la cellule, ici nous verrons combien de personnes participent à ce projet et les rôles de chacun. De plus cela va permettre de mettre en avant la répartition des premiers jalons du projet.

*Patrick LE CALLET (Responsable scientifique)*

Il assure le bon déroulement du projet et les discussions avec le client afin d’aboutir aux exigences du projet de départ.

*Pierre LEBRETON (Ingénieur et responsable cellule)*

Encadrant des membres participant au projet, il est au quotidien le garant de la qualité des actions liées au projet, il en est aussi le référent technique. Son rôle est plus polyvalent, il travaille sur les différents aspects du projet.

*Lina GUEMBRI (Ingénieure)*

Son rôle se trouve majoritairement dans l’évaluation des métriques de qualité vidéo, l’étude de leurs défauts et les solutions permettant d’y échapper.

*Jipeng XIA (Stagiaire)*
Il travaille sur la thématique des outils d’optimisation de compression vidéo en particulier en étudiant l’état de l’art des solutions actuelles.

*Mon rôle*

En tant qu’alternant, ce projet a commencé pour moi par une première étude sur l’utilisation d’une métrique de qualité vidéo dans le cas de l'entraînement d’un codec neuronal. L’objectif était de faire ressortir des possibles améliorations mathématiques de cette métrique afin d’en améliorer la pertinence et son utilisation durant l’apprentissage. Cela était un premier pas dans ce domaine et m’a permis d’apprendre de nombreuses notions importantes.

Par la suite, dans le cadre de mon PFE, je travaille majoritairement sur les analyses et implémentations d’outils d’optimisation, plus particulièrement sur l’aspect proxy de codec afin de contourner les limitations des outils classiques en d’autres termes créer un jumeau des outils classiques qui guidera l’apprentissage. La thématique des outils de mesure de qualité vidéo étant directement liée à ce sujet, ma mission réside aussi dans l’étude des meilleurs outils pour ce cas d’utilisation.

= Compréhension des codecs 
Dans cette section, nous allons comprendre les codecs, leur utilité et la théorie de base qui permet de comment ces outils fonctionnent sera un prérequis pour certaines sections de ce document.

== Du diffuseur jusqu’au salon
La chaîne VOD est un processus complexe qui transforme une scène captée en une vidéo diffusée mondialement. Cette chaîne se décompose en cinq étapes majeures :

- *La source*: Les caméras et microphones enregistrent la vidéo et l'audio bruts. Un appareil de capture convertit ces signaux physiques en un format numérique exploitable par un ordinateur, il se passe alors aussi un grand nombre de traitements (montage) afin d’obtenir un résultat satisfaisant.
- *Encodage* (Compression) : C'est ici qu'intervient le premier rôle clé du codec. Comme les données brutes sont trop volumineuses, l'encodeur les compresse (en utilisant des standards comme H.264, H.265 ou AV1) pour optimiser le poids du fichier sans sacrifier la qualité. Cette étape se situe côté fournisseur, avant de transmettre la vidéo.
- *Serveur* : Le serveur reçoit le flux, le traite et le convertit en plusieurs versions (transcodage) pour s'adapter à différents appareils et débits.
- *CDN (Distribution)* : Un réseau de serveurs répartis mondialement stocke des copies du contenu. Cela permet de diffuser le flux depuis le serveur le plus proche de l'utilisateur, réduisant ainsi la latence et les interruptions.
- *Lecteur/Décodeur* : C'est l'étape finale. Le lecteur (application, navigateur) reçoit le flux compressé. Le codec intervient ici : le décodeur transforme les données compressées en images et sons lisibles pour l'écran de l'utilisateur. Cette étape se situe côté utilisateur.

#align(center)[
  #figure(
    image("images\VODtransfr.png", width: 80%, height: 110pt)
    ,
    caption: [Schéma illustrant la chaîne de transmission d'une vidéo à la demande (VOD)]
  ) <vod_transmission>
]

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


