#import "@preview/cetz:0.4.2": canvas, draw
#set page(
  paper: "a4",
  margin: (x: 2.5cm, top: 2.5cm, bottom: 2.5cm),
)

// Notre fonction maison pour faire des liens vers le glossaire
#let gls(id, mot) = link(label(id))[#text(weight: "semibold", mot)]

#set text(
  font: "Liberation Serif",
  size: 11.5pt,
  lang: "fr",
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
    ],
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
    #text(
      size: 14pt,
      style: "italic",
    )[Optimiser la compression vidéo par prétraitement IA : contourner les limites des outils classiques] \
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
    ],
  )
]

#pagebreak()

#set page(
  header: align(right)[Projet de fin d'étude Enzo LE BODO IDIA2026],
  footer: context [
    #align(center)[
      #counter(page).display("1 / 1", both: true)
    ]
  ],
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
  indent: 1.5em,
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
    image("images/VODtransfr.png", width: 80%, height: 110pt),
    caption: [Schéma illustrant la chaîne de transmission d'une vidéo à la demande #gls("vod", "VOD"), @coffie2025streaming],
  ) <vod_transmission>
]

Ces processus concernent les données vidéos mais aussi audio, dans notre cas uniquement les données vidéos nous intéressent pour ce projet.

Il est important de mettre en avant la différence et le déséquilibre aux moments clés de l’encodage et du décodage.

Côté Fournisseur : L'encodage est une opération réalisée sur les serveurs du diffuseur, ce qui techniquement, est alors plus simple pour implémenter de nouvelles méthodes, car le diffuseur possède le contrôle total de son infrastructure. Bien qu' évolutive, cette infrastructure répond tout de même à une logique d’optimisation des coûts, une solution trop gourmande en calculs pourrait faire exploser les coûts pour les fournisseurs, ou encore une solution n’apportant pas une grande optimisation mais demandant de modifier toute l’architecture sera aussi difficilement acceptable de ce point de vue.
Côté utilisateur : Le décodage est effectué directement par l'appareil de l'utilisateur (TV, smartphone). Ces appareils utilisent des puces de décodage matériel conçues pour être économes en énergie et rapides. Ces puces sont figées lors de la fabrication. La seule alternative, pour un appareil dépourvu du circuit adéquat, est le décodage logiciel, ce qui signifie faire exécuter le calcul de décodage par le processeur général. Cette voie est universelle mais bien moins efficace. Il est donc extrêmement complexe de modifier le comportement de ce décodage ou d'y introduire de nouvelles méthodes, car cela nécessiterait de mettre à jour le matériel ou d'imposer des contraintes incompatibles avec les appareils existants. Cette limite s’explique notamment car les nouvelles solutions, apportant une optimisation sont accompagnées d’un nombre plus important de calculs, ce qui n’est pas toujours supporté par l’ensemble des appareils.

On comprend alors que la balance se trouve, à court terme, dans des solutions d’optimisations peu gourmandes en ressources. Cela permet alors de combler l’optimisation des coûts de l'entreprise, mais aussi répondre aux limites matérielles côté utilisateurs. On peut aussi prédire des modifications futures plus importantes advenant à la suite d’une maturité suffisante des outils nécessitant cette évolution.

De par ce constat, on peut estimer qu'une optimisation réaliste se trouverait alors en amont du transfert de la vidéo. En particulier car une vidéo encodée sera transmise à un grand nombre d'utilisateurs, optimiser une vidéo pourrait alors devenir intérressant plus rapidement.

=== Les enjeux économiques de la #gls("vod", "VOD") et liens avec la recherche

Une question guide cette mise en contexte : quels sont les enjeux économiques de la #gls("vod", "VOD"), et en quoi une optimisation en amont de la compression répond-elle aux besoins des acteurs du secteur, et donc à ceux de notre cellule ?

La #gls("vod", "VOD") représente aujourd'hui une part majeure du trafic internet mondial, et chaque flux transmis a un coût, en bande passante, en stockage et en énergie. Pour des plateformes comptant des millions d'abonnés, la moindre réduction du débit moyen se traduit par des économies considérables, répétées à chaque diffusion. C'est ce qui explique l'attention portée à la compression : optimiser une vidéo une seule fois, en amont, profite ensuite à l'ensemble des utilisateurs qui la regarderont.

// TODO : si tu trouves des chiffres sourçables (part du trafic vidéo, coût relatif de chaque composant de la boucle VOD), c'est ici qu'il faut les insérer pour donner les ordres de grandeur demandés.

Les acteurs concernés sont parmi les plus gros du numérique, Netflix, Amazon ou Meta, et ce sont précisément les clients de notre cellule. Leurs besoins orientent donc directement nos sujets de recherche : la majorité de nos projets portent sur l'évaluation de nouvelles solutions, souvent confrontées à un panel d'utilisateurs. Une étude récente du secteur place d'ailleurs le stockage comme premier défi des entreprises de streaming @challengesVOD, ce qui confirme tout l'intérêt d'une optimisation agissant directement sur le poids des fichiers.

Enfin, un point mérite d'être souligné : l'écosystème open source et open access joue un rôle clé. Il permet de faire évoluer les outils de compression, mais donne aussi accès à des outils de mesure de qualité vidéo, des outils complexes, parfois développés en interne par ces entreprises, et dont la disponibilité conditionne en grande partie la recherche dans ce domaine.

=== Rapport d'utilisation des outils de compression
Pour mieux comprendre les éléments suivants, voici un bref historique des outils existants.

#align(center)[
  #figure(
    image("images/historique_codec.png", width: 100%, height: 125pt),
    caption: [Historique et évolution des outils de compression vidéo (#gls("codec", "codecs")) entre 1990 et 2017 @moreira2022digitalvideo],
  ) <historiqueCodec>
]

Afin de mettre en avant la difficulté d'évolution des outils de compression par les entreprises concernées, les figures suivantes illustrent la répartition d'utilisation des outils de compression en 2023 et 2024 sur un panel d'entreprises. On peut y voir que les outils les plus récents ne sont pas encore adoptés par la majorité des entreprises, ce qui montre la difficulté d'évolution de ces outils.
#align(center)[
  #figure(
    image("images/Codecs_2023.png", width: 80%, height: 200pt),
    caption: [Illustration de la répartition d'utilisation des outils de compression en 2023-2024 (Streaming & #gls("vod", "VOD")) pour un panel d'entreprises (en rouge : l'outil envisagé pour l'année suivante) @bitmovin2023report],
  ) <utilisationCodec2023>
]

