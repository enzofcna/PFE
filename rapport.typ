#set page(
  paper: "a4",
  margin: (x: 2.5cm, top: 2.5cm, bottom: 2.5cm)
)

// Notre fonction maison pour faire des liens vers le glossaire
#let gls(id, mot) = link(label(id))[#text(fill: blue, mot)]

#set text(
  font: "Liberation Serif",
  size: 11pt,
  lang: "fr"
)

#set par(justify: true)

#show ref: it => {
  let el = it.element
  if el != none and el.func() == terms.item {
    link(it.target)[#el.term]
  } else {
    it
  }
}

#place(top + left, scope: "column")[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1cm,
    align: center + horizon,
    
    rect(width: 100%, height: 120pt, stroke: 0.5pt + gray, radius: 2pt)[
      #align(center + horizon)[
        #image("images/logos/capa.webp", width: 90%)
      ]
    ],
    
    rect(width: 100%, height: 120pt, stroke: 0.5pt + gray, radius: 2pt)[
      #align(center + horizon)[
        #image("images/logos/ITII.webp", width: 70%)
      ]
    ]
  )

  #v(0.5cm)

  #align(center)[
    #rect(width: 60%, height: 95pt, stroke: 0.5pt + gray, radius: 2pt)[
      #align(center + horizon)[
        #image("images/logos/popo.webp", width: 95%)
      ]
    ]
  ]

  #v(2cm)

  #align(center)[
    #text(size: 26pt, weight: "bold")[Projet de fin d'étude] \
    #v(0.5cm)
    #text(size: 14pt, style: "italic")[Optimiser la compression vidéo par prétraitement IA : contourner les limites des outils classiques] \
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
      #text(size: 10pt)[Étudiant]
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
Le secteur de la #gls("vod", "vidéo à la demande (VOD)") a connu un essor très important notamment avec l’arrivée de nombreuses plateformes de contenu. Contrairement à la TNT où une seule antenne émet un signal capté par un grand nombre de foyers sans coût énergétique supplémentaire par spectateur, la VOD nécessite une connexion point à point. Chaque clic sur "Play" sur Netflix ou Amazon prime génère un flux dédié depuis un serveur (souvent via un #gls("cdn", "Content Delivery Network CDN")), augmentant fortement la consommation de bande passante et d'énergie. 
On comprend alors que dans ce contexte les algorithmes de compression visant à diminuer la taille de l’information transmise de manière optimisée : les "#gls("codec", "codecs")", deviennent de plus en plus importants. L’évolution de leurs performances a permis de rendre accessible ces services à de nombreuses personnes. Mais la difficulté d’évolution d’architecture rend l'adoption des nouvelles versions plus complexe, ce qui pousse souvent à l’utilisation d'outils n'étant pas les plus optimisés.

=== Du diffuseur jusqu’au salon
La chaîne #gls("vod", "VOD") est un processus complexe qui transforme une scène captée en une vidéo diffusée mondialement. Cette chaîne se décompose en cinq étapes majeures :

- *La source*: Les caméras et microphones enregistrent la vidéo et l'audio bruts. Un appareil de capture convertit ces signaux physiques en un format numérique exploitable par un ordinateur, il se passe alors aussi un grand nombre de traitements (montage) afin d’obtenir un résultat satisfaisant.
- *Encodage* (Compression de la vidéo) : C'est ici qu'intervient le premier rôle clé des algorithmes de compression (#gls("codec", "codec")). Comme les données brutes sont trop volumineuses, l'encodeur les compresse (en utilisant des standards comme H.264, #gls("hevc", "H.265") ou AV1) pour optimiser le poids du fichier sans sacrifier la qualité. Cette étape se situe côté fournisseur, avant de transmettre la vidéo.
- *Serveur* : Le serveur reçoit le flux, le traite et le convertit en plusieurs versions (transcodage) pour s'adapter à différents appareils et débits.
- *#gls("cdn", "CDN") (Distribution)* : Un réseau de serveurs répartis mondialement stocke des copies du contenu. Cela permet de diffuser le flux depuis le serveur le plus proche de l'utilisateur, réduisant ainsi la latence et les interruptions.
- *Lecteur/Décodeur* : C'est l'étape finale. Le lecteur (application, navigateur) reçoit le flux compressé. Le #gls("codec", "codec") intervient ici : le décodeur transforme les données compressées en images et sons lisibles pour l'écran de l'utilisateur. Cette étape se situe côté utilisateur.

#align(center)[
  #figure(
    image("images/VODtransfr.png", width: 80%, height: 110pt)
    ,
    caption: [Schéma illustrant la chaîne de transmission d'une vidéo à la demande #gls("vod", "VOD"), @coffie2025streaming]
  ) <vod_transmission>
]

