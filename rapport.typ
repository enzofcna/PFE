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
    #text(size: 14pt, style: "italic")[Filtrage d'images grâce à l'intelligence artificielle pour assister l'optimisation de la compression vidéo] \
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
On comprend alors que dans ce contexte les outils de compression visant à diminuer la taille de l’information transmise de manière optimisée : les "codecs", deviennent de plus en plus importants. L’évolution de leurs performances à permis de rendre accessible ces services à de nombreuses personnes. Mais la difficulté d’évolution d’architecture rend l'adoption des nouvelles versions plus complexe, ce qui pousse souvent à l’utilisation d'outils n'étant pas les plus optimisés.

=== Du diffuseur jusqu’au salon
La chaîne VOD est un processus complexe qui transforme une scène captée en une vidéo diffusée mondialement. Cette chaîne se décompose en cinq étapes majeures :

- *La source*: Les caméras et microphones enregistrent la vidéo et l'audio bruts. Un appareil de capture convertit ces signaux physiques en un format numérique exploitable par un ordinateur, il se passe alors aussi un grand nombre de traitements (montage) afin d’obtenir un résultat satisfaisant.
- *Encodage* (Compression) : C'est ici qu'intervient le premier rôle clé des algorithmes de compression  (codec). Comme les données brutes sont trop volumineuses, l'encodeur les compresse (en utilisant des standards comme H.264, H.265 ou AV1) pour optimiser le poids du fichier sans sacrifier la qualité. Cette étape se situe côté fournisseur, avant de transmettre la vidéo.
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

Ces processus concernent les données vidéos mais aussi audio, dans notre cas uniquement les données vidéos nous intéressent pour ce projet.

Il est important de mettre en avant la différence et le déséquilibre aux moments clés de l’encodage et du décodage.

Côté Fournisseur : L'encodage est une opération réalisée sur les serveurs du diffuseur, ce qui techniquement, est alors plus simple pour implémenter de nouvelles méthodes, car le diffuseur possède le contrôle total de son infrastructure. Bien qu' évolutive, cette infrastructure répond tout de même à une logique d’optimisation des coûts, une solution trop gourmande en calcule pourrait faire exploser les coûts pour les fournisseurs, ou encore une solution n’apportant pas une grande optimisation mais demandant de modifier toute l’architecture sera aussi difficilement acceptable de ce point de vue.
Côté utilisateur : Le décodage est effectué directement par l'appareil de l'utilisateur (TV, smartphone). Ces appareils utilisent des puces de décodage matériel conçues pour être économes en énergie et rapides. Ces puces sont figées lors de la fabrication. La seule alternative, pour un appareil dépourvu du circuit adéquat, est le décodage logiciel, ce qui signifie faire exécuter le calcul de décodage par le processeur général. Cette voie est universelle mais bien moins efficace. Il est donc extrêmement complexe de modifier le comportement de ce décodage ou d'y introduire de nouvelles méthodes, car cela nécessiterait de mettre à jour le matériel ou d'imposer des contraintes incompatibles avec les appareils existants. Cette limite s’explique notamment car les nouvelles solutions, apportant une optimisation sont accompagnées d’un nombre plus important de calculs, ce qui n’est pas toujours supporté par l’ensemble des appareils.

On comprend alors que la balance se trouve, à court terme, dans des solutions d’optimisations peu gourmandes en ressources. Cela permet alors de combler l’optimisation des coûts de l'entreprise, mais aussi répondre aux limites matérielles côté utilisateurs. On peut aussi prédire des modifications futures plus importantes advenant à la suite d’une maturité suffisante des outils nécessitant cette évolution.

De par ce constat, on peut estimer qu'une optimisation réaliste se trouverait alors en amont du transfert de la vidéo. En particulier car une vidéo encodée sera transmise à un grand nombre d'utilisateurs.

=== Rapport d'utilisation des outils de compression
Pour mieux comprendre les éléments suivants, voici un bref historique des outils existants.

#align(center)[
  #figure(
    image("images\historique_codec.png", width: 100%, height: 125pt)
    ,
    caption: [Historique et évolution des outils de compression vidéo (codecs) entre 1990 et 2017]
  ) <historiqueCodec>
]