#align(center)[
  #figure(
    image("images/Codecs_2024.png", width: 90%, height: 200pt),
    caption: [Illustration de la répartition d'utilisation des outils de compression en 2024-2025 uniquement pour la #gls("vod", "VOD") pour un panel d'entreprises (en rouge : l'outil envisagé pour l'année suivante) @bitmovin2024report],
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

Au-delà de ce verrou technique, ce rapport examine également le projet sous trois angles complémentaires : économique, organisationnel et humain. Chacun est introduit par une question, posée à l'endroit le plus pertinent du document et reprise en conclusion.

= Présentation de l'environnement de travail

== L'entreprise
Capacités SAS est une filiale privée de valorisation de la recherche de Nantes Université. Créée en 2005, elle emploie aujourd’hui environ une centaine de collaborateurs. L’entreprise est détenue à 93 % par Nantes Université et 7 % par la chambre de Commerce et d’Industrie de Nantes Saint-Nazaire. L’entreprise est présente sur 3 villes du Grand Ouest : La Roche Sur Yon, Saint Nazaire et Nantes. Capacités est divisé en 13 cellules d'expertise. Les cellules portent des projets d’entreprise au sein des laboratoires auxquelles elles sont rattachées pour avoir accès à une expertise et être au plus près de la découverte scientifique. Elles apportent aussi un support à la recherche lors d’un besoin en ingénierie. Les cellules sont composées de chercheurs, ingénieurs et techniciens. Chaque équipe possède ses propres clients et gère une partie de son budget pour l’attribuer selon les ressources nécessaires. Il existe également des projets inter cellules pour regrouper plusieurs domaines d’expertise sur les sujets pluridisciplinaires.

== La cellule IXPEL
Je travaille au sein de la cellule IXPEL, qui est intégrée au sein de l’équipe de recherche IPI (Image Perception Interaction) qui appartient au LS2N (Laboratoire des Sciences du Numérique de Nantes). L’équipe est spécialisée dans l’intelligence artificielle appliquée à l’image et la qualité d’expérience. On y retrouve par exemple des sujets liés à l'imagerie médicale, au traitement de documents manuscrits et l’expérience/qualité utilisateur face à du contenu vidéo, l’équipe est reconnue mondialement sur ce dernier sujet ce qui lui permet de travailler en collaboration avec les plus grandes entreprises du secteur et en particulier avec leurs équipes de recherche.

Les clients de notre cellule sont des grandes entreprises du numérique comme Meta, Netflix ou Amazon. L’équipe IPI et la cellule IXPEL sont reconnues pour les tests subjectifs et la qualité expérience c’est notamment pour ce genre de sujets que les projets avec ces entreprises portent. Les tests permettent par exemple de recueillir des données sur la satisfaction d’utilisateurs face à des contenus vidéo, ce qui permet par la suite d’évaluer des méthodes et solutions mises en place. Nous avons également comme client le laboratoire lui-même. Quand le laboratoire montre un besoin de programmation ou autres tâches d'ingénierie pour un des projets en cours, ils vont alors faire appel à notre cellule si cela reste dans nos domaines de compétences. D’autres clients plus ponctuels peuvent aussi faire appel à notre cellule pour une mise en place d'outils liés à la vision par ordinateur et à l’image plus généralement.

Cet environnement facilite donc les échanges avec le laboratoire, ce qui fluidifie l'avancement des projets de recherche mais apporte aussi à notre cellule un lien fort avec les thématiques de recherche actuelles ce qui pour nous est un argument très important car cela montre la possibilité de travailler sur des solutions innovantes. Ce lien est donc bénéfique pour les deux parties.

La cellule est actuellement composée de 8 membres, ce chiffre évolue fréquemment, notamment de par l'arrivée de stagiaires ou encore selon la durée des contrats en cours.

= Organisation du projet

Ce chapitre cherche à répondre à une question : comment une petite cellule, à l'interface entre un laboratoire de recherche et une entreprise, s'organise-t-elle pour mener un projet d'apprentissage automatique, avec les contraintes de ressources et de coordination que cela implique ? Les sections qui suivent y répondent en présentant le cadre du projet, les rôles de chacun, puis les méthodes et outils de travail au quotidien.

== Contexte du projet
Ce projet est en lien avec Amazon Elemental, filiale d’Amazon. Ce groupe s'intéresse aux problématiques liées à la vidéo notamment dû aux différents services qu’ils proposent tel que prime vidéo. Ce projet prend part dans une collaboration à plus long terme et fait suite à d’autres projets en lien avec cet organisme.

Ce projet s'inscrit aussi dans la dynamique de la cellule. Sa montée en charge s'est accompagnée de recrutements, et le sujet, à la croisée de la compression vidéo et de l'apprentissage automatique, a contribué à orienter certains des profils recherchés. // TODO : préciser le volume de recrutements ou les profils concernés si tu as les éléments. Pendant son déroulement, il occupe une place importante au sein de l'équipe : il mobilise plusieurs membres et s'appuie sur les compétences cœur de la cellule.

Un objectif transversal mérite par ailleurs d'être mentionné dès maintenant : au-delà des résultats, le projet vise à produire des outils réutilisables par l'équipe. La documentation rédigée et le code, versionné sur la plateforme GitLab de l'équipe, doivent permettre de capitaliser sur ce travail pour les contributions futures.

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

=== Méthodes de suivi et de travail

Au sein de la cellule, les projets ne regroupent que peu de personnes à chauqe fois et les missions peuvent parfois ne pas nécessiter une communication quotidienne poussée, cependant il reste important de garder en tête les avancés de chacuns, c'est pourquoi nous faisons des réunions hebdomadaires. Nous suivons la méthode POP, une méthode qui simplifie la gestion de ses réunions en les rendant plus dynamique. Tous les lundi, face à un tableau prévu à cet effet, représentant la semaine actuelle et la semaine passée, nous précisons alors ce que nous avons réalisé la semaine précedante et ce que nous envisageons de faire pour la semaine en cours. On utilise aussi des post-it qui permettent de garder un trace des points clés évoqués et de pouvoir suivre ce qui était prévu et ce qui a été fait d'une semaine à l'autre.
C'est un moement où l'on peut plus facilement débloquer de situations, se donner des conseils et établir une oragnisation des tâches plus cohérente car tous les membres sont bien disponibles.