Ces processus concernent les données vidéos mais aussi audio, dans notre cas uniquement les données vidéos nous intéressent pour ce projet.

Il est important de mettre en avant la différence et le déséquilibre aux moments clés de l’encodage et du décodage.

Côté Fournisseur : L'encodage est une opération réalisée sur les serveurs du diffuseur, ce qui techniquement, est alors plus simple pour implémenter de nouvelles méthodes, car le diffuseur possède le contrôle total de son infrastructure. Bien qu' évolutive, cette infrastructure répond tout de même à une logique d’optimisation des coûts, une solution trop gourmande en calculs pourrait faire exploser les coûts pour les fournisseurs, ou encore une solution n’apportant pas une grande optimisation mais demandant de modifier toute l’architecture sera aussi difficilement acceptable de ce point de vue.
Côté utilisateur : Le décodage est effectué directement par l'appareil de l'utilisateur (TV, smartphone). Ces appareils utilisent des puces de décodage matériel conçues pour être économes en énergie et rapides. Ces puces sont figées lors de la fabrication. La seule alternative, pour un appareil dépourvu du circuit adéquat, est le décodage logiciel, ce qui signifie faire exécuter le calcul de décodage par le processeur général. Cette voie est universelle mais bien moins efficace. Il est donc extrêmement complexe de modifier le comportement de ce décodage ou d'y introduire de nouvelles méthodes, car cela nécessiterait de mettre à jour le matériel ou d'imposer des contraintes incompatibles avec les appareils existants. Cette limite s’explique notamment car les nouvelles solutions, apportant une optimisation sont accompagnées d’un nombre plus important de calculs, ce qui n’est pas toujours supporté par l’ensemble des appareils.

On comprend alors que la balance se trouve, à court terme, dans des solutions d’optimisations peu gourmandes en ressources. Cela permet alors de combler l’optimisation des coûts de l'entreprise, mais aussi répondre aux limites matérielles côté utilisateurs. On peut aussi prédire des modifications futures plus importantes advenant à la suite d’une maturité suffisante des outils nécessitant cette évolution.

De par ce constat, on peut estimer qu'une optimisation réaliste se trouverait alors en amont du transfert de la vidéo. En particulier car une vidéo encodée sera transmise à un grand nombre d'utilisateurs, optimiser une vidéo pourrait alors devenir intérressant plus rapidement.

=== Les enjeux économiques de la #gls("vod", "VOD") et liens avec la recherche

Expliquer les enjeux, les acteurs, leurs poids et en quoi cela influe directement notre cellule et la recherche en général car la majorité des projets sont en lien avec ces acteurs et leurs besoins et les tests des nouveautés face à un panel d'utilisateur.
Prendre l'exemple de l'étude qui met en avant le challenge lié au stockage comme priorité n°1 @challengesVOD
Les aspects open source et open access sont aussi à mettre en avant, car ils permettent de faire évoluer les outils de compression mais aussi d'avoir un accès à des outils de mesure de qualité vidéo, qui sont pourtant des outils complexes et développés parfois en interne par ces entreprises.

=== Rapport d'utilisation des outils de compression
Pour mieux comprendre les éléments suivants, voici un bref historique des outils existants.

#align(center)[
  #figure(
    image("images/historique_codec.png", width: 100%, height: 125pt)
    ,
    caption: [Historique et évolution des outils de compression vidéo (#gls("codec", "codecs")) entre 1990 et 2017 @moreira2022digitalvideo]
  ) <historiqueCodec>
]