Afin de mettre en avnat la difficulté d'évolution des outils de compression par les entreprises concernées, les figures suivantes illustrent la répartition d'utilisation des outils de compression en 2023 et 2024 sur un panel d'entreprises. On peut y voir que les outils les plus récents ne sont pas encore adoptés par la majorité des entreprises, ce qui montre la difficulté d'évolution de ces outils.
#align(center)[
  #figure(
    image("images\Codecs_2023.png", width: 80%, height: 200pt)
    ,
    caption: [Illustration de la répartition d'utilisation des outils de compression en 2023 (Streaming & VOD) sur un panel d'entreprises (en rouge : l'outil envisagé pour l'année suivante)]
  ) <utilisationCodec2023>
]

#align(center)[
  #figure(
    image("images\Codecs_2024.png", width: 90%, height: 200pt)
    ,
    caption: [Illustration de la répartition d'utilisation des outils de compression en 2024-2025 (VOD) sur un panel d'entreprises (en rouge : l'outil envisagé pour l'année suivante)]
  ) <utilisationCodec2024>
]

Il est intéressant de noter que les chiffres évoluent peu, ce qui prouve l’écart entre la volonté d’évolution et la faisabilité réelle. On voit que le codec le plus utilisé en 2025 reste H264, pourtant créé en 2003. Cependant H265 et AV1 représentent les candidats des prochaines années d’après ces sondages.
Un point important, énoncé dans la section précédente, le matériel actuel est aussi un point important à prendre en compte. A ce jour il existe beaucoup plus de matériel capable de décoder H265 nativement, ce qui le rend plus efficace et moins énergivore. Sans ce décodage natif, la tâche devient plus complexe pour des appareils plus anciens car ils doivent se débrouiller avec la puissance CPU en place, ce qui, notamment avec AV1, qui demande plus de calcul, devient plus compliqué voire impossible.

Le choix d’une cible d’optimisation réaliste et qui prend en compte ces différents éléments semble donc clair, H265 est aujourd'hui très intéressante pour ce cas d'utilisation pour tous les points évoqués.


=== Les enjeux économiques de la VOD

TODO

== Problématique
Nous avons vu que la diffusion de contenu vidéo était soumise à de fortes contraintes, notamment de part les limitations matérielles côté utilisateur.
Ce projet vient donc d'une volonté d'optimiser les performances des outils de compression vidéo, en particulier H265, afin de réduire la taille des flux transmis tout en maintenant une qualité visuelle acceptable pour l'utilisateur final.Une optimisation, permettent d'améliorer l'efficacité de la compression sans nécessiter de modifications matérielles côté utilisateur.
Pour ce faire, l'utilisation de l'intelligence artificielle (IA) est envisagée comme un moyen d'apporter des améliorations significatives aux codecs existants. L'idée est d'explorer comment l'IA peut être utilisée pour prétraiter les vidéos avant la compression, rendant ainsi le contenu plus facile à compresser et potentiellement réduisant la taille des fichiers tout en maintenant une qualité visuelle satisfaisante. L'IA semble répondre à un réel défis dans la compression vidéo, s'adapter à la diversité des contenus qui rendent difficile l'optimisation par des méthodes traditionnelles. L'IA peut apprendre à identifier les caractéristiques visuelles importantes et à ajuster l'image en conséquence, offrant ainsi une approche qui pourrait s'avérer plus adaptative Ou au moins moins complexe ques des optimisations complexes très couteuses en calcul.

Cependant, l'apprentissage de modèles d'IA dans ce contexte pose des défis particuliers. Les outils de compression vidéo traditionnels ne sont pas conçus pour être utilisés dans un processus d'apprentissage, ce qui complique l'intégration de l'IA dans le flux de travail existant. Il est donc nécessaire de développer des méthodes et des outils spécifiques pour permettre à l'IA d'interagir efficacement avec les codecs vidéo, ce qui permettra d'apprendre de manière efficace et de comprendre les limites des outils de compression actuels.

En résumé, ce sujet questionne alors la faisabilité de l'utilisation de l'IA pour optimiser la compression vidéo, en particulier dans le contexte des codecs existants comme H265. Il s'agit d'explorer comment l'IA peut être intégrée dans le processus de compression pour améliorer les performances tout en respectant les contraintes matérielles et les exigences de qualité visuelle. Pour ce faire la question princiaple réside dans la défintion des moyens les plus pertinents pour répondre aux limitations des outils de compression vidéo classiques, pour permettre à l'IA d'apprendre efficacement.
De plus, des questions liées au projet dans sa globalité viennent s'ajouter, par exemple, comment évaluer la qualité d'une vidéo optimisée par IA, là où les outils classiques sont conçues pour évaluer la qualité d'une vidéo encodée par un codec classique. Il reste aussi à savoir quels commet guider l'apprentissage pour simuler la satisfaction d'un utilisateur final, ce qui est aussi un point clé de l'optimisation. Il est donc nécessaire de définir les outils et méthodes d'évaluation adaptés à ce contexte particulier pour répondre aux enjeux du projet final. Ce qui seront alors des aspects étudiés en parrallèle à l'implémentation des outils d'optimisation.