Le reste du temps les échanges concernant les différents projets sont plus informels, facilité par notre proximité dans les locaux. Il est aussi fréquent de faire des points ou présentation pour mettre au clair un avancement, des idées, ou des besoins spécifiques pour un projet. des moments qui sont alors essentiels quand le proejt regroupe plusieurs personnes.

Les échanges sont majoritairement en français mais ponctuellement en anglais en raison de l'aisance de chacun avec le français.

=== Outils de communication et de suivi
Notre cellule étant de petite taille, la communication y est facilité nous travaillons tous dans le même bureau, cependant nous faisons parti de deux autres organismes, le laboratoire de recherche, pour lequel nous partageons les mêmes locaux et l'entreprise. Cela entraine donc des besoins de communication et gestion par de canaux différents, concernant le labo nous avons des canaux liés à l'université, notamment l'outil mattermost permettant de réaliser des échanges en lignes sous forme de chat, en groupe notamment pour les différents projets ou seul. D'autres outils liés à l'université nous sont mis à disposition : UnCloud, qui permet d'avoir un stockage cloud et de partager facilement des documents volumineux. Webmail, un service de mail en ligne en lien avec l'université. Glicid, un cluster de calcul partagé disponible pour la recherche dans la région Nantaise en particulier.
Concernant le lien entreprise est lui plus distant, et des outils et protocoles sont mis en place pour suivre l'évolution des projets par les responsables et services de gestion de l'entreprise. Lucca qui permet la gestion des congés et autres absences, de partager des documents RH aux employés, Laboxy qui permet d'attribuer les heures effectuées aux projets concernés.

=== Outil internes

AU sien du laboratoire et en particulier de la cellule nous possedons aussi des serveurs de calcul qui permettent alors de repartir les membres de l'équipe et en particulier de stocker des dossiers volumineux notamment des vidéos sources qui peuvent parfois devenir très encombrantes.
Ces outils sont alors important mais demande une organisation particulière pour une utilisation par plusieurs personnes, création de session différentes limite d'utilisation des ressource processeurs ou graphique par chacun. Le nombre de membres au sein de l'équipe ayant augmenté, ces outils internes ne suffisent pas pour que chacun puisse les utilsier quotidiennement mais ce sont pas les seuls outils à disposition.

=== Adaptation Impact des outils utilisés
Parmis les outils utilisés durant ce projet, un outil en particulier permet de nous affranchir d'un besoin matériel important : Glicid.
C'est un cluster de calcul partagé, accessible à un ensemble de projets de recherche et aux entreprises qui en paie l'accès. Glicid fourni alors différentes environnments permettant d'accéder à des processeurs puissants ou carte graphique, deux moyens d'effectuer un grand nombre de calculs et faire executer différents algorithmes. Ce qui est essentiel pour travailler avec des outils d'intelligence artificielle comme nous le faisons. Cette plateforme permet donc de centraliser les ressources matéreilles nécessaires à de nombreux projets. cela rend alors ces ressources plus accessible financièrement mais aussi limite l'impact écologique de chaque projet, chaque envirronement est utilisé pleinement, ce qui permet d'en optimiser l'utilisation, quand un test est terminé un nouveau peut-être lancé. De plus les outils proposés évoluent, ce qui mutualise les besoins et facilitent l'accès à des nouvelles technologies couteuses.

Cet outil necessite cependant une adaptation pour une utilisation optimale, différents envrionnements, comprendre les différents éléments, comment bien réaliser la demande pour un envirronmeent qui répond aux besoins du test en cours.
Cela fait donc partie de nos missions, s'adapter aux outils utilisés et à leur évolutions au fil du temps.

Pour notre cellule on peut facilement se partager des astuces ou bonnes pratiques pour parvenir à mieux appréhender ce genre d'outil. C'est devenu un indispensable pour certains membres de l'équipe et permet de mieux gérer nos ressources internes. Glicid est aussi maintenu ce qui facilite la tâche car pour des ressources internes, cela demanderait plus de travail.

Cependant ces maintenances imposent aussi des moments d'arrets de l'outil, un grand nombre de jours durant ce projet ont été privés de cette resssource pour maintenance ou innaccessibilité de la plateforme. Cela limite alors l'organisation des tâches et peut parfois ralentir l'avancé de certains projets.

De manière général c'est un outil atypique qui modifie la manière de travailler, entre adaptation aux mécanismes spécifiques et contrainte liés à l'accès à la plateforme, l'organisation au quotidien en est alors dépendante.

=== La vie du laboratoire
Partagant les memes locaux et faisant partie de l'équipe IPI nous participons aussi aux différents moments conviviaux de l'équipe, pour les repas ou séminaires notamment. Il est assez fréquent que des seminaires d'équipes soient oragnisés où des doctorants, chercheurs ou invités présentent leurs travaux. Ces présentations se déroulent en anglais pour que tout le monde puisse suivre car il est fréquent d'avoir des stagiaires étrangers au sein du laboratoire.
Au regard des compétences de l'équipe cela apporte pour tous, pour ceux qui présentent, cela leur permet de valider leurs propos et obtenir des idées d'autres chercheurs mais aussi de prendre de l'assurance dans leur présentation. Pour ceux qui écoutent d'apprendre des concepts complexes et de pratiquer l'anglais dans des domaines précis et techniques. C'est un moment d'équipe, humain qui semble annodin mais qui a un intérêt important pour le développement de chacun et indispensable pour les relations dans l'équipe.

= Compression et qualité vidéo : défis et solutions

== Contexte et formation pour l'équipe

On peut ici se poser une question : comment une équipe jeune vit-elle et monte-t-elle en compétence sur des thématiques de pointe comme le deep learning et la qualité vidéo, entre veille permanente, partage de connaissances et accompagnement ?