Afin de mettre en avant la difficulté d'évolution des outils de compression par les entreprises concernées, les figures suivantes illustrent la répartition d'utilisation des outils de compression en 2023 et 2024 sur un panel d'entreprises. On peut y voir que les outils les plus récents ne sont pas encore adoptés par la majorité des entreprises, ce qui montre la difficulté d'évolution de ces outils.
#align(center)[
  #figure(
    image("images/Codecs_2023.png", width: 80%, height: 200pt)
    ,
    caption: [Illustration de la répartition d'utilisation des outils de compression en 2023-2024 (Streaming & #gls("vod", "VOD")) sur un panel d'entreprises (en rouge : l'outil envisagé pour l'année suivante) @bitmovin2023report]
  ) <utilisationCodec2023>
]

#align(center)[
  #figure(
    image("images/Codecs_2024.png", width: 90%, height: 200pt)
    ,
    caption: [Illustration de la répartition d'utilisation des outils de compression en 2024-2025 uniquement pour la #gls("vod", "VOD") sur un panel d'entreprises (en rouge : l'outil envisagé pour l'année suivante) @bitmovin2024report]
  ) <utilisationCodec2024>
]

Il est intéressant de noter que les chiffres évoluent peu, ce qui prouve l’écart entre la volonté d’évolution et la faisabilité réelle. On voit que le #gls("codec", "codec") le plus utilisé en 2025 reste H.264, pourtant créé en 2003. Cependant #gls("hevc", "H.265") et AV1 représentent les candidats des prochaines années d’après ces sondages.
Un point important, énoncé dans la section précédente, le matériel actuel est aussi un point important à prendre en compte. À ce jour il existe beaucoup plus de matériel capable de décoder #gls("hevc", "H.265") nativement, ce qui le rend plus efficace et moins énergivore. Sans ce décodage natif, la tâche devient plus complexe pour des appareils plus anciens car ils doivent se débrouiller avec la puissance CPU en place, ce qui, notamment avec AV1, qui demande plus de calcul, devient plus compliqué voire impossible.

Le choix d’une cible d’optimisation réaliste et qui prend en compte ces différents éléments semble donc clair, #gls("hevc", "H.265") est aujourd'hui très intéressante pour ce cas d'utilisation pour tous les points évoqués.


== Problématique
Nous avons vu que la diffusion de contenu vidéo est soumise à de fortes contraintes, en particulier matérielles côté utilisateur. Optimiser un codec déjà en place comme H265, plutôt que d'en imposer un nouveau, apparaît donc comme la voie la plus réaliste : on réduit la taille des flux transmis sans toucher aux appareils des utilisateurs. C'est précisément ce que l'intelligence artificielle (IA) pourrait permettre.

L'idée explorée dans ce projet est d'utiliser l'IA en amont de la compression, pour prétraiter la vidéo : ajuster l'image de façon à la rendre plus facile à compresser, et ainsi réduire le poids du fichier final à qualité visuelle équivalente. L'intérêt de l'IA tient à sa capacité d'adaptation : là où les méthodes traditionnelles peinent face à la diversité des contenus, un modèle peut apprendre à repérer ce qui compte visuellement et à modifier l'image en conséquence. On obtient une approche potentiellement plus souple, et moins coûteuse en calcul que des optimisations classiques poussées.
Reste un obstacle majeur. Les codecs vidéo n'ont jamais été pensés pour servir dans un apprentissage : ils s'intègrent donc mal dans le flux de travail d'une IA. La question principale est alors de définir les moyens permettant à l'IA d'apprendre efficacement à travers un codec classique comme H265, malgré les limitations de ce dernier. C'est le verrou technique central du projet.

À cette question s'en ajoutent deux autres, propres au sujet. D'abord, comment évaluer la qualité d'une vidéo optimisée par IA, alors que les outils existants sont conçus pour juger une vidéo encodée de façon classique ? Ensuite, comment guider l'apprentissage pour qu'il simule la satisfaction réelle d'un utilisateur final, un point clé, mais un défi de taille, là encore parce que les outils actuels ne sont pas faits pour ça, la plupart des projets IA et vidéo reposent sur des mesures simples, eficaces pour orienter l'apprentissage, mais aveugles aux spécificités de la perception visuelle humaine.