= Présentation de l'environnement de travail

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

#align(center)[
  #figure(
    image("images\planning.png", width: 80%, height: 110pt)
    ,
    caption: [Planning du projet dans sa globalité, avec les différentes étapes et jalons à atteindre]
  ) <planning>
]

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

Par la suite, dans le cadre de mon PFE, je travaille majoritairement sur les analyses et implémentations d’outils d’optimisation, plus particulièrement sur l’aspect proxy de codec afin de contourner les limitations des outils classiques en d’autres termes créer un jumeau des outils classiques qui guidera l’apprentissage. La thématique des outils de mesure de qualité vidéo étant directement liée à ce sujet, ma mission réside aussi dans l’étude des meilleurs outils pour ce cas d’utilisation et leurs spécificités.

== Outils et méthodes de travail

=== Outils de communication et de suivi
Présenter les outils de communications en ligne utilisés mattermost gitlab uncloud et serveur commun (partage de fichiers lourds notamment)
=== Adaptation aux outils
Présenter glicid et l'aspect fromation nécessaire pour s'adapter à l'outil

=== Impact des outils utilisés
Parler de l'aspect collaboratif et commun avec le labo
Utilisation de glicid = reduction des infrastructures necessaires pour le projet, Optimisation des ressource (pas utilisées que par nous gain economique/écologique)

Les limites de l'outils (maintenance parfois longues) = Perte de temps et de fléxibilité d'organisation des taches

Reste indispensable pour notre équipe.

=== Méthodes de suivi et de travail

= Compression et qualité vidéo : défis et solutions

== Context et formation pour l'équipe

== Encodage : la réduction d'informations transmises

== Évaluer le contenu vidéo

== Les limitations pour l'apprentissage

=== Limites mathématique des outils pour l'apprentissage
	(arrondi, choix du meilleur bloc, introduire alors le concept de différentiabilité)
Impossibilité d'utiliser les codecs comme tel pour 	l'apprentissage (pas prévu pour, trop d'opérations bloquantes etc)


== Solutions existantes

=== Deep learning et méthodes de remplacement

Evoquer le graphe forward et backarda vec plusieurs schema et en quoi on pour les séparer et ce que ça permet de faire

=== Les méthodes existantes
Evoquer la littérature sur le sujet et ce qui a été fait et en quoi tout n'est pas applicable à notre cas d'utilisation, les limites de ces méthodes et ce qu'elles apportent.

= Implémentation

== Objectif et difficultés

Introduire l'objectif d'être capable d'avoir plusieurs outils pour comparer les approches existantes en les adaptant. Mettre en avant l'aspect transmissions de connaissance à l'équipe.

Evoquer la difficulté de reproduire fidèlement une implémentation d'un papier de recherche, il faut donc souvent reprendre certains aspects depuis le début, c'est aussi une grosse partie du travail


== Mise en place globale 

(filtre proxy métrique) schema et explications

== Codage neuronal
expliquer la logique suivie pour utiliser un codec neuronal pour reproduire H265, les choix de conception et les limitations de ce codec neuronal dans ce rôle de proxy
== Codage simplifié
expliquer les bases utilisées pour reproduire un codec simplifié, les choix de conception et les limitations de ce codec simplifié.

== Guide d'optimisation
Expliquer le choix de métriques simple pour le moment la suite du projet mais pertinente ayant pour but de développer aussi cet aspect dans la suite du projet.

Et la logique suivie pour valider plus simplement les résultats.

== Les différentes approches

Expliquer les choix de tests et leurs raisons

== Limites et perspectives

= Résultats et analyses

== En tant que proxy 
Evaluer la fidélité des iamges face au vrai codec

== Résultats face aux métriques
Expliquer le choix des métriques utilisées pour l'évaluation et les résultats obtenus, 

== Test Visuel

Quelques exemples pour visualisaer les effets des optimisations.

== Limites et perspectives

les limites de ces métriques pour ce contenu modifié
Difficulté d'évaluer les résultats.


= Conclusion

= Glossaire

= Remerciements

= Résumé