Au sein de la cellule et en particulier les membres concernés par le projet, la jeunesse de l'équipe est à prendre en compte, c'est un très bon point pour se tourner vers l'innovation et facilite le changement, qui sont mieux acceptés par ce publique. Cependant cela demande aussi un montée en compétence rapide pour assimiler des sujets d'expertises poussés. La compression vidéo est un domaine remplie de théorie et de concepts complexes, faire partie d'une équipe experte de ces sujets facilite cette montée en compétence mais une part de se travail doit être fait par des recherches personnelles. Le deep learning en lien avec ce sujet est aussi un domaine complexe qui est aussi un domaine en lien avec l'équipe mais le sujet demande des compétences importantes qui s'acquiert aussi au fil du projet. Il est donc assez évident que cette montée en compétences demande du temps et les évolutions rapides de ces sujets impliquent une veille au quotidien. Ces limites sont, en partie, dûes à la compléxité du projet qui implique des compétences transverses et demande donc un investissement personnel pour combler le manque d'experience dnas ce domaine.



== Encodage : la réduction d'informations transmises

Le codage vidéo repose sur un grand nombre de principes parfois complexes, le but ici va seulement être de donnée les logiques de bases et certaines éléments importants qui vont permettre une meilleure compréhenssion du sujet et facilité les éléments d'une possible amélioration.
Une vidéo est une suite d'images qui se suivent, souvent très rapidement (plusieurs par seconde). On peut parfois avoir des vidéos qui contienent 30, 60 voir 120 images par secondes et plus dans certains cas pour certians types de contenus qui demande une grande fluidité. Durant un court laps de temps la scène ne change que très peu. C'est le point principale utilisé pour la compressein vidéo, utiliser cette redondance d'informations de manière efficace.
Pour bien comprendre les différents concepts il faut aussi avoir en tête que les iamges sont décomposées en blocs, qui peuvent être de taille variable pour une même iamge, dans les exemples, nous garderons une taille fixe pour faciliter la compréhension.
Pour illuster ce mécanisme voici un exemple simple qui permet de comprendre la logique utilisée.

#align(center)[
  #figure(
    image("images/interMotion.png", width: 90%, height: 190pt),
    caption: [Exemple de mouvement prédit @moreira2022digitalvideo],
  ) <intermotion>
]

Le premier point étantt la principale optimisation qui utilise une répétition d'informations mais il faut tout d'abord transmettre un image clée, qui servira de point d'anchrage pour la suite de cette prédiction de mouvement. Une image clée est transmise pour chaque groupe d'image (GOP).
Ces images clés doivent être transmise entièrement ce uqi peut parfois avoir un coût important. On utilise alors une autre forme de redondance au sein de cette image uniquement, des zones de ciel bleue pourront alors etre transmises simplement car les blocs voisins se ressemblent.
Pour ce faire il faut dérouler à partir des informations connues de l'iamges, le bloc en haut à gauche est transmis en premier il servira alors de base pour la suite.
Voici un exemple qui montre la manière dont cela est utilisé.

#align(center)[
  #figure(
    image("images/intraExemple.png", width: 80%, height: 220pt),
    caption: [Exemple de la réutilisation de la partie de l'image connue @moreira2022digitalvideo],
  ) <intraexemple>
]


Une fois que ces prédictions sont réalisées, l'image prédite n'étant pas parfaite il manque des informations importantes à transmettre pour corriger au mieux cette prédiction. Cette correction est appelée résidu, elle est la différence entre l'image prédite etl'image d'origine : c'est le reste des informations à transmettre pour arriver à l'image d'origine.


#align(center)[
  #figure(
    image("images/rescalcul.png", width: 110%, height: 140pt),
    caption: [Exemple de calcul du résidu pour le ciel bleu @moreira2022digitalvideo],
  ) <intraexemple>
]

#align(center)[
  #figure(
    image("images/resExemple.png", width: 50%, height: 220pt),
    caption: [Exemple visuel de résidu pour l'exemple du mouvement de la balle @moreira2022digitalvideo],
  ) <resexemple>
]


== Utilisateur et compression ciblé

Au-delà de la redondance entre images et au sein d'une image, la compression exploite une autre source d'économie : les limites de la perception humaine. L'idée est simple, si l'œil ne perçoit pas une information, il est inutile de la transmettre fidèlement.

Deux mécanismes illustrent bien cette logique. Le premier repose sur la #gls("dct", "DCT") (transformée en cosinus discrète), qui réorganise l'information d'un bloc par fréquences. Les zones lisses se concentrent dans les basses fréquences, les détails fins dans les hautes fréquences. Or l'œil est bien moins sensible à ces hautes fréquences : on peut donc les représenter plus grossièrement lors de la #gls("quantification", "quantification"), sans dégradation visible, ce qui allège fortement le poids du fichier.

Le second mécanisme concerne la couleur. Une image peut être décrite en #gls("rgb", "RGB"), mais on lui préfère l'espace #gls("yuv", "YUV"), qui sépare la #gls("luminance", "luminance") (l'intensité lumineuse) des #gls("chrominance", "chrominances") (la couleur). L'œil étant beaucoup plus sensible à la luminance qu'à la couleur, on peut sous-échantillonner cette dernière : c'est le format 4:2:0, où la couleur est transmise à une résolution réduite par rapport à la luminance. La perte est réelle, mais quasiment imperceptible.

Ces deux exemples montrent une chose importante pour la suite : la compression ne cherche pas la fidélité parfaite, mais la fidélité _perçue_. C'est exactement le terrain sur lequel se place ce projet, modifier l'image pour qu'elle coûte moins cher à coder, sans que l'utilisateur final ne le remarque.

== Coûts des vidéos : logique et théorie

La théorie derrière le codage arithmétique est complexe, l'objectif de cette section est uniquement de mettre en avant la logique suivie afin de comprendre comment une optimisation semble possible pour contrer les effets d'une compression parfois agressive.

Nous venons de voir brièvement comment les informations étaient transmises, cependant ces informations peuvent grandement faire varier le poids des fichiers vidéo. Une logique simple repose sur la théorie de l'information : plus une information est prédictible, moins elle coûte cher à transmettre. On comprend alors l'intérêt de la #gls("quantification", "quantification"), qui simplifie les valeurs : on retrouve par exemple un grand nombre de 0, quasiment gratuits à transmettre.