En résumé, ce projet questionne la faisabilité d'une optimisation de la compression vidéo par IA dans le cadre des codecs existants comme H265. Il s'agit d'y intégrer l'IA pour gagner en performance tout en respectant les contraintes matérielles et les exigences de qualité visuelle. Le dépassement des verrous liés aux algorithmes de codage classiques et la définition des bons outils d'évaluation seront donc étudiés en parallèle, comme les deux faces d'un même problème.

= Présentation de l'environnement de travail

== L'entreprise
Capacités SAS est une filiale privée de valorisation de la recherche de Nantes Université. Créée en 2005, elle emploie aujourd’hui environ une centaine de collaborateurs. L’entreprise est détenue à 93 % par Nantes Université et 7 % par la chambre de Commerce et d’Industrie de Nantes Saint-Nazaire. L’entreprise est présente sur 3 villes du Grand Ouest : La Roche Sur Yon, Saint Nazaire et Nantes. Capacités est divisé en 13 cellules d'expertise. Les cellules portent des projets d’entreprise au sein des laboratoires auxquelles elles sont rattachées pour avoir accès à une expertise et être au plus près de la découverte scientifique. Elles apportent aussi un support à la recherche lors d’un besoin en ingénierie. Les cellules sont composées de chercheurs, ingénieurs et techniciens. Chaque équipe possède ses propres clients et gère une partie de son budget pour l’attribuer selon les ressources nécessaires. Il existe également des projets inter cellules pour regrouper plusieurs domaines d’expertise sur les sujets pluridisciplinaires. 

== La cellule IXPEL
Je travaille au sein de la cellule IXPEL, qui est intégrée au sein de l’équipe de recherche IPI (Image Perception Interaction) qui appartient au LS2N (Laboratoire des Sciences du Numérique de Nantes). L’équipe est spécialisée dans l’intelligence artificielle appliquée à l’image et la qualité d’expérience. On y retrouve par exemple des sujets liés à l'imagerie médicale, au traitement de documents manuscrits et l’expérience/qualité utilisateur face à du contenu vidéo, l’équipe est reconnue mondialement sur ce dernier sujet ce qui lui permet de travailler en collaboration avec les plus grandes entreprises du secteur et en particulier avec leurs équipes de recherche.

Les clients de notre cellule sont des grandes entreprises du numérique comme Meta, Netflix ou Amazon. L’équipe IPI et la cellule IXPEL sont reconnues pour les tests subjectifs et la qualité expérience c’est notamment pour ce genre de sujets que les projets avec ces entreprises portent. Les tests permettent par exemple de recueillir des données sur la satisfaction d’utilisateurs face à des contenus vidéo, ce qui permet par la suite d’évaluer des méthodes et solutions mises en place. Nous avons également comme client le laboratoire lui-même. Quand le laboratoire montre un besoin de programmation ou autres tâches d'ingénierie pour un des projets en cours, ils vont alors faire appel à notre cellule si cela reste dans nos domaines de compétences. D’autres clients plus ponctuels peuvent aussi faire appel à notre cellule pour une mise en place d'outils liés à la vision par ordinateur et à l’image plus généralement.

Cet environnement facilite donc les échanges avec le laboratoire, ce qui fluidifie l'avancement des projets de recherche mais apporte aussi à notre cellule un lien fort avec les thématiques de recherche actuelles ce qui pour nous est un argument très important car cela montre la possibilité de travailler sur des solutions innovantes. Ce lien est donc bénéfique pour les deux parties.

La cellule est actuellement composée de 8 membres, ce chiffre évolue fréquemment, notamment de par l'arrivée de stagiaires ou encore selon la durée des contrats en cours.

= Organisation du projet

== Contexte du projet
Ce projet est en lien avec Amazon Elemental, filiale d’Amazon. Ce groupe s'intéresse aux problématiques liées à la vidéo notamment dû aux différents services qu’ils proposent tel que prime vidéo. Ce projet prend part dans une collaboration à plus long terme et fait suite à d’autres projets en lien avec cet organisme.

Ce projet a pour ambition d’étudier le sujet de l’IA dans le cadre de l’optimisation vidéo, cela prend la forme d’une preuve de concept, où les études réalisées seront présentées à l’entreprise cliente afin de définir la faisabilité d’une telle optimisation. Pour ce faire différents jalons sont posés, quels outils permettent au mieux d’évaluer la qualité d’un contenu vidéo. Par la suite des FOM (Figure Of Merit) devront définir les méthodes d’évaluation de la réussite d’une optimisation. Ces premiers jalons donnent une base solide qui sera réutilisable pour les étapes d’optimisation. D’autres aspects du projet consiste aussi dans l’évaluation des méthodes d’optimisation par IA. C’est d’ailleurs dans cette partie que ce projet de fin d’étude prend place, le but est de définir les outils possibles pour ce genre d'optimisation, comment répondre aux différentes problématiques posées par les outils de codage vidéo classiques pour l’apprentissage. Il sera alors question d’implémenter des solutions et d’évaluer leurs performances et pertinence dans le projet. Ces tests sont aussi liés à l’évaluation des différents outils de mesures de qualité car ils seront la clé d’un apprentissage réussi.
Par la suite, une fois les différentes études menées sur l’outillage nécessaire à une optimisation réussie, l’objectif final sera de réaliser, sur des cas contrôlés de vidéo, de mettre ces outils en œuvre afin d’évaluer les possibles optimisations obtenues.
Il est important de rappeler que ce PFE s’intègre dans le projet et que différentes contributions seront réalisées plus tard, dans la suite du projet.


== Planning
Le projet est structuré autour de trois Work Packages complémentaires, s'étalant d'avril 2026 à mars 2027. 

L'articulation globale des tâches ainsi que l'enchaînement des différents jalons de validation sont détaillés dans le diagramme de Gantt disponible à la fin du document (voir @planning en annexe).


== Les membres du projet

Dans la section précédente nous avons évoqué le nombre de membres de la cellule, ici nous verrons combien de personnes participent à ce projet et les rôles de chacun.

*Patrick LE CALLET (Responsable scientifique)*

Il assure le bon déroulement du projet et les discussions avec le client afin d’aboutir aux exigences du projet de départ. Il est aussi un élément moteur des idées amenant à ce projet.

*Pierre LEBRETON (Ingénieur et responsable cellule)*

Encadrant des membres de la cellule et donc des participants au projet, il est au quotidien le garant de la qualité des actions liées au projet, il en est aussi le référent technique. Son rôle est plus polyvalent, il travaille sur des implémentations techniques mais aussi la gestion des différents aspects du projet.

*Lina GUEMBRI (Ingénieure)*

Son rôle se trouve majoritairement dans l’évaluation des #gls("metrique", "métriques") de qualité vidéo, l’étude de leurs défauts et les solutions permettant d’y échapper.

*Jipeng XIA (Stagiaire)*

Il travaille sur la thématique des outils d’optimisation de compression vidéo par filtrage IA en particulier en étudiant l’état de l’art des solutions actuelles et leurs implémentations.

*Mon rôle*

En tant qu’alternant, ce projet a commencé pour moi par une première étude sur l’utilisation d’une #gls("metrique", "métrique") de qualité vidéo dans le cas de l'entraînement d’un #gls("codec", "codec") neuronal. L’objectif était de faire ressortir des possibles améliorations mathématiques de cette métrique afin d’en améliorer la pertinence et son utilisation durant l’apprentissage. Cela était un premier pas dans ce domaine et m’a permis d’apprendre de nombreuses notions importantes.

Par la suite, dans le cadre de mon PFE, je travaille majoritairement sur les analyses et implémentations d’outils d’optimisation, plus particulièrement sur l'aspect #gls("proxy", "proxy") de #gls("codec", "codec") afin de contourner les limitations des outils classiques en d’autres termes créer un jumeau des outils classiques qui guidera l’apprentissage. Si l'on s'en fie au planning, cette tâche fait partie du Work package n°3 concernant l'étude des cas d'utilisation des métriques, dans ce cas le filtrage d'images en pré-compression. La thématique des outils de mesure de qualité vidéo étant directement liée à ce sujet, ma mission réside aussi dans l’étude des meilleurs outils pour ce cas d’utilisation et leurs spécificités, ce qui fait lien avec les différents autres jalons du projet.