C'est là qu'intervient le codage entropique, l'outil qui transforme réellement ces valeurs en bits. En #gls("hevc", "H.265"), ce rôle est tenu par le #gls("cabac", "CABAC"). Sans entrer dans le détail, il faut surtout retenir deux idées. D'abord, il est contextuel : pour coder une valeur, il regarde ses voisines déjà codées et s'en sert pour estimer ce qui va probablement suivre. Ensuite, il est adaptatif : au fil du codage, il met à jour ses probabilités en fonction de ce qu'il a réellement rencontré. Autrement dit, plus le contenu est régulier et conforme à ses attentes, plus il devient efficace.

On voit alors pourquoi avoir des valeurs simples est si important. Une suite de valeurs proches, répétées ou nulles est très prédictible : le #gls("cabac", "CABAC") lui attribue une forte probabilité et la code sur très peu de bits. À l'inverse, des valeurs dispersées et imprévisibles coûtent cher. C'est précisément ce levier que l'on cherche à exploiter : si l'on parvient, en amont, à rendre l'image plus simple à représenter une fois transformée et quantifiée (davantage de zéros, des coefficients plus réguliers), alors le codage final devient moins coûteux, à qualité visuelle comparable. C'est tout l'enjeu de l'optimisation visée dans ce projet.


== Évaluer le contenu vidéo

Si l'on veut optimiser une vidéo, encore faut-il pouvoir mesurer sa qualité. C'est un point central du projet : la mesure choisie servira de guide à l'apprentissage du filtre, et conditionnera donc directement la pertinence des résultats.

La référence reste le jugement humain. En réunissant un panel d'utilisateurs et en moyennant leurs notes, on obtient un #gls("mos", "MOS") (Mean Opinion Score), considéré comme la « vérité terrain » de la qualité perçue. C'est d'ailleurs l'une des expertises reconnues de notre équipe, sollicitée pour ce type de tests par de grands acteurs du secteur. Mais ces tests sont coûteux et lents : impossible de les utiliser pour guider, image par image, l'entraînement d'un réseau de neurones.

On s'appuie donc sur des #gls("metrique", "métriques") objectives, c'est-à-dire calculées automatiquement. La plus ancienne, le PSNR, mesure simplement l'écart pixel à pixel avec la source : elle est facile à calculer mais corrèle mal avec la perception humaine. D'autres, comme le SSIM ou surtout le #gls("vmaf", "VMAF"), cherchent à se rapprocher du jugement humain en combinant plusieurs indicateurs. Ces métriques sont au cœur du projet, mais elles ont aussi leurs défauts, un point sur lequel nous reviendrons, car une métrique mal choisie peut conduire à optimiser dans une mauvaise direction.

Enfin, il faut garder en tête que ces métriques restent des approximations. La validation finale d'une optimisation, une fois les outils suffisamment matures, passera par de vrais utilisateurs : c'est ce qui garantit la validité du projet, et c'est précisément le type de tests que notre environnement permet de mener.

== Les limitations pour l'apprentissage

Nous l'avons mentionné, les codecs classiques s'intègrent mal dans un apprentissage. Avant de voir comment contourner ce problème, il faut comprendre d'où viennent réellement ces limites.

=== Limites mathématique des outils pour l'apprentissage

Ces limites sont avant tout mathématiques. Pour qu'un réseau apprenne, chaque opération de la boucle doit indiquer dans quelle direction ajuster les paramètres : c'est le rôle du gradient, qui donne en quelque sorte le « sens de la pente ». Une opération est utilisable pour l'apprentissage si elle est _différentiable_, c'est-à-dire si l'on peut calculer cette pente.

Le problème, c'est que beaucoup de fonctions n'ont pas cette propriété. Certaines présentent des zones plates, où une petite variation de l'entrée ne change rien à la sortie : la pente y est nulle et n'indique aucune direction. D'autres présentent des cassures franches, où la pente n'est tout simplement pas définie.

Les #gls("codec", "codecs") vidéo regorgent de ce type d'opérations. La #gls("quantification", "quantification"), par exemple, repose sur un arrondi : sa courbe est un escalier, plat entre deux marches, donc de gradient nul presque partout. La sélection du meilleur bloc lors de la prédiction repose elle sur un argmin, un choix discret qui ne fournit aucune pente exploitable.

// TODO : ajouter une figure illustrant ces fonctions (escalier de l'arrondi, et/ou comportement de l'argmin).

C'est pour cette raison qu'un codec ne peut pas être utilisé tel quel au cœur d'un apprentissage : il contient trop d'opérations « bloquantes », qui interrompent la circulation du gradient. Il faut donc trouver un moyen de les contourner.

== Solutions existantes

=== Deep learning et méthodes de remplacement

Lors de l'apprentissage d'un réseau de neurones, dans notre cas le filtre, le code qui réalise cet apprentissage est rempli d'opérations mathématiques qui sont les piliers de l'optimisation des paramètres du réseau. Pour permettre à chaque opération d'avoir sa place dans cette optimisation, un graphe de calcul est créé : il regroupe les différents calculs exécutés durant la boucle.

Ce graphe se parcourt dans les deux sens. À l'aller (le _forward_), on calcule normalement le résultat à partir des entrées. Au retour (le _backward_), on remonte le graphe en sens inverse pour calculer, pour chaque opération, le gradient, c'est-à-dire la contribution de chacun à l'erreur finale. C'est cette seconde étape qui permet d'ajuster le réseau.

Séparer ces deux passes ouvre une possibilité intéressante : on peut intervenir sur le backward indépendamment du forward. Deux outils en découlent. Le premier consiste à « détacher » une partie du graphe, de sorte que le gradient ne la traverse pas : la valeur est bien calculée à l'aller, mais aucun gradient ne remonte par ce chemin. La @forward_backward illustre ce principe sur un calcul simple.

Le second, plus puissant, consiste à remplacer le comportement d'une fonction au backward. On exécute l'opération réelle à l'aller, mais on lui substitue une approximation dérivable au retour. C'est le principe du #gls("ste", "STE") (Straight Through Estimator) : pour un arrondi, par exemple, on applique le vrai arrondi au forward, mais on fait « comme si » la fonction était l'identité au backward, ce qui laisse passer un gradient exploitable.