== Outils et méthodes de travail

=== Outils de communication et de suivi
Présenter les outils de communications en ligne utilisés mattermost gitlab uncloud et serveur commun (partage de fichiers lourds notamment)
=== Adaptation aux outils
Présenter glicid et l'aspect formation nécessaire pour s'adapter à l'outil

=== Impact des outils utilisés
Parler de l'aspect collaboratif et commun avec le labo
Utilisation de glicid = reduction des infrastructures nécessaires pour le projet, Optimisation des ressources (pas utilisées que par nous, gain économique/écologique)

Les limites de l'outil (maintenance parfois longue) = Perte de temps et de flexibilité d'organisation des tâches

Indispensable pour notre équipe.

=== Méthodes de suivi et de travail

Explications des réunions, méthode POP et comment s'organisent les tâches.
Pour l'entreprise outil de suivi (laboxy pour préciser les projets auxquels on participe et les tâches réalisées)

= Compression et qualité vidéo : défis et solutions

== Contexte et formation pour l'équipe
Equipe jeune, formation sur les sujets (compression, deep learning notamment) et veille constante car le domaine évolue rapidement.
Environnement facilitant le partage de connaissance au sein de la cellule mais aussi de par le labo (séminaires, outils développés etc)

== Encodage : la réduction d'informations transmises
Remettre le contexte qu'une vidéo est une suite d'images et qu'il est possible de réduire la quantité en utilisant la redondance des zones similaires d'un image à la suivante.
Et que les images contiennent des informations redondantes au sein même de l'iamge (zone de ciel bleu), ce qui permet de réduire aussi la quantité d'information transmise pour la première iamge qui sera la base des suivantes.

== Utilisateur et compression ciblé
Reprendre la logique simplement de l'utilisation de la compréhension de l'utilisateur pour simplifier les vidéos sans pertes importantes

== Coûts des vidéos : logique et théorie
Expliquer la logique de la taille des vidéos (information prédictible => peu coûteuse)
Expliquer les mécanismes utilisés pour rendre les données plus simples transformation et #gls("quantification", "quantification") (expliquer la logique de la #gls("quantification", "quantification") et comment elle est utilisée pour réduire la taille des données)

== Évaluer le contenu vidéo

== Les limitations pour l'apprentissage

=== Limites mathématique des outils pour l'apprentissage
  (arrondi, choix du meilleur bloc, introduire alors le concept de différentiabilité)
Impossibilité d'utiliser les #gls("codec", "codecs") comme tel pour l'apprentissage (pas prévu pour, trop d'opérations bloquantes etc)

== Solutions existantes

=== Deep learning et méthodes de remplacement

Evoquer le graphe forward et backward avec plusieurs schémas simples et en quoi on peut séparer ces étapes et ce que ça permet de faire =>(mettre un calcul non optimisable dans la boucle)

Expliquer la modification de fonctions simples (round par exemple ou argmin) pour regler un problème de zone plate qui ne guide par l'apprentissage (ne donne pas le sens de la pente)

=== Les méthodes d'optimisation existantes
Evoquer la littérature sur le sujet et ce qui a été fait et en quoi tout n'est pas applicable à notre cas d'utilisation (filtre aussi en post processing coté utilisateur par exemple), les limites de ces méthodes et ce qu'elles apportent.

= Implémentation

== Objectif et difficultés

Introduire l'objectif d'être capable d'avoir plusieurs outils pour comparer les approches existantes en les adaptant. Mettre en avant l'aspect transmissions de connaissance à l'équipe.

Mettre en avant les choix pour aller vers H.265

Evoquer la difficulté de reproduire fidèlement une implémentation d'un papier de recherche, il faut donc souvent reprendre certains aspects depuis le début, c'est aussi une grosse partie du travail.

== Architecture globale 

(filtre #gls("proxy", "proxy") #gls("metrique", "métrique")) schéma et explications

== Codage neuronal
Expliquer la logique suivie pour utiliser un #gls("codec", "codec") neuronal pour reproduire #gls("hevc", "H.265"), les choix de conception et les limitations de ce #gls("codec", "codec") neuronal dans ce rôle de #gls("proxy", "proxy")
== Codage simplifié
Expliquer les bases utilisées pour reproduire un #gls("codec", "codec") simplifié qui permet d'avoir un environnement d'apprentissage qui reprend les contraintes d'un véritable #gls("codec", "codec"), les choix de conception et les limitations de cette version simplifiée.

== Guide d'optimisation
Expliquer le choix de #gls("metrique", "métriques") simples pour le moment la suite du projet mais pertinente ayant pour but de développer aussi cet aspect dans la suite du projet.

Et la logique suivie pour valider plus simplement les résultats.

== Les différentes approches

Expliquer les choix de tests et leurs raisons

== Limites et perspectives

= Résultats et analyses

== En tant que #gls("proxy", "Proxy")
Evaluer la fidélité des images face au vrai #gls("codec", "codec")
Evaluer la corrélation face à l'stimation de débit
Expliquer la différence entre les deux versions une apprise l'autre par mimétisme
Voir à quel point le proxy fonctionne (si on entraine dessus les résultats se reporte sur le vrai codec ?)

== Résultats face aux #gls("metrique", "métriques")
Expliquer le choix des #gls("metrique", "métriques") utilisées pour l'évaluation et les résultats obtenus, puis voir les scores que l'on obtient

== Test Visuel

Quelques exemples pour visualiser les effets des optimisations.

== Limites et perspectives

Les limites de ces #gls("metrique", "métriques") pour ce contenu modifié
Difficulté d'évaluer les résultats car les approches réagissent différemment.

= Conclusion

#pagebreak()
= Glossaire

/ VOD <vod>: *Video On Demand.* Vidéo à la demande. Mode de diffusion où chaque utilisateur déclenche un flux vidéo dédié au moment qu'il choisit, par opposition à une diffusion unique captée simultanément par tous comme la TNT.

/ CDN <cdn>: *Content Delivery Network.* Réseau de diffusion de contenu. Serveurs répartis mondialement qui stockent des copies de la vidéo pour la diffuser depuis le serveur le plus proche de l'utilisateur, réduisant la latence et les coûts.

/ Codec <codec>: *Coder-decoder.* Outil chargé de compresser la vidéo à l'encodage (côté fournisseur) et de la reconstituer au décodage (côté utilisateur).

/ HEVC / H.265 <hevc>: *High Efficiency Video Coding.* Norme de compression vidéo, successeur de H.264, offrant une efficacité accrue à qualité égale. C'est le codec ciblé par ce projet, retenu pour son support matériel répandu.

/ CABAC <cabac>: *Context-Adaptive Binary Arithmetic Coding.* Méthode de codage entropique utilisée par H.265, combinant deux optimisations : le choix de probabilités selon le contexte (les coefficients voisins) et leur mise à jour adaptative au fil du codage.

/ Proxy <proxy>: *Modèle de substitution.* Dans ce projet, modèle de substitution différentiable reproduisant le comportement d'un codec réel, afin de pouvoir guider l'apprentissage d'un réseau de neurones là où le codec d'origine ne le permettrait pas.

/ DCT <dct>: *Discrete Cosine Transform.* Transformée en cosinus discrète. Transformation appliquée aux blocs de l'image qui réorganise l'information par fréquences, séparant les zones lisses (basses fréquences) des zones de détail (hautes fréquences), sans perte d'information.

/ Quantification <quantification>: *Réduction de précision.* Étape de la compression qui réduit la précision des coefficients issus de la DCT (division puis arrondi). C'est l'étape où l'information est volontairement perdue, principalement sur les hautes fréquences, pour alléger le poids de la vidéo.

/ GOP <gop>: *Group Of Pictures.* Groupe d'images. Ensemble d'images consécutives codées ensemble, organisé autour d'une image de référence (intra) dont dépendent les images suivantes (prédites). Limiter sa taille évite de s'appuyer sur une image d'une autre scène.

/ FPS <fps>: *Frames Per Second.* Images par seconde. Nombre d'images affichées chaque seconde dans une vidéo (couramment 30 ou 60). Plus il est élevé, plus la redondance temporelle entre images consécutives est forte.

/ CRF / QP <crf-qp>: *Constant Rate Factor / Quantization Parameter.* Paramètres réglant l'intensité de la compression : plus leur valeur est élevée, plus la quantification est forte, donc plus la vidéo est légère mais dégradée. Le CRF vise une qualité constante tandis que le QP fixe un niveau de quantification rigide.

/ RGB <rgb>: *Red, Green, Blue.* Espace de représentation des couleurs où chaque pixel est décrit par trois valeurs (rouge, vert, bleu). Ces canaux sont fortement corrélés, ce qui le rend peu efficace pour la compression.

/ YUV <yuv>: *Luminance / Chrominance.* Espace de représentation séparant l'intensité lumineuse (luminance) des informations de couleur (chrominances). Mieux adapté à la compression que le RGB, car il permet de réduire la couleur sans trop affecter la perception.

/ Chrominance <chrominance>: *Composantes de couleur.* Composantes d'une image portant l'information de couleur (chrominance bleue et chrominance rouge). L'œil y étant moins sensible, elles sont fortement sous-échantillonnées lors de la compression.

/ Luminance <luminance>: *Intensité lumineuse.* Composante d'une image représentant son intensité lumineuse (les niveaux de gris). L'œil humain y est très sensible. C'est sur cette composante que se concentre le filtre développé dans ce projet.

/ Métrique <metrique>: *Évaluation de qualité.* Mesure visant à évaluer la qualité d'une vidéo, le plus souvent en cherchant à prédire le jugement qu'en porterait un utilisateur humain.

/ VMAF <vmaf>: *Video Multimethod Assessment Fusion.* Métrique de qualité développée par Netflix, devenue un standard de l'industrie. Elle combine plusieurs indicateurs extraits de l'image et du mouvement via un modèle appris (SVR) pour prédire la note qu'un utilisateur moyen donnerait. Elle ne traite que la luminance.

/ SVR <svr>: *Support Vector Regression.* Modèle d'apprentissage automatique "frugal" (peu coûteux par rapport à un réseau de neurones), utilisé notamment par la métrique VMAF pour relier les caractéristiques extraites d'une vidéo à un score de qualité.

/ MOS <mos>: *Mean Opinion Score.* Note d'opinion moyenne. Moyenne des notes de qualité attribuées par un panel d'utilisateurs à un contenu vidéo. C'est la référence "humaine" à laquelle on compare les métriques pour évaluer leur fiabilité.

/ VLM <vlm>: *Vision Language Model.* Modèle vision-langage. Modèle d'IA récent combinant compréhension d'image et de texte, offrant une analyse plus fine du contenu, mais coûteux en mémoire et difficile à utiliser comme guide d'apprentissage.

/ STE <ste>: *Straight Through Estimator.* Technique permettant de faire traverser une opération non dérivable. On exécute l'opération réelle à l'aller (forward) et on lui substitue une approximation dérivable au retour (backward). C'est ce qui rend possible l'usage d'un codec au cœur de l'apprentissage.

#pagebreak()

#bibliography("ref.bib", style: "ieee", title: "Références bibliographiques")


#pagebreak()

= Annexes
== Annexe 1 : Étude sur les plus gros challenges du secteur VOD/Streaming
#align(center)[
  #figure(
    image("images/prioriteEtude.png", width: 100%, height: 450pt)
    ,
    caption: [Illustration des challenges principaux face à un panel d'entreprise du secteur Streaming/#gls("vod", "VOD") pour l'année 2024-2025) @bitmovin2024report]
  ) <challengesVOD>
]

#page(flipped: true)[
  #set align(center + horizon)
  
  == Annexe 2 : Planning prévisionnel du projet <planning>
  
  #v(1cm)

  #figure(
    image("images/planning.png", width: 110%, height: 255pt),
    caption: [Planning global du projet (2026-2027)]
  )
]
= Remerciements

= Résumé