C'est exactement ce mécanisme qui rend possible l'usage d'opérations bloquantes, voire d'un codec entier, au cœur de l'apprentissage : on garde le comportement réel là où il compte, tout en fournissant au réseau une pente artificielle mais utile pour apprendre.

#figure(
  canvas(length: 1cm, {
    import draw: *

    // petite fonction pour les flèches
    let arrow = (start, end) => line(start, end, mark: (end: ">", fill: black, scale: 0.6))

    // hauteurs des 3 entrées (a en haut, y au milieu, b en bas)
    let ya = 1.6
    let yy = 0.8
    let yb = 0

    // ---------- FORWARD ----------
    let off = 0
    content((-0.6, yy + off), text(weight: "bold")[Forward], anchor: "east")
    content((0, ya + off), [a])
    content((0, yy + off), [y])
    content((0, yb + off), [b])

    let mulx = (2.6, 0.95 + off)
    let addx = (4.3, 0.6 + off)
    let rx = (5.8, 0.6 + off)
    content(mulx, text(size: 13pt, weight: "bold")[$times$])
    content(addx, text(size: 15pt, weight: "bold")[$+$])
    content(rx, text(weight: "bold")[r])

    arrow((0.25, ya + off), (mulx.at(0) - 0.3, mulx.at(1) + 0.15)) // a -> x
    arrow((0.25, yy + off), (mulx.at(0) - 0.3, mulx.at(1) - 0.05)) // y -> x
    arrow((mulx.at(0) + 0.3, mulx.at(1)), (addx.at(0) - 0.3, addx.at(1) + 0.1)) // x -> +
    arrow((0.25, yb + off), (addx.at(0) - 0.3, addx.at(1) - 0.15)) // b -> +
    arrow((addx.at(0) + 0.3, addx.at(1)), (rx.at(0) - 0.3, rx.at(1))) // + -> r

    // ---------- BACKWARD ----------
    let off = -2.6
    content((-0.6, yy + off), text(weight: "bold")[Backward], anchor: "east")
    content((0, ya + off), [a])
    content((0, yy + off), [y])
    content((0, yb + off), [b])

    let mulx = (2.6, 0.95 + off)
    let addx = (4.3, 0.6 + off)
    let rx = (5.8, 0.6 + off)
    content(mulx, text(size: 13pt, weight: "bold")[$times$])
    content(addx, text(size: 15pt, weight: "bold")[$+$])
    content(rx, text(weight: "bold")[r])

    arrow((rx.at(0) - 0.3, rx.at(1)), (addx.at(0) + 0.3, addx.at(1))) // r -> +
    arrow((addx.at(0) - 0.3, addx.at(1) + 0.1), (mulx.at(0) + 0.3, mulx.at(1))) // + -> x
    arrow((addx.at(0) - 0.3, addx.at(1) - 0.15), (0.25, yb + off)) // + -> b
    arrow((mulx.at(0) - 0.3, mulx.at(1) - 0.05), (0.25, yy + off)) // x -> y
    line((mulx.at(0) - 0.3, mulx.at(1) + 0.15), (0.25, ya + off)) // x -> a (coupé)

    // grosse croix rouge : gradient bloqué vers a
    let cx = 1.2
    let cy = (ya + off + mulx.at(1) + 0.15) / 2 + 0.06
    let s = 0.30
    line((cx - s, cy - s), (cx + s, cy + s), stroke: (paint: red, thickness: 4pt))
    line((cx - s, cy + s), (cx + s, cy - s), stroke: (paint: red, thickness: 4pt))
  }),
  caption: [Graphe de calcul : $r = a y + b$ ($a$ est détaché, son gradient est bloqué au _backward_)],
) <forward_backward>


=== Les méthodes d'optimisation existantes

Le filtrage de prétraitement par IA est aujourd'hui une thématique bien présente dans la littérature. Pour autant, il reste difficile d'établir quelle méthode est la plus performante pour remplacer les outils de codage classiques durant l'apprentissage, et comment guider au mieux ce dernier. On peut regrouper les travaux existants autour de deux grandes familles de #gls("proxy", "proxy") : ceux qui reconstruisent une version simplifiée et différentiable d'un codec classique, et ceux qui entraînent un codec neuronal à imiter le comportement d'un codec cible. Nous présentons ici trois travaux représentatifs de ces deux approches.

*Neural Wrapping (CVPR 2025) — un codec neuronal comme #gls("proxy", "proxy")* @khan2025neural

Ce travail, mené par Sony, s'intéresse à du contenu de type jeu vidéo et à du streaming à des débits représentatifs de la diffusion 1080p. L'architecture combine un filtre de prétraitement et un filtre de post-traitement (un « neural wrapper ») encadrant le #gls("codec", "codec"). Ils utilisent des filtres légers, l'encodage lui-même utilisant au contraire des presets lents et de haute qualité, ce qui se rapproche des conditions que l'on souhaite tester pour ce projet.

Pour contourner la non-différentiabilité des codecs classiques, les auteurs n'essaient pas de reproduire les étapes du codec : ils entraînent un codec neuronal à l'imiter. Cet alignement se fait en deux phases. On aligne d'abord les images reconstruites par le proxy sur celles produites par le vrai codec, puis on apprend la distribution du débit avant de la recaler sur le débit réel mesuré. Pendant l'apprentissage de bout en bout, le proxy est réajusté à chaque itération, et une astuce de _stop-gradient_ — proche dans l'esprit du #gls("ste", "STE"), permet de transmettre au post-traitement les vraies images du codec tout en faisant circuler le gradient à travers le proxy neuronal.

L'intérêt principal est de repartir d'outils de codage neuronaux existants, réentraînables sur ses propres données, et d'obtenir une architecture relativement simple à appréhender. Malgré une différence de fonctionnement marquée avec un codec classique, les résultats montrent que l'approche reste cohérente une fois le filtre appliqué sur le vrai codec : les auteurs rapportent un gain moyen de l'ordre de #sym.minus 18,5 % de BD-rate (le BD-rate mesure l'économie moyenne de débit à qualité égale, plus il est négatif, mieux c'est), et vérifient surtout que débit et distorsion du proxy et du codec cible se corrèlent fortement après l'alignement condition nécessaire à un apprentissage par gradient.

*Limites.* La première limite tient au paradigme lui-même : les fonctions du codec (transformée, #gls("quantification", "quantification"), codage entropique) sont ici entièrement remplacées par des réseaux de neurones, qui réagissent différemment d'un vrai codec. On peut donc penser qu'un proxy plus proche du fonctionnement réel constituerait un meilleur simulateur pour l'apprentissage c'est précisément l'une des pistes explorées dans ce projet. Ensuite, réutiliser un codec neuronal existant contraint aux points de fonctionnement pour lesquels il a été conçu, des variantes à débit variable apparaissent (par modulation des caractéristiques, par exemple), mais l'alignement sur un nouveau codec cible reste coûteux les auteurs notent eux-mêmes un surcoût de calcul important pour l'alignement sur #gls("hevc", "VVC"). Enfin, et c'est central pour notre projet, une grande partie des gains repose sur le post-traitement : leur étude d'ablation montre que le prétraitement seul dégrade même certaines #gls("metrique", "métriques") de fidélité (SSIM, MS-SSIM), et que seul l'entraînement conjoint du pré- et du post-traitement donne des gains cohérents sur l'ensemble des #gls("metrique", "métriques"). Or un post-traitement côté client est difficile à déployer dans notre contexte (cf. les contraintes matérielles évoquées plus haut).
Un dernier point essentiel est leur choix de métriques durant l'apprentissage, ils utilisent une des composante de VMAF, ce qui facilite probablement les gains face à cette mesure.

*DPP (CVPR 2021) — un codec simplifié et différentiable* @chadha2021dpp

On retrouve ici du filtrage neuronal, mais uniquement en prétraitement : aucune composante n'est ajoutée côté décodeur, ce qui rend la méthode directement déployable. Pour remplacer le codec cible, les auteurs « virtualisent » les briques essentielles d'un codec hybride en versions différentiables : prédiction inter/intra, sélection du meilleur bloc, transformée fréquentielle (la #gls("dct", "DCT")) et #gls("quantification", "quantification"). Les opérations bloquantes pour l'apprentissage sont contournées par des approximations un #gls("ste", "STE") pour l'argmin de la recherche de bloc, et un bruit uniforme additif pour remplacer l'arrondi de la quantification. Le gain moyen rapporté est d'environ 11 % sur plusieurs codecs (AVC, AV1, VVC).

*Limites.* L'implémentation paraît simple, mais cette simplicité vient surtout de la difficulté à reproduire fidèlement un codec complexe tout en gardant des fonctions dérivables et compatibles avec la mémoire des cartes graphiques (la recherche de blocs vectorisée est notamment coûteuse en mémoire). Par ailleurs, l'estimation du débit ne repose pas sur un calcul figé : elle s'appuie sur un modèle d'entropie *appris* (un prior factorisé sur des coefficients #gls("dct", "DCT") normalisés), ce qui réintroduit une composante apprise là où l'on cherchait justement à s'affranchir du « tout neuronal » et reproduire la logique du codage théorique classique.

*Sandwiched Video Compression (Google, ICIP 2023) — codec simplifié avec encadrement pré/post* @isik2023sandwiched

Cette approche reprend l'idée du « sandwich » : un filtre de prétraitement et un filtre de post-traitement, très légers (de l'ordre de 100 000 paramètres, voire 57 000 pour la version allégée), encadrent un #gls("codec", "codec") standard, ici #gls("hevc", "H.265"). Le proxy de codec est, comme pour DPP, une version différentiable simplifiée : codage intra de type image (#gls("dct", "DCT") et quantification avec un estimateur de type _straight-through_, #gls("ste", "STE")), compensation de mouvement, sélection de mode inter/intra, codage du résidu, filtre de boucle, et une estimation de débit différentiable et simple. Cette approche obtient dans certians cas des gains aux alentours de 30 % de débit économisé sous la métrique perceptuelle LPIPS.

*Limites.* L'évaluation porte sur #gls("hevc", "H.265") et sur des scénarios assez spécifiques, principalement avec le PSNR et LPIPS, ce qui rend la transposition directe à notre cas moins évidente. Et là encore, le post-traitement côté client pose les mêmes difficultés de déploiement. On peut d'ailleurs imaginer que les résultats sont en bonne aprtie dûes à ce filtre en post traitement comme pour le premier papier présenté.

*Limites communes*

Au-delà des spécificités de chaque méthode, une limite transversale concerne les outils d'évaluation. Plusieurs de ces travaux s'appuient sur le #gls("vmaf", "VMAF"), métrique reconnue mais qui existe en plusieurs versions et dont la version standard est connue pour être « piégeable », avec notamment une sensibilité au contraste et à l'accentuation. Les auteurs en sont conscients : DPP rapporte aussi le VMAF NEG (variante durcie qui pénalise les rehaussements linéaires), et le travail de 2025 croise quatre métriques objectives avec des tests subjectifs (#gls("mos", "MOS")). C'est précisément cette précaution qui semble la plus saine : croiser plusieurs #gls("metrique", "métriques") corrélées à la vision humaine plutôt que d'optimiser une seule mesure, sous peine de gains en partie illusoires.


= Implémentation

== Objectif et difficultés

La mise en place d'un #gls("proxy", "proxy") fiable est la clé du projet, c'est lui qui permettra d'entraîner correctement le filtre, et plus tard, possiblement d'autres outils destinés à assister la compression. Tester différentes méthodologies de proxy était donc l'un des piliers du projet, et cela s'intègre naturellement dans le cadre d'un projet de fin d'études.

Comme évoqué dans la partie précédente, de nombreux travaux sont parvenus à dépasser les limites des codecs classiques pour entraîner un filtre. Mais la diversité des implémentations, des méthodes d'entraînement et d'évaluation rend difficile de savoir laquelle est la plus efficace dans notre cas précis : le filtre de prétraitement. À cela s'ajoute un obstacle pratique, ces travaux sont rarement accompagnés de leur code source, ce qui complique fortement leur ré-implémentation et, bien souvent, empêche d'en reproduire les résultats.

Il était donc indispensable de reprendre ces idées, de les adapter et d'en évaluer la pertinence, afin d'identifier les outils les plus adaptés à notre projet. Une contrainte nous était par ailleurs propre : notre cible était #gls("hevc", "H.265"), ce qui n'était pas forcément le cas des travaux cités.

Concrètement, notre implémentation poursuivait deux objectifs : reproduire un proxy par codage neuronal adapté à #gls("hevc", "H.265"), et réaliser une version simplifiée d'un #gls("codec", "codec") cherchant à se rapprocher de certains de ses choix.

== Architecture globale

Afin de comprendre les différents éléments nécessaire à  l'apprentissage du filtre voici un schéma qui explique la logique gloable de l'apprentissage pour notre cas d'utilisation, une logique qui s'appliquera pour les deux implémentations testées.

Dans ce schéma le terme #gls("proxy", "proxy") est associé à copie du codec pour simplifier la comprehenssion, les scores liés aux #gls("metrique", "métriques") sont aussi remplacé par *résultat du filtre* car dans cette boucle, les métriques nous servent de guide et définissent les résultats du filtre.


#align(center)[
  #figure(
    image("images/filtre_pipeline.png", width: 95%, height: 190pt),
    caption: [Déroulement de la boucle d'apprentissage du filtre],
  ) <filtreGlobale>
]


Pour rentrer plus en détial sur l'architecture du filtre utilisée, nous avons fait le choix de reprendre une architecture simple lié à la partie pre-filtrage du papier CVPR2025 présenté plus tôt. L'objectif ici est d'évaluer les solutions de proxy avec une architecture de filtre fonctionnelle, cette architecture étant validée par les résultats fournis par ces travaux, reprendre cette même architecture simplifie donc l'étude de ce point. Dans une perspective future d'évolution de gains supplémentaire du filtre, cette architecture pourra largement évoluer mais les détails de l'architecture étaient fournis facilitant alors sont implémentation.

// TODO Mettre le filtre en annexe.

== Proxy par codage neuronal
// TODO (dépend de ton implémentation) :
// Expliquer la logique suivie pour utiliser un codec neuronal pour reproduire H.265,
// les choix de conception et les limitations de ce codec neuronal dans ce rôle de proxy.

== Proxy par codec simplifié
// TODO (dépend de ton implémentation) :
// Expliquer les bases utilisées pour reproduire un codec simplifié qui reprend les
// contraintes d'un véritable codec, les choix de conception et les limitations de cette
// version simplifiée. Évoquer la littérature et ce qui n'est pas applicable à notre cas
// d'usage (filtre aussi en post-processing côté utilisateur, etc.).

== Guide d'optimisation
// TODO (dépend de ton implémentation) :
// Expliquer le choix de métriques simples pour le moment, pertinentes, avec l'intention
// de développer cet aspect dans la suite du projet, et la logique suivie pour valider
// plus simplement les résultats.

== Les différentes approches
// TODO (dépend de ton implémentation) : expliquer les choix de tests et leurs raisons.

== Limites et perspectives
// TODO

= Résultats et analyses

== En tant que #gls("proxy", "Proxy")
// TODO (dépend de tes résultats) :
// - Évaluer la fidélité des images face au vrai codec.
// - Évaluer la corrélation face à l'estimation de débit.
// - Expliquer la différence entre les deux versions (apprise vs mimétisme).
// - Voir dans quelle mesure le proxy fonctionne (si on entraîne dessus, les résultats
//   se reportent-ils sur le vrai codec ?).

== Résultats face aux #gls("metrique", "métriques")
// TODO (dépend de tes résultats) :
// Expliquer le choix des métriques utilisées pour l'évaluation et les scores obtenus.

== Test Visuel
// TODO : quelques exemples pour visualiser les effets des optimisations.

== Limites et perspectives
// TODO :
// - Les limites de ces métriques pour ce contenu modifié.
// - Difficulté d'évaluer les résultats car les approches réagissent différemment.

= Conclusion

Ce projet de fin d'études s'attaque à une question concrète : peut-on, à l'aide de l'IA, optimiser la compression vidéo en amont d'un codec existant comme #gls("hevc", "H.265"), sans toucher aux appareils des utilisateurs ? Le cœur du travail a consisté à lever le principal verrou technique, l'impossibilité d'apprendre directement à travers un codec classique, en étudiant, adaptant et évaluant différentes approches de #gls("proxy", "proxy"). Deux voies ont été explorées : un proxy par codage neuronal et un codec simplifié différentiable, chacune avec ses forces et ses limites. // TODO : rappeler les principaux résultats une fois obtenus.

Ce travail s'accompagne d'un constat important : la qualité d'une optimisation dépend autant du proxy que de la #gls("metrique", "métrique") qui guide l'apprentissage. C'est pourquoi le choix et la critique des outils d'évaluation ont occupé une place centrale, et continueront de le faire dans la suite du projet.

Au-delà de l'aspect technique, ce rapport aura cherché à répondre à trois questions transversales. Sur le plan économique, on retiendra que les enjeux de la #gls("vod", "VOD"), bande passante, stockage, énergie, rendent toute optimisation en amont directement profitable aux acteurs du secteur, et donc à notre cellule. Sur le plan organisationnel, le projet illustre comment une petite structure, à l'interface d'un laboratoire et d'une entreprise, s'organise autour de réunions régulières et de ressources mutualisées pour mener un travail d'apprentissage automatique. Sur le plan humain, enfin, il montre qu'une équipe jeune compense un certain manque d'expérience par une réelle capacité d'adaptation, une veille constante et un partage de connaissances au quotidien, autant d'atouts pour aborder des sujets de pointe.

Ce PFE ne constitue qu'une étape : les outils mis en place ont vocation à être réutilisés, et la validation finale, par de vrais utilisateurs, viendra confirmer la pertinence des optimisations une fois celles-ci suffisamment mûres.

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
    image("images/prioriteEtude.png", width: 100%, height: 450pt),
    caption: [Illustration des challenges principaux face à un panel d'entreprise du secteur Streaming/#gls("vod", "VOD") pour l'année 2024-2025) @bitmovin2024report],
  ) <challengesVOD>
]

#page(flipped: true)[
  #set align(center + horizon)

  == Annexe 2 : Planning prévisionnel du projet <planning>

  #v(1cm)

  #figure(
    image("images/planning.png", width: 110%, height: 255pt),
    caption: [Planning global du projet (2026-2027)],
  )
]
= Remerciements

= Résumé
