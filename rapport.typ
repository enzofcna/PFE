#import "@preview/cetz:0.4.2": canvas, draw
#set page(
  paper: "a4",
  margin: (x: 2.5cm, top: 2.5cm, bottom: 2.5cm),
)

#let gls(id, mot) = link(label(id))[#text(weight: "semibold", mot)]

#set text(
  font: "Liberation Serif",
  size: 11.5pt,
  lang: "fr",
)

// ── AÉRATION ────────────────────────────────────────────────────────────────
#set par(
  justify: true,
  leading: 0.9em,
  spacing: 1.5em,
)

#set list(
  spacing: 0.75em,
  indent: 0.4em,
)

#set figure(
  gap: 0.9cm,
)
// ────────────────────────────────────────────────────────────────────────────

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

  #v(1.5cm)

  #align(center)[
    #text(size: 26pt, weight: "bold")[Projet de fin d'études] \
    #v(0.5cm)
    #text(
      size: 14pt,
      style: "italic",
    )[Optimiser la compression vidéo par prétraitement IA : contourner les limites des outils classiques] \
  ]

  #v(2cm)

  #line(length: 100%, stroke: 1.5pt + gray)
  #v(0.2cm)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1cm,
    [
      #text(size: 10pt, weight: "bold")[AUTEUR] \
      #v(0.1cm)

      #text(size: 12pt, weight: "bold")[Enzo LE BODO] \
      #text(size: 9.5pt)[Étudiant]
      #text(size: 9.5pt)[IDIA-2026]\
      #link("mailto:enzo.lebodo@capacites.fr")
    ],
    [
      #text(size: 10pt, weight: "bold")[ENCADREMENT] \
      #v(0.1cm)

      #text(size: 11pt, weight: "bold")[Pierre LEBRETON] \
      #text(size: 9.5pt, style: "italic")[Tuteur Entreprise] \
      #link("mailto:pierre.lebreton@capacites.fr")



      #v(0.3cm)

      #text(size: 11pt, weight: "bold")[Matthieu PERREIRA DA SILVA] \
      #text(size: 9.5pt, style: "italic")[Tuteur Académique]

      #v(0.3cm)

      #text(size: 11pt, weight: "bold")[Bruno THEILLAC] \
      #text(size: 9.5pt, style: "italic")[Référent Apprentissage]
    ],
  )

    #v(0.2cm)
    #line(length: 100%, stroke: 1.5pt + gray)
    #v(0.1cm)
    #text(size: 10pt, fill: gray)[
      *Capacités SAS* — Cellule IXPEL \
      Siège social : 1 quai de Tourville 44000 Nantes, France \
      Adresse postale : 16, rue des Marchandises 44200 Nantes, France\
      Tel : (+33) 02 72 64 88 81 \
      #link("https://capacites.fr/")[www.capacites.fr]
    ]
]

#pagebreak()

#set page(
  header: align(right)[Projet de fin d'études Enzo LE BODO IDIA2026],
  footer: context [
    #align(center)[
      #counter(page).display("1 / 1", both: true)
    ]
  ],
)
#counter(page).update(1)

#set heading(numbering: "1.1.")

// Espacement général autour de tous les titres
#show heading: it => [
  #v(0.85cm)
  #it
  #v(0.45cm)
]

// Saut de page avant chaque chapitre de niveau 1
#show heading.where(level: 1): it => [
  #pagebreak(weak: true)
  #it
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
Le secteur de la #gls("vod", "vidéo à la demande (VOD)") a connu un essor très important, notamment avec l'arrivée de nombreuses plateformes de contenu. Contrairement à la TNT, où une seule antenne émet un signal capté par un grand nombre de foyers sans coût énergétique supplémentaire par spectateur, la #gls("vod", "VOD") nécessite une connexion point à point. Chaque clic sur « Play » sur Netflix ou Amazon Prime génère un flux dédié depuis un serveur (souvent via un #gls("cdn", "Content Delivery Network, CDN")), augmentant fortement la consommation de bande passante et d'énergie.
On comprend alors que, dans ce contexte, les algorithmes de compression visant à diminuer la taille de l'information transmise de manière optimisée, les #gls("codec", "codecs"), deviennent de plus en plus importants. L'évolution de leurs performances a permis de rendre ces services accessibles à de nombreuses personnes. Mais la difficulté d'évolution des architectures rend l'adoption des nouvelles versions plus complexe, ce qui pousse souvent à l'utilisation d'outils qui ne sont pas les plus optimisés.

=== Du diffuseur jusqu'au salon <vod_circuit>
La chaîne #gls("vod", "VOD") est un processus complexe qui transforme une scène captée en une vidéo diffusée mondialement. Cette chaîne se décompose en cinq étapes majeures :

- *La source* : les caméras et microphones enregistrent la vidéo et l'audio bruts. Un appareil de capture convertit ces signaux physiques en un format numérique exploitable par un ordinateur ; il se passe alors aussi un grand nombre de traitements (montage) afin d'obtenir un résultat satisfaisant.
- *Encodage* (compression de la vidéo) : c'est ici qu'intervient le premier rôle clé des algorithmes de compression (#gls("codec", "codec")). Comme les données brutes sont trop volumineuses, l'encodeur les compresse (en utilisant des standards comme #gls("h264", "H.264"), #gls("hevc", "H.265") ou #gls("av1", "AV1")) pour optimiser le poids du fichier sans sacrifier la qualité. Cette étape se situe côté fournisseur, avant de transmettre la vidéo.
- *Serveur* : le serveur reçoit le flux, le traite et le convertit en plusieurs versions (transcodage) pour s'adapter à différents appareils et débits.
- *#gls("cdn", "CDN") (distribution)* : un réseau de serveurs répartis mondialement stocke des copies du contenu. Cela permet de diffuser le flux depuis le serveur le plus proche de l'utilisateur, réduisant ainsi la latence et les interruptions.
- *Lecteur / décodeur* : c'est l'étape finale. Le lecteur (application, navigateur) reçoit le flux compressé. Le #gls("codec", "codec") intervient ici : le décodeur transforme les données compressées en images et sons lisibles pour l'écran de l'utilisateur. Cette étape se situe côté utilisateur.

#align(center)[
  #figure(
    image("images/VODtransfr.png", width: 80%, height: 110pt),
    caption: [Schéma illustrant la chaîne de transmission d'une vidéo à la demande #gls("vod", "VOD"), @coffie2025streaming],
  ) <vod_transmission>
]

Ces processus concernent les données vidéo, mais aussi audio ; dans notre cas, seules les données vidéo nous intéressent pour ce projet.

Il est important de mettre en avant la différence et le déséquilibre aux moments clés de l'encodage et du décodage.

Côté fournisseur, l'encodage est une opération réalisée sur les serveurs du diffuseur, ce qui, techniquement, est plus simple pour implémenter de nouvelles méthodes, car le diffuseur possède le contrôle total de son infrastructure. Bien qu'évolutive, cette infrastructure répond tout de même à une logique d'optimisation des coûts : une solution trop gourmande en calculs pourrait faire exploser les coûts pour les fournisseurs, et une solution n'apportant pas une grande optimisation mais demandant de modifier toute l'architecture serait aussi difficilement acceptable de ce point de vue.

Côté utilisateur, le décodage est effectué directement par l'appareil (TV, smartphone). Ces appareils utilisent des puces de décodage matériel conçues pour être économes en énergie et rapides. Ces puces sont figées lors de la fabrication. La seule alternative, pour un appareil dépourvu du circuit adéquat, est le décodage logiciel, c'est-à-dire faire exécuter le calcul de décodage par le processeur général. Cette voie est universelle, mais bien moins efficace. Il est donc extrêmement complexe de modifier le comportement de ce décodage ou d'y introduire de nouvelles méthodes, car cela nécessiterait de mettre à jour le matériel ou d'imposer des contraintes incompatibles avec les appareils existants. Cette limite s'explique notamment par le fait que les nouvelles solutions, apportant une optimisation, s'accompagnent d'un nombre plus important de calculs, ce qui n'est pas toujours supporté par l'ensemble des appareils.

On comprend alors que la balance se trouve, à court terme, dans des solutions d'optimisation peu gourmandes en ressources. Cela permet de répondre à l'optimisation des coûts de l'entreprise, mais aussi aux limites matérielles côté utilisateur. On peut aussi prédire des modifications futures plus importantes, advenant à la suite d'une maturité suffisante des outils nécessitant cette évolution.

De ce constat, on peut estimer qu'une optimisation réaliste se trouverait en amont du transfert de la vidéo. En particulier, car une vidéo encodée sera transmise à un grand nombre d'utilisateurs : optimiser une vidéo pourrait alors devenir intéressant plus rapidement.

=== Les enjeux économiques de la #gls("vod", "VOD") et liens avec la recherche

Une question guide cette mise en contexte : quels sont les enjeux économiques de la #gls("vod", "VOD"), et en quoi une optimisation en amont de la compression répond-elle aux besoins des acteurs du secteur ?

La #gls("vod", "VOD") représente aujourd'hui une part majeure du trafic internet mondial, et chaque flux transmis a un coût, en bande passante, en stockage et en énergie. Les ordres de grandeur sont éloquents : la vidéo reste la première catégorie d'application en volume sur les réseaux, et une poignée d'acteurs, parmi lesquels Netflix, Amazon ou Meta, concentrent à eux seuls plus de la moitié du trafic web @applogic2025gipr.

Ce poids dans le trafic s'accompagne d'un marché en forte croissance. Le segment de la #gls("vod", "VOD") par abonnement (SVOD, _Subscription Video On Demand_) était évalué à 151,9 milliards de dollars en 2023, et les projections l'estiment à plus de 408 milliards à l'horizon 2032, soit une croissance annuelle moyenne supérieure à 11 % @gmi2024svod. Cette dynamique est un point essentiel pour notre sujet : plus le volume de contenus diffusés augmente, plus une optimisation appliquée une seule fois en amont devient rentable, puisqu'elle profite ensuite à l'ensemble des utilisateurs qui regarderont la vidéo. Pour des plateformes comptant des millions d'abonnés, la moindre réduction du débit moyen se traduit par des économies considérables, répétées à chaque diffusion. C'est ce qui explique l'attention portée à la compression.

#align(center)[
  #figure(
    image("images/svod_eco.png", width: 85%),
    caption: [Évolution du marché SVOD par type de contenu, 2022-2032 (en milliards de dollars) @gmi2024svod],
  ) <svodmarket>
]

Ce graphique montre la tendance du secteur ; il semble important de préciser que le secteur de la vidéo ne s'arrête pas là. Ces données excluent les plateformes financées par la publicité comme YouTube, qui n'apparaît donc pas dans ce marché alors qu'elle représente à elle seule plus de 10 % de la bande passante internet mondiale @applogic2025gipr. Or, ces plateformes s'appuient sur des outils de compression similaires (#gls("h264", "H.264"), VP9, #gls("av1", "AV1")) : l'enjeu de l'optimisation dépasse donc largement le seul périmètre du marché SVOD chiffré ici.

#align(center)[
  #figure(
    image("images/ademeVOD.png", width: 100%),
    caption: [Répartition des usages numériques et de leur impact environnemental, @arcom_ademe_2024],
  ) <ademe>
]

Ce sujet questionne aussi l'impact d'une telle optimisation sur un sujet majeur de notre époque : l'écologie. Si l'on reprend le graphique de l'ADEME, on y retrouve de nombreuses informations liées à cette thématique, et donc des éléments de réponse. Il faut alors se référer aux sections « V4 » et « V5 », qui représentent les usages liés à la #gls("vod", "VOD") sur télévision ou smartphone. On y remarque une importance relativement faible de ces données dans le total. Il faut aussi comprendre que ces optimisations peuvent avoir un impact direct sur les parties réseau : en fluidifiant le trafic par des vidéos moins gourmandes en ressources, on obtient des infrastructures qui supportent plus facilement la charge requise, rendant alors leur déploiement moins massif. Cet enjeu est loin d'être théorique, car le trafic est de plus en plus marqué par des pics : en 2024, les dix journées de trafic les plus importantes coïncidaient toutes avec un événement diffusé en direct, ce type d'événement pouvant faire bondir le trafic réseau de 30 à 40 % @applogic2025gipr. Des flux plus légers aident directement à absorber ces montées en charge.

Mais il faut aussi reprendre les éléments de la section précédente @vod_circuit. Garder des outils de compression qui prennent en compte les limites du matériel existant rend ce matériel plus durable, utiliser des outils trop gourmands en calcul rend les traitements plus lourds et complexes, ce qui peut diminuer la durée de vie des appareils utilisés. Une adoption massive d'un codec comme #gls("av1", "AV1") entraînerait ainsi une obsolescence anticipée de certains téléviseurs actuels.

On peut en revanche opposer à cette optimisation un possible effet rebond, un accès plus simple et plus rapide à davantage de ressources #gls("vod", "VOD") pourrait toucher plus d'utilisateurs, ou permettre de proposer du contenu de plus haute qualité. C'est précisément le but des entreprises dans une logique de performance et de qualité de service. Et c'est qui est remarqué lors de différentes évolution, les outils deviennent plus performant mais permettent aussi d'augmenter la résolution des contenus et donc leur qualité ce qui contenu de faire croitre les besoins et apporte de nouveaux besoins, comme de nouveaux téléviseurs supportant ces technologies. De ce point de vue, on irait alors à l'encontre des optimisations évoquées du point de vue écologique.

Les acteurs concernés par ce secteur sont parmi les plus gros du numérique, Netflix, Amazon ou Meta, et ce sont précisément les clients de notre cellule. Leurs besoins orientent donc directement nos sujets de recherche, la majorité de nos projets portent sur l'évaluation ou le développement de nouvelles solutions, souvent confrontées à un panel d'utilisateurs. Les défis remontés par le secteur confortent l'intérêt d'une optimisation agissant directement sur le poids des fichiers, les coûts de licence et de production de contenu sont identifiés comme un obstacle majeur du marché SVOD @gmi2024svod, tandis qu'une étude récente place le stockage comme premier défi des entreprises de streaming interrogées @challengesVOD. Réduire le poids des fichiers agit directement sur ces deux postes, et donc sur les coûts à différents points de la chaîne.

Enfin, un point mérite d'être souligné : l'écosystème open source et open access joue un rôle clé. Il permet de faire évoluer les outils de compression, mais donne aussi accès à des outils de mesure de qualité vidéo complexes, parfois développés en interne par ces entreprises, et dont la disponibilité conditionne en grande partie la recherche dans ce domaine. Cela semble parfois en contradiction avec la volonté générale des entreprises technologiques, qui cherchent à protéger leurs outils pour ne pas aider la concurrence. Cependant, dans ce cas précis, ces entreprises profitent aussi d'une communauté très active autour des contenus vidéo : des utilisateurs ou des groupes de recherche s'emparent de leurs outils et proposent des améliorations que leurs équipes internes ne pourraient pas toutes réaliser. Faire évoluer le secteur permet à ces entreprises d'en tirer profit, nous l'avons vu le secteur est en forte hausse, chaque optimisation compte et cette aide externe, gratuite, est intéressante. Cela devient aussi un argument pour les travailleurs de ces entreprises qui peuvent mettre en avant leurs travaux publiquement. On peut toutefois illustrer la limite de cette logique, ces entreprises partagent peu, voire pas, leurs données, y compris celles utilisées pour produire ou entraîner des outils qui seront ensuite mis en accès libre. Cela montre que cette volonté de partage reste ciblée, éloignée d'une générosité soudaine qui ne correspondrait pas à une logique économique.

=== Rapport d'utilisation des outils de compression
Pour mieux comprendre les éléments suivants, voici un bref historique des outils existants.

#align(center)[
  #figure(
    image("images/historique_codec.png", width: 100%, height: 125pt),
    caption: [Historique et évolution des outils de compression vidéo (#gls("codec", "codecs")) entre 1990 et 2017 @moreira2022digitalvideo],
  ) <historiqueCodec>
]

Afin de mettre en avant la difficulté d'évolution des outils de compression par les entreprises concernées, les figures suivantes illustrent la répartition d'utilisation des outils de compression en 2023 et 2024 sur un panel d'entreprises. On peut y voir que les plus récents ne sont pas encore adoptés par la majorité des entreprises, ce qui montre la difficulté d'évolution.
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

Il est intéressant de noter que les chiffres évoluent peu, ce qui prouve l'écart entre la volonté d'évolution et la faisabilité réelle. On voit que le #gls("codec", "codec") le plus utilisé en 2025 reste #gls("h264", "H.264"), pourtant créé en 2003. Cependant, #gls("hevc", "H.265") et #gls("av1", "AV1") représentent les candidats des prochaines années d'après ces sondages.
Un point important, énoncé dans la section précédente : le matériel actuel est aussi un élément à prendre en compte. À ce jour, il existe beaucoup plus de matériel capable de décoder #gls("hevc", "H.265") nativement, ce qui le rend plus efficace et moins énergivore. Sans ce décodage natif, la tâche devient plus complexe pour des appareils plus anciens, car ils doivent se débrouiller avec la puissance des processeurs en place, ce qui, notamment avec #gls("av1", "AV1") qui demande plus de calcul, cela devient alors plus compliqué, voire impossible.

Le choix d'une cible d'optimisation réaliste et qui prend en compte ces différents éléments semble donc clair : #gls("hevc", "H.265") est aujourd'hui très intéressant pour ce cas d'utilisation, pour tous les points évoqués.


== Problématique
Nous avons vu que la diffusion de contenu vidéo est soumise à de fortes contraintes, en particulier matérielles côté utilisateur. Optimiser un codec déjà en place comme #gls("hevc", "H.265"), plutôt que d'en imposer un nouveau, apparaît donc comme la voie la plus réaliste : on réduit la taille des flux transmis sans toucher aux appareils des utilisateurs. C'est précisément ce que l'intelligence artificielle (IA) pourrait permettre.

L'idée explorée dans ce projet est d'utiliser l'IA en amont de la compression, pour prétraiter la vidéo : ajuster l'image de façon à la rendre plus facile à compresser, et ainsi réduire le poids du fichier final à qualité visuelle équivalente. L'intérêt de l'IA tient à sa capacité d'adaptation : là où les méthodes traditionnelles peinent face à la diversité des contenus, un modèle peut apprendre à repérer ce qui compte visuellement et à modifier l'image en conséquence. On obtient une approche potentiellement plus souple, et moins coûteuse en calcul que des optimisations classiques poussées.
Reste un obstacle majeur. Les codecs vidéo n'ont jamais été pensés pour servir dans un apprentissage : ils s'intègrent donc mal dans le flux de travail d'une IA. La question principale est alors de définir les moyens permettant à l'IA d'apprendre efficacement à travers un codec classique comme #gls("hevc", "H.265"), malgré les limitations de ce dernier. C'est le verrou technique central du projet.

À cette question s'en ajoutent deux autres, propres au sujet. D'abord, comment évaluer la qualité d'une vidéo optimisée par IA, alors que les outils existants sont conçus pour juger une vidéo encodée de façon classique ? Ensuite, comment guider l'apprentissage pour qu'il simule la satisfaction réelle d'un utilisateur final ? C'est un point clé, mais un défi de taille, là encore parce que les outils actuels ne sont pas faits pour cela : la plupart des projets IA et vidéo reposent sur des mesures simples, efficaces pour orienter l'apprentissage, mais aveugles aux spécificités de la perception visuelle humaine.

En résumé, ce projet questionne la faisabilité d'une optimisation de la compression vidéo par IA dans le cadre des codecs existants comme #gls("hevc", "H.265"). Il s'agit d'y intégrer l'IA pour gagner en performance tout en respectant les contraintes matérielles et les exigences de qualité visuelle. Le dépassement des verrous liés aux algorithmes de codage classiques et la définition des bons outils d'évaluation seront donc étudiés en parallèle, comme les deux faces d'un même problème.

Au-delà de ce verrou technique, ce rapport examine également le projet sous trois angles complémentaires : économique, organisationnel et humain.

= Présentation de l'environnement de travail

== L'entreprise
Capacités SAS est une filiale privée de valorisation de la recherche de Nantes Université. Créée en 2005, elle emploie aujourd'hui environ une centaine de collaborateurs. L'entreprise est détenue à 93 % par Nantes Université et à 7 % par la chambre de Commerce et d'Industrie de Nantes Saint-Nazaire. Elle est présente sur trois villes du Grand Ouest : La Roche-sur-Yon, Saint-Nazaire et Nantes.

#align(center)[
  #figure(
    image("images/capateams.png", width: 100%),
    caption: [Cartographie des cellules de Capacités],
  ) <capateams>
]

Capacités est divisée en 13 cellules d'expertise. Les cellules portent des projets d'entreprise au sein des laboratoires auxquels elles sont rattachées, pour avoir accès à une expertise et être au plus près de la découverte scientifique.

#align(center)[
  #figure(
    image("images/capaExp.png", width: 100%),
    caption: [Expertises des cellules de Capacités],
  ) <capateams>
]

Elles apportent aussi un support à la recherche lors d'un besoin en ingénierie. Les cellules sont composées de chercheurs, ingénieurs et techniciens. Chaque équipe possède ses propres clients et gère une partie de son budget pour l'attribuer selon les ressources nécessaires. Il existe également des projets inter-cellules pour regrouper plusieurs domaines d'expertise sur les sujets pluridisciplinaires.

== La cellule IXPEL
Je travaille au sein de la cellule IXPEL, intégrée à l'équipe de recherche IPI (Image Perception Interaction), qui appartient au LS2N (Laboratoire des Sciences du Numérique de Nantes). L'équipe est spécialisée dans l'intelligence artificielle appliquée à l'image et la qualité d'expérience. On y retrouve par exemple des sujets liés à l'imagerie médicale, au traitement de documents manuscrits et à l'expérience/qualité utilisateur face à du contenu vidéo ; l'équipe est reconnue mondialement sur ce dernier sujet, ce qui lui permet de travailler en collaboration avec les plus grandes entreprises du secteur et en particulier avec leurs équipes de recherche.

Les clients de notre cellule sont de grandes entreprises du numérique comme Meta, Netflix ou Amazon. L'équipe IPI et la cellule IXPEL sont reconnues pour les tests subjectifs et la qualité d'expérience ; c'est notamment pour ce genre de sujets que les projets avec ces entreprises portent. Les tests permettent par exemple de recueillir des données sur la satisfaction d'utilisateurs face à des contenus vidéo, ce qui permet par la suite d'évaluer des méthodes et solutions mises en place. Nous avons également comme client le laboratoire lui-même. Quand le laboratoire montre un besoin de programmation ou d'autres tâches d'ingénierie pour un des projets en cours, il fait appel à notre cellule si cela reste dans nos domaines de compétences. D'autres clients plus ponctuels peuvent aussi faire appel à notre cellule pour la mise en place d'outils liés à la vision par ordinateur et à l'image plus généralement.

Cet environnement facilite donc les échanges avec le laboratoire, ce qui fluidifie l'avancement des projets de recherche, mais apporte aussi à notre cellule un lien fort avec les thématiques de recherche actuelles. C'est pour nous un argument très important, car cela montre la possibilité de travailler sur des solutions innovantes. Ce lien est donc bénéfique pour les deux parties.

La cellule est actuellement composée de 8 membres, ce chiffre évolue fréquemment, notamment du fait de l'arrivée de stagiaires ou selon la durée des contrats en cours.

= Organisation du projet

Ce chapitre cherche à répondre à une question : comment une petite cellule, à l'interface entre un laboratoire de recherche et une entreprise, s'organise-t-elle pour mener un projet complexe, avec les contraintes de ressources et de coordination que cela implique ? Les sections qui suivent y répondent en présentant le cadre du projet, les rôles de chacun, puis les méthodes et outils de travail au quotidien.

== Contexte du projet
Ce projet est en lien avec Amazon Elemental, filiale d'Amazon. Ce groupe s'intéresse aux problématiques liées à la vidéo, notamment du fait des différents services qu'il propose, tel que Prime Video. Ce projet prend part dans une collaboration à plus long terme et fait suite à d'autres projets en lien avec cet organisme.

Ce projet s'inscrit aussi dans la dynamique de la cellule. Sa montée en charge s'est accompagnée de recrutements, et le sujet, à la croisée de la compression vidéo et de l'apprentissage automatique, a contribué à orienter certains des profils recherchés. // TODO : préciser le volume de recrutements ou les profils concernés si tu as les éléments.
Pendant son déroulement, il occupe une place importante au sein de l'équipe : il mobilise plusieurs membres et s'appuie sur les compétences cœur de la cellule.

Un objectif transversal mérite par ailleurs d'être mentionné dès maintenant : au-delà des résultats, le projet vise à produire des outils réutilisables par l'équipe. La documentation rédigée et le code, versionné sur la plateforme GitLab de l'équipe, doivent permettre de capitaliser sur ce travail pour les contributions futures.

Ce projet a pour ambition d'étudier le sujet de l'IA dans le cadre de l'optimisation vidéo. Cela prend la forme d'une preuve de concept, où les études réalisées seront présentées à l'entreprise cliente afin de définir la faisabilité d'une telle optimisation. Pour ce faire, différents jalons sont posés : quels outils permettent au mieux d'évaluer la qualité d'un contenu vidéo ? Par la suite, des FOM (_Figure Of Merit_) devront définir les méthodes d'évaluation de la réussite d'une optimisation. Ces premiers jalons donnent une base solide qui sera réutilisable pour les étapes d'optimisation. D'autres aspects du projet consistent aussi en l'évaluation des méthodes d'optimisation par IA. C'est d'ailleurs dans cette partie que ce projet de fin d'études prend place : le but est de définir les outils possibles pour ce genre d'optimisation, et de répondre aux différentes problématiques posées par les outils de codage vidéo classiques pour l'apprentissage. Il sera alors question d'implémenter des solutions et d'évaluer leurs performances et leur pertinence dans le projet. Ces tests sont aussi liés à l'évaluation des différents outils de mesure de qualité, car ils seront la clé d'un apprentissage réussi.
Par la suite, une fois les différentes études menées sur l'outillage nécessaire à une optimisation réussie, l'objectif final sera de mettre ces outils en œuvre sur des cas contrôlés de vidéo, afin d'évaluer les optimisations obtenues.
Il est important de rappeler que ce PFE s'intègre dans le projet et que différentes contributions seront réalisées plus tard, dans la suite de celui-ci.


== Planning
Le projet est structuré autour de trois Work Packages complémentaires, s'étalant d'avril 2026 à mars 2027.

L'articulation globale des tâches ainsi que l'enchaînement des différents jalons de validation sont détaillés dans le diagramme de Gantt disponible à la fin du document (voir @planning en annexe).


== Les membres du projet

Dans la section précédente, nous avons évoqué le nombre de membres de la cellule ; ici, nous verrons combien de personnes participent à ce projet et les rôles de chacun.

*Patrick LE CALLET (Responsable scientifique)*

Il assure le bon déroulement du projet et les discussions avec le client afin d'aboutir aux exigences du projet de départ. Il est aussi un élément moteur des idées amenant à ce projet.

*Pierre LEBRETON (Ingénieur et responsable de cellule)*

Encadrant des membres de la cellule, et donc des participants au projet, il est au quotidien le garant de la qualité des actions liées au projet ; il en est aussi le référent technique. Son rôle est polyvalent : il travaille sur des implémentations techniques mais aussi sur la gestion des différents aspects du projet.

*Lina GUEMBRI (Ingénieure)*

Son rôle se trouve majoritairement dans l'évaluation des #gls("metrique", "métriques") de qualité vidéo, l'étude de leurs défauts et les solutions permettant d'y échapper.

*Jipeng XIA (Stagiaire)*

Il travaille sur la thématique des outils d'optimisation de compression vidéo par filtrage IA, en particulier en étudiant l'état de l'art des solutions actuelles et leurs implémentations.

*Mon rôle*

En tant qu'alternant, ce projet a commencé pour moi par une première étude sur l'utilisation d'une #gls("metrique", "métrique") de qualité vidéo dans le cas de l'entraînement d'un #gls("codec_neuronal", "codec neuronal"). L'objectif était de faire ressortir de possibles améliorations mathématiques de cette métrique afin d'en améliorer la pertinence et son utilisation durant l'apprentissage. C'était un premier pas dans ce domaine, qui m'a permis d'apprendre de nombreuses notions importantes.

Par la suite, dans le cadre de mon PFE, je travaille majoritairement sur les analyses et implémentations d'outils d'optimisation, plus particulièrement sur l'aspect #gls("proxy", "proxy") de #gls("codec", "codec") afin de contourner les limitations des outils classiques ; en d'autres termes, créer un jumeau des outils classiques qui guidera l'apprentissage. Si l'on s'en fie au planning, cette tâche fait partie du Work Package n°3 concernant l'étude des cas d'utilisation des métriques, dans ce cas le filtrage d'images en pré-compression. La thématique des outils de mesure de qualité vidéo étant directement liée à ce sujet, ma mission réside aussi dans l'étude des meilleurs outils pour ce cas d'usage et de leurs spécificités, ce qui fait le lien avec les différents autres jalons du projet.

== Estimation prévisionnelle du projet
Ce porjet a débuté pour moi courant mars, en considérant la date de rendu du document écrit mi-juillet, une période d'environ 4 mois se présente pour ce projet de fin d'études. Ce qui représente environ 80 jours ou environ 560 heures de travail. 

#figure(
  caption: [Répartition prévisionnelle de la charge de travail du PFE (en jours).],
  table(
    columns: (1fr, auto),
    align: (left, center),
    stroke: 0.5pt + rgb("#888"),
    inset: 6pt,
    table.header([*Poste*], [*Jours*]),
    [Etat de l'art et apprentissage continu (compression, deep learning, méthodes, métriques)], [15 j],
    [Étude et analyse des métriques de qualité (corrélations, choix du guide, test d'optimisation)], [5 j],
    [Implémentation des solutions : Code, test (concluants ou non), débug], [25 j],
    [Expérimentations : entraînements/itérations, tests, analyse des résultats], [20 j], 
    [Réunions POP, points d'équipe, séminaires, échanges encadrants], [5 j],
    [Rédaction du mémoire, figures, documentation projet, présentation réunion], [10 j],
    table.hline(stroke: 0.7pt),
    [*Total*], [*80 j*],
  ),
) <repartition_charge>

== Outils et méthodes de travail

=== Méthodes de suivi et de travail

Au sein de la cellule, les projets ne regroupent que peu de personnes à chaque fois, et les missions peuvent parfois ne pas nécessiter une communication quotidienne poussée. Il reste cependant important de garder en tête les avancées de chacun ; c'est pourquoi nous tenons des réunions hebdomadaires. Nous suivons la méthode POP, qui simplifie la gestion des réunions en les rendant plus dynamiques. Tous les lundis, face à un tableau prévu à cet effet, représentant la semaine actuelle et la semaine passée, nous précisons ce que nous avons réalisé la semaine précédente et ce que nous envisageons de faire pour la semaine en cours. On utilise aussi des post-it qui permettent de garder une trace des points clés évoqués et de suivre ce qui était prévu et ce qui a été fait d'une semaine à l'autre.
C'est un moment où l'on peut plus facilement débloquer des situations, se donner des conseils et établir une organisation des tâches plus cohérente, car tous les membres sont alors disponibles.

Le reste du temps, les échanges concernant les différents projets sont plus informels, facilités par notre proximité dans les locaux. Il est aussi fréquent de faire des points ou des présentations pour mettre au clair un avancement, des idées ou des besoins spécifiques pour un projet, des moments essentiels quand le projet regroupe plusieurs personnes.

Les échanges se font majoritairement en français, mais ponctuellement en anglais, en fonction de l'aisance de chacun avec le français.

=== Outils de communication et de suivi
Notre cellule étant de petite taille, la communication y est facilitée : nous travaillons tous dans le même bureau. Cependant, nous faisons partie de deux autres organismes, le laboratoire de recherche, avec lequel nous partageons les mêmes locaux, et l'entreprise. Cela entraîne donc des besoins de communication et de gestion par des canaux différents. Concernant le laboratoire, nous avons des canaux liés à l'université, notamment l'outil Mattermost, qui permet de réaliser des échanges en ligne sous forme de chat, en groupe (notamment pour les différents projets) ou seul. D'autres outils liés à l'université nous sont mis à disposition : UnCloud, qui permet d'avoir un stockage cloud et de partager facilement des documents volumineux ; Webmail, un service de mail en ligne en lien avec l'université ; Glicid, un cluster de calcul partagé disponible pour la recherche, en particulier dans la région nantaise.
Le lien avec l'entreprise est, lui, plus distant ; des outils et protocoles sont mis en place pour suivre l'évolution des projets par les responsables et services de gestion de l'entreprise. Lucca permet la gestion des congés et autres absences ainsi que le partage de documents RH aux employés ; Laboxy permet d'attribuer les heures effectuées aux projets concernés.

=== Outils internes

Au sein du laboratoire, et en particulier de la cellule, nous possédons aussi des serveurs de calcul qui permettent de répartir les ressources entre les membres de l'équipe et, en particulier, de stocker des dossiers volumineux, notamment des vidéos sources qui peuvent parfois devenir très encombrantes.
Ces outils sont importants, mais demandent une organisation particulière pour une utilisation par plusieurs personnes : création de sessions différentes, limites d'utilisation des ressources processeur ou graphique par chacun. Le nombre de membres au sein de l'équipe ayant augmenté, ces outils internes ne suffisent pas pour que chacun puisse les utiliser quotidiennement, mais ce ne sont pas les seuls outils à disposition.

=== Adaptation et impact des outils utilisés
Parmi les outils utilisés durant ce projet, l'un en particulier permet de nous affranchir d'un besoin matériel important : Glicid.
C'est un cluster de calcul partagé, accessible à un ensemble de projets de recherche et aux entreprises qui en paient l'accès. Glicid fournit différents environnements permettant d'accéder à des processeurs puissants ou à des cartes graphiques, deux moyens d'effectuer un grand nombre de calculs et de faire exécuter différents algorithmes. C'est essentiel pour travailler avec des outils d'intelligence artificielle comme nous le faisons. Cette plateforme permet donc de centraliser les ressources matérielles nécessaires à de nombreux projets. Cela rend ces ressources plus accessibles financièrement, mais limite aussi l'impact écologique de chaque projet : chaque environnement est utilisé pleinement, ce qui permet d'en optimiser l'utilisation ; quand un test est terminé, un nouveau peut être lancé. De plus, les outils proposés évoluent, ce qui mutualise les besoins et facilite l'accès à de nouvelles technologies coûteuses.

Cet outil nécessite cependant une adaptation pour une utilisation optimale : différents environnements à comprendre, et la manière de bien formuler la demande pour un environnement qui réponde aux besoins du test en cours.
Cela fait donc partie de nos missions : s'adapter aux outils utilisés et à leurs évolutions au fil du temps.

Pour notre cellule, on peut facilement se partager des astuces ou bonnes pratiques pour mieux appréhender ce genre d'outil. C'est devenu un indispensable pour certains membres de l'équipe, et cela permet de mieux gérer nos ressources internes. Glicid est aussi maintenu, ce qui facilite la tâche, car pour des ressources internes, cela demanderait plus de travail.

Cependant, ces maintenances imposent aussi des moments d'arrêt de l'outil ; un grand nombre de jours durant ce projet ont été privés de cette ressource pour maintenance ou inaccessibilité de la plateforme. Cela limite l'organisation des tâches et peut parfois ralentir l'avancée de certains projets.

De manière générale, c'est un outil atypique qui modifie la manière de travailler : entre adaptation aux mécanismes spécifiques et contraintes liées à l'accès à la plateforme, l'organisation au quotidien en est dépendante.

=== La vie du laboratoire

Partageant les mêmes locaux et faisant partie de l'équipe IPI, nous participons aussi aux différents moments conviviaux de l'équipe, notamment les repas et les séminaires. Il est fréquent que des séminaires soient organisés, où doctorants, chercheurs ou invités présentent leurs travaux. Ces présentations se déroulent en anglais pour que tout le monde puisse suivre, car le laboratoire accueille souvent des stagiaires étrangers.

Ces moments profitent à tous. Pour ceux qui présentent, c'est l'occasion de valider leurs propos, de recueillir des idées d'autres chercheurs et de gagner en assurance. Pour ceux qui écoutent, c'est une façon d'aborder des concepts complexes et de pratiquer l'anglais sur des sujets précis et techniques.

En apparence anodins, ces moments illustrent assez bien ce que la littérature en management appelle l'apprentissage par l'action (_execution-as-learning_), par opposition à une logique de pure exécution @edmondson2012teaming. Edmondson montre notamment qu'une équipe apprend d'autant mieux qu'elle dépasse ses frontières internes (distances physiques, différences de statut, écarts de connaissance), par exemple via des temps d'échange réguliers. Les séminaires jouent exactement ce rôle, ils font circuler les connaissances entre des profils et des projets différents. Une étude menée sur 90 équipes, citée par ces travaux, observe d'ailleurs que les questions et interruptions lors des réunions améliorent le transfert de connaissances et l'acquisition de nouvelles pratiques. Cela suppose toutefois un climat où questionner n'est pas perçu comme une marque d'ignorance, ce que ces auteurs nomment la sécurité psychologique. En faisant le parallèle avec nos réunions, on retrouve une ambiance ouverte pour ces présentations, car c'est l'objectif, questionner sur un sujet que l'on découvre souvent durant la présentation. Il est parfois difficile de rendre les questions utiles pour le sujet en lui-même, et pas uniquement de les orienter pour notre propre compréhension.

= Compression et qualité vidéo : défis et solutions

== Contexte de l'équipe et formation

On peut ici se poser une question : comment une équipe jeune vit-elle et monte-t-elle en compétence sur des thématiques de pointe comme le deep learning et la qualité vidéo, entre veille permanente, partage de connaissances et accompagnement ?

La jeunesse de l'équipe est un point à prendre en compte. Cela peut être vu comme un atout pour se tourner vers l'innovation et faciliter l'acceptation aux changements, mais cela demande aussi une montée en compétence rapide sur des sujets d'expertise pointus pour répondre aux attentes du projet. La compression vidéo est un domaine riche en théorie et en concepts complexes, appartenir à une équipe experte facilite cette montée en compétence, mais une part du travail passe nécessairement par des recherches personnelles. Le deep learning associé à ce sujet est tout aussi exigeant, et certaines compétences ne s'acquièrent qu'au fil du projet. Cette progression demande donc du temps, et l'évolution rapide de ces domaines impose une veille au quotidien.

La recherche sur l'adoption des technologies aide à nuancer l'idée, intuitive, qu'une équipe jeune serait simplement « moins réticente ». Étudiant l'adoption d'un nouvel outil logiciel sur cinq mois, Morris et Venkatesh observent surtout que les déterminants de l'usage varient avec l'âge, chez les travailleurs les plus jeunes, la décision d'utiliser l'outil est davantage portée par l'attitude, c'est-à-dire par l'utilité qu'ils lui perçoivent, tandis que pour les plus âgés pèsent davantage l'avis des pairs et la facilité de prise en main @morris2000age. Pour une équipe jeune comme la nôtre, cela suggère que l'adoption d'un nouvel outil ou d'une nouvelle méthode se joue surtout sur sa valeur perçue, autrement dit, démontrer concrètement ce qu'il apporte est sans doute le meilleur levier. Ces résultats doivent toutefois être pris avec prudence, ils reposent sur un échantillon réduit, et les auteurs eux-mêmes rappellent qu'on ne peut distinguer nettement un effet propre à l'âge d'un simple effet de génération mais cela montre tout de même une tendance, liée à l'âge ou à la génération, ce qui vient tout de même confirmer qu'une équipe jeune, venant d'une génération proche les uns des autres, pourrait avoir un comportement commun face aux changements. Si l'on prend l'exemple concret au sein de notre équipe, nous avons vu arriver il y a quelque temps des accès directement fournis par l'entreprise pour un outil de chat par IA, qui s'intègre aussi directement dans des projets pour faciliter l'écriture de code informatique. Avoir un outil commun permet de centraliser les connaissances sur ce domaine et les bonnes pratiques, mais surtout, de ne pas rendre le sujet tabou, ce qui pourrait amener à des comportements plus difficiles à contrôler, on entend actuellement parler de « shadow AI », phénomène émergent où l'utilisation de ce genre d'outils est réalisée par les employés sans approbation de leurs supérieurs ou du service informatique. L'intérêt d'utiliser ces outils pour des jeunes ingénieurs est simple, cela facilite l'accès à un grand nombre de connaissances et simplifient l'implémentation pour tester des outils rapidement. L'acceptation semble donc rapide car l'outil est vu comme utile. Cela renforce alors les résultats obtenus dans l'étude présentée. Il reste tout de même intéressant de rendre les pratiques plus contrôlées et raisonnées pour éviter des dérives, ce que l'entreprise essaie de faire au niveau global pour éviter que chaque cellule ait à le faire.

Au-delà de la perception des outils, la montée en compétence dépend fortement de l'environnement de travail. Les travaux d'Edmondson sur le « teaming » montrent qu'un environnement psychologiquement sécurisant, où chacun peut poser des questions, reconnaître ses limites et solliciter de l'aide sans crainte d'être jugé, accélère l'apprentissage collectif @edmondson2012teaming. C'est un point clé pour nous, se sentir dans une équipe où d'autres ont probablement les mêmes questionnements, de par un manque logique d'expérience, pousse à partager les réponses ou les sources explicatives trouvées. Ce partage, joint à un investissement personnel et à une veille régulière, est ce qui permet de combler progressivement le manque d'expérience sur ces thématiques. Cela reste un processus qui prend du temps, notamment du fait de la complexité du domaine de la compression vidéo et, pour ce projet en particulier, de la complexité du domaine du deep learning.


== Encodage : la réduction d'informations transmises

Le codage vidéo repose sur un grand nombre de principes parfois complexes ; le but ici sera seulement de donner les logiques de base et certains éléments importants qui permettront une meilleure compréhension du sujet et faciliteront l'identification des éléments d'une possible amélioration.
Une vidéo est une suite d'images qui se suivent, souvent très rapidement (plusieurs par seconde). On peut parfois avoir des vidéos qui contiennent 30, 60, voire 120 images par seconde (#gls("fps", "FPS")), et plus dans certains cas, pour des types de contenus qui demandent une grande fluidité. Durant un court laps de temps, la scène ne change que très peu. C'est le point principal utilisé pour la compression vidéo : exploiter cette redondance d'informations de manière efficace.
Pour bien comprendre les différents concepts, il faut aussi avoir en tête que les images sont décomposées en blocs, qui peuvent être de taille variable pour une même image. Dans les exemples, nous garderons une taille fixe pour faciliter la compréhension.

Pour illustrer ce mécanisme, voici un exemple simple qui permet de comprendre la logique utilisée.

#align(center)[
  #figure(
    image("images/interMotion.png", width: 90%, height: 190pt),
    caption: [Exemple de mouvement prédit @moreira2022digitalvideo],
  ) <intermotion>
]

Le premier point est la principale optimisation, qui utilise une répétition d'informations, mais il faut tout d'abord transmettre une image clé, qui servira de point d'ancrage pour réaliser cette prédiction de mouvement. Une image clé est transmise pour chaque groupe d'images (#gls("gop", "GOP")).
Ces images clés doivent être transmises entièrement, ce qui peut parfois avoir un coût important. On utilise alors une autre forme de redondance, au sein d'une même image, des zones simples comme un ciel bleu pourront être transmises simplement, car les blocs voisins se ressemblent.
Pour ce faire, il faut dérouler à partir des informations connues de l'image, qui sont déjà prédites. Le bloc en haut à gauche est transmis en premier, il servira alors de base pour la suite des prédictions qui vont dérouler jusqu'à terminer l'image.
Toutes ces prédictions sont réalisées avec comme contrainte de s'éloigner le moins possible de l'image d'origine, ce qui permet de choisir parmi les différentes options qui permettent de dérouler l'image.

Voici un exemple qui montre la manière dont cela est utilisé.

#align(center)[
  #figure(
    image("images/intraExemple.png", width: 80%, height: 220pt),
    caption: [Exemple de la réutilisation de la partie de l'image connue @moreira2022digitalvideo],
  ) <intraexemple>
]


Différentes options permettent de dérouler l'image, dans les outils récents il en existe de nombreuses mais pour comprendre la logique voici quelques exemples simples :

- La prédiction horizontale : On lisse de gauche à droite. L'encodeur considère que les pixels d'une ligne sont la continuité directe des pixels situés juste à gauche. Il recopie simplement les valeurs de la colonne précédente pour remplir le bloc.
- La prédiction verticale : On lisse de haut en bas. À l'inverse, l'encodeur estime que les pixels d'une colonne sont identiques à ceux de la ligne située juste au-dessus. Il « tire » l'information vers le bas pour prédire le contenu du bloc.
- La prédiction par moyenne globale : Dans les zones où les couleurs sont très homogènes (un aplat de couleur par exemple), l'encodeur calcule la moyenne des pixels voisins (en haut et à gauche) et applique cette valeur unique à tout le bloc.

Parmi ces trois options l'exemple imagé utilisait la prédiction verticale.


Une fois ces prédictions réalisées, l'image prédite n'étant pas parfaite, il manque des informations importantes à transmettre pour la corriger au mieux. Cette correction est appelée résidu : c'est la différence entre l'image prédite et l'image d'origine, autrement dit, c'est le reste des informations à transmettre pour arriver à l'image d'origine.


#align(center)[
  #figure(
    image("images/rescalcul.png", width: 110%, height: 140pt),
    caption: [Exemple de calcul du résidu pour le ciel bleu @moreira2022digitalvideo],
  ) <resCalcul>
]

#align(center)[
  #figure(
    image("images/resExemple.png", width: 50%, height: 220pt),
    caption: [Exemple visuel de résidu pour l'exemple du mouvement de la balle @moreira2022digitalvideo],
  ) <resexemple>
]

Nous verrons dans la section suivante que ce résidu n'est pas transmis tel quel car il peut parfois contenir encore un grand nombre d'informations.

== Utilisateur et compression ciblée

Au-delà de la redondance entre images et au sein d'une image, la compression exploite une autre source d'économie : les limites de la perception humaine. L'idée est simple : si l'œil ne perçoit pas une information, il est inutile de la transmettre fidèlement.

Deux mécanismes illustrent bien cette logique. Le premier repose sur la #gls("dct", "DCT") (transformée en cosinus discrète), qui réorganise l'information d'un bloc par fréquences. Les zones lisses se concentrent dans les basses fréquences, les détails fins dans les hautes fréquences. Or, l'œil est bien moins sensible à ces hautes fréquences : on peut donc les représenter plus grossièrement lors de la #gls("quantification", "quantification"), sans dégradation visible, ce qui allège fortement le poids du fichier.
Cette importance peut être simplement évoquée par des exemples visuels : plus on monte dans les fréquences, moins l'information semble essentielle.

#align(center)[
  #figure(
    image("images/exemplefreq.png", width: 100%),
    caption: [Illustration de l'importance de chaque domaine de fréquence pour la fidélité de l'image source @stackoverflow2015freqcomponents],
  ) <freq>
]

Pour illustrer la simplification des données, voici aussi un exemple de l'utilisation de cette transformation #gls("dct", "DCT") : un résultat obtenu qui permet de trier les basses fréquences dans des valeurs qui seront mieux conservées (en haut à gauche) et les valeurs de hautes fréquences comme des détails (en bas à droite). Cet exemple illustre alors la #gls("quantification", "quantification") (arrondi), qui vient simplifier ces valeurs.

#align(center)[
  #figure(
    image("images/quantification.png", width: 100%),
    caption: [Exemple de quantification venant simplifier les données obtenues après la transformation DCT @moreira2022digitalvideo],
  ) <quantif_dct>
]

Il est important de noter que ces transformations n'ont d'effet sur les données que si le paramètre de quantification « qstep » est supérieur à 0 ; sinon, les données restent intactes. Cette transformation permet alors de cibler les fréquences de l'image que l'on veut simplifier ; c'est là que repose la majorité des simplifications réalisées par les codecs pour obtenir des données plus compressibles, avec notamment davantage de valeurs simples comme des zéros. Un élément expliqué plus tard, en @th_info.

Pour avoir une idée du résultat obtenu après quantification voici un exemple pour une zone d'image qui permet de voir précisément les détails.

#align(center)[
  #figure(
    image("images/quantResult.png", width: 100%),
    caption: [Exemple de résultat après quantification, ici 67.1875% des coefficients sont supprimés @moreira2022digitalvideo],
  ) <quantif_res>
]

On observe donc que cette étape cause une perte en qualité ou au moins en fidélité à l'image originale. On remarque cependant que malgré une perte de plus de la moitié des coefficients, l'image reste globalement similaire.


Le second mécanisme concerne la couleur. Une image peut être décrite en #gls("rgb", "RGB") (_Red, Green, Blue_), mais on lui préfère l'espace #gls("yuv", "YUV"), qui sépare la #gls("luminance", "luminance") (l'intensité lumineuse) des #gls("chrominance", "chrominances") (la couleur). Là où, en #gls("rgb", "RGB"), cette luminance se retrouve dans chacune des composantes, ce qui empêche de la séparer du reste des informations.

#align(center)[
  #figure(
    image("images/RGBYUV.png", width: 100%),
    caption: [Exemple d'une image décomposée en #gls("rgb", "RGB") et en #gls("yuv", "YUV") @wikimedia_ccd_ycbcr],
  ) <rgbyuv>
]


L'œil étant beaucoup plus sensible à la luminance qu'à la couleur, on peut alors sous-échantillonner cette dernière : c'est le format 4:2:0 qui est souvent choisi, où la couleur est transmise à une résolution réduite par rapport à la luminance. La perte est réelle, mais quasiment imperceptible.

Pour comprendre ce point et l'impact qu'il a sur les données, voici un exemple en image :

#align(center)[
  #figure(
    image("images/420_exemple.png", width: 100%),
    caption: [Exemple de réduction des données en 4:2:0 et autres formats, @wiki:chroma_subsampling],
  ) <420>
]

Pour garder l'exemple du format 4:2:0, on a donc deux couleurs qui sont en fait la concaténation des chrominances rouge et bleu ce qui en réalité, représente 4 informations.

#align(center)[
  #figure(
    image("images/420_formats.png", width: 100%),
    caption: [Exemple visuel en 4:2:0 et autres formats, @wiki:chroma_subsampling],
  ) <420_visu>
]

On voit alors que malgré une réduction importante des données pour le format 4:2:0, qui supprime 75 % des informations de couleurs, on retrouve une image qui reste assez similaire à celle contenant toutes les informations (le format 4:4:4). Un autre ordre de grandeur met en avant cette efficacité, avec cette méthode on garde uniquement 50 % des données d'origines (4/4 +1/4 + 1/4 = 6/12), on a donc réduit par deux les données sans perdre trop d'information.

Ces deux exemples montrent une chose importante pour la suite : la compression ne cherche pas la fidélité parfaite, mais la fidélité _perçue_. C'est exactement le terrain sur lequel se place ce projet : modifier l'image pour qu'elle coûte moins cher à coder, sans que l'utilisateur final ne le remarque.

== Coûts des vidéos : logique et théorie <th_info>

La théorie derrière le codage arithmétique est complexe ; l'objectif de cette section est uniquement de mettre en avant la logique suivie, afin de comprendre comment une optimisation semble possible pour contrer les effets d'une compression parfois agressive.

Nous venons de voir brièvement comment les informations étaient transmises ; cependant, ces informations peuvent grandement faire varier le poids des fichiers vidéo. Une logique simple repose sur la théorie de l'information : plus une information est prédictible, moins elle coûte cher à transmettre. On comprend alors l'intérêt de la #gls("quantification", "quantification"), qui simplifie les valeurs : on retrouve par exemple un grand nombre de zéros, quasiment gratuits à transmettre.

C'est là qu'intervient le codage entropique, l'outil qui transforme réellement ces valeurs en représentation binaire (en bits). Dans #gls("hevc", "H.265"), ce rôle est tenu par le #gls("cabac", "CABAC"). Sans entrer dans le détail, il faut surtout retenir deux idées. D'abord, il est contextuel, pour coder une valeur, il regarde ses voisines déjà codées et s'en sert pour estimer ce qui va probablement suivre. Ensuite, il est adaptatif, au fil du codage, il met à jour ses probabilités en fonction de ce qu'il a réellement rencontré. Autrement dit, plus le contenu est régulier et conforme à ses attentes, plus il devient efficace.

On voit alors pourquoi avoir des valeurs simples est si important. Une suite de valeurs proches, répétées ou nulles est très prédictible : le #gls("cabac", "CABAC") lui attribue une forte probabilité et la code sur très peu de bits. À l'inverse, des valeurs dispersées et imprévisibles coûtent cher. C'est précisément ce levier que l'on cherche à exploiter : si l'on parvient, en amont, à rendre l'image plus simple à représenter une fois transformée et quantifiée (davantage de zéros, des coefficients plus réguliers), alors le codage final devient moins coûteux, à qualité visuelle comparable. C'est tout l'enjeu de l'optimisation visée dans ce projet.


== Évaluer le contenu vidéo <contenteval>

Si l'on veut optimiser une vidéo, encore faut-il pouvoir mesurer sa qualité. C'est un point central du projet, pour deux aspects : la mesure choisie servira de guide à l'apprentissage du filtre, elle se doit donc d'être un critère qui reflète la vision humaine ; et l'évaluation conditionnera aussi la pertinence des résultats obtenus.

La référence reste le jugement humain. En réunissant un panel d'utilisateurs et en moyennant leurs notes, on obtient un #gls("mos", "MOS") (_Mean Opinion Score_), considéré comme la « vérité terrain » de la qualité perçue. C'est d'ailleurs l'une des expertises reconnues de notre équipe, sollicitée pour ce type de tests par de grands acteurs du secteur. Mais ces tests sont coûteux et lents : impossible de les utiliser pour guider, image par image, l'entraînement d'un réseau de neurones.

On s'appuie donc sur des #gls("metrique", "métriques") objectives, c'est-à-dire calculées automatiquement. La plus ancienne, le #gls("psnr", "PSNR"), mesure simplement l'écart pixel à pixel avec la source, elle est facile à calculer, mais corrèle mal avec la perception humaine. Elle reste pourtant un indicateur intéressant pour mesurer les performances d'un codec, à quel point il reproduit exactement l'image d'origine.

#align(center)[
  #figure(
    image("images/PSNRDefault.png", width: 100%),
    caption: [Exemple de la différence entre fidélité structurelle et qualité perçue (score #gls("psnr", "PSNR") de 31 dB, mauvais, pour les deux images du haut, et de 34 dB, meilleur, pour celles du bas)],
  ) <psnrdefault>
]

On voit, dans cet exemple, que la mesure de fidélité de l'image au niveau des pixels ne réagit pas du tout de la même manière selon l'image : un gain de 3 dB peut être invisible ou, au contraire, grandement améliorer la qualité.

D'autres métriques, comme le #gls("ssim", "SSIM") ou surtout le #gls("vmaf", "VMAF"), cherchent à se rapprocher du jugement humain en combinant plusieurs indicateurs. Ces métriques sont au cœur du projet, mais elles ont aussi leurs défauts, un point sur lequel nous reviendrons, car une métrique mal choisie peut conduire à optimiser dans une mauvaise direction.

Enfin, il faut garder en tête que ces métriques restent des approximations. La validation finale d'une optimisation, une fois les outils suffisamment matures dans la poursuite du projet, passera par de vrais utilisateurs, c'est ce qui garantit la validité du projet, et c'est précisément le type de tests que notre cellule peut mener.

== Les limitations pour l'apprentissage

Nous l'avons mentionné, les codecs classiques s'intègrent mal dans un apprentissage. Avant de voir comment contourner ce problème, il faut comprendre d'où viennent réellement ces limites.

=== Limites mathématiques des outils pour l'apprentissage <limites_codec>

Ces limites sont avant tout mathématiques. Pour qu'un réseau apprenne, chaque opération de la boucle doit indiquer dans quelle direction ajuster les paramètres, c'est le rôle du gradient, qui donne en quelque sorte le « sens de la pente ». Une opération est utilisable pour l'apprentissage si elle est différentiable, c'est-à-dire si l'on peut calculer cette pente.

#figure(
  canvas(length: 1cm, {
    import draw: *
    let arrow = (start, end) => line(start, end, mark: (end: ">", fill: black, scale: 0.6))

    // axes
    arrow((0, 0), (5, 0))
    arrow((0, 0), (0, 3.3))
    content((5.1, 0), [$x$], anchor: "west")
    content((0, 3.6), [$f(x)$])

    // courbe lisse (parabole) : f(x) = 0.3 (x-2)^2 + 0.6
    let f = x => 0.3 * calc.pow(x - 2, 2) + 0.6
    let pts = range(0, 41).map(i => {
      let x = i / 10
      (x, f(x))
    })
    line(..pts, stroke: (paint: blue, thickness: 1.5pt))

    // point d'évaluation en x0 = 3
    let x0 = 3
    let y0 = f(x0)
    let m = 0.6 * (x0 - 2)
    circle((x0, y0), radius: 0.09, fill: red)

    // droite tangente autour de x0
    let tan = x => y0 + m * (x - x0)
    line((2.2, tan(2.2)), (3.9, tan(3.9)), stroke: (paint: red, thickness: 1.3pt))

    // petit triangle de pente (pointillés)
    line((x0, y0), (3.8, y0), stroke: (paint: gray, thickness: 0.6pt, dash: "dashed"))
    line((3.8, y0), (3.8, tan(3.8)), stroke: (paint: gray, thickness: 0.6pt, dash: "dashed"))
    content((4.15, (y0 + tan(3.8)) / 2), text(size: 8pt)[pente])
  }),
  caption: [Cas d'une fonction différentiable : en tout point, on peut calculer la pente (le gradient), qui indique dans quel sens la fonction varie, et donc dans quelle direction ajuster le paramètre.],
) <pente>

La raison principale de l'impossibilité d'utiliser ces outils est qu'ils ne sont pas prévus pour cela, ni adaptés aux langages utilisés pour l'apprentissage. Ils sont aussi très optimisés pour des calculs rapides sur processeurs, mais bien moins dans des conditions d'entraînement : de nombreux choix binaires constituent alors des murs à l'apprentissage, où l'on garde ou ne garde pas une information sans donner la raison qui serait justement le moyen de parvenir à l'optimisation.

On retrouve alors beaucoup de fonctions qui n'ont pas cette propriété. Certaines présentent des zones plates, où une petite variation de l'entrée ne change rien à la sortie : la pente y est nulle et n'indique aucune direction. D'autres présentent des cassures franches, où la pente n'est tout simplement pas définie.

Les #gls("codec", "codecs") vidéo regorgent de ce type d'opérations. La #gls("quantification", "quantification"), par exemple, repose sur un arrondi : sa courbe est un escalier, plat entre deux marches, donc de gradient nul presque partout. La sélection du meilleur bloc lors de la prédiction repose, elle, sur un argmin, un choix discret qui ne fournit aucune pente exploitable.

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    align: center + bottom,
    [
      #canvas(length: 0.95cm, {
        import draw: *
        let arrow = (start, end) => line(start, end, mark: (end: ">", fill: black, scale: 0.6))

        // axes
        arrow((0, 0), (4.4, 0))
        arrow((0, 0), (0, 4.4))
        content((4.5, 0), [$x$], anchor: "west")
        content((0, 4.7), [$Q(x)$])

        // escalier de l'arrondi
        line((0, 0), (0.5, 0), (0.5, 1), (1.5, 1), (1.5, 2), (2.5, 2), (2.5, 3), (3.5, 3), stroke: (
          paint: blue,
          thickness: 1.5pt,
        ))

        // annotation : palier plat = pente nulle
        arrow((3.0, 3.8), (3.0, 3.05))
        content((3.0, 4.05), text(size: 8pt)[pente nulle])

        // annotation : saut
        arrow((2.7, 0.9), (1.55, 1.5))
        content((3.2, 0.7), text(size: 8pt)[saut])
      })
      #v(0.3em)
      #text(size: 9pt)[(a) Arrondi (quantification)]
    ],
    [
      #canvas(length: 0.95cm, {
        import draw: *
        let arrow = (start, end) => line(start, end, mark: (end: ">", fill: black, scale: 0.6))
        let stem = (x, y) => line((x, 0), (x, y), stroke: (paint: gray, thickness: 0.6pt))

        // axes
        arrow((0, 0), (6.2, 0))
        arrow((0, 0), (0, 4.0))
        content((6.3, 0), [bloc], anchor: "west")
        content((0, 4.3), [coût])

        // tiges des coûts candidats
        stem(1, 3.0)
        stem(2, 1.9)
        stem(3, 0.8)
        stem(4, 1.7)
        stem(5, 2.8)

        // points : minimum en rouge, le reste en gris
        circle((1, 3.0), radius: 0.1, fill: gray)
        circle((2, 1.9), radius: 0.1, fill: gray)
        circle((3, 0.8), radius: 0.14, fill: red)
        circle((4, 1.7), radius: 0.1, fill: gray)
        circle((5, 2.8), radius: 0.1, fill: gray)

        // numéros des blocs
        content((1, -0.35), text(size: 8pt)[1])
        content((2, -0.35), text(size: 8pt)[2])
        content((3, -0.35), text(size: 8pt)[3])
        content((4, -0.35), text(size: 8pt)[4])
        content((5, -0.35), text(size: 8pt)[5])

        // annotation : argmin
        arrow((3.5, 2.2), (3.15, 0.95))
        content((3.7, 2.7), text(size: 8pt)[bloc choisi \ (argmin)])
      })
      #v(0.3em)
      #text(size: 9pt)[(b) Sélection du meilleur bloc (argmin)]
    ],
  ),
  caption: [Deux opérations non différentiables typiques d'un #gls("codec", "codec"). À gauche, l'arrondi de la #gls("quantification", "quantification") : sa courbe en escalier est plate entre les marches et discontinue aux sauts. À droite, la sélection du meilleur bloc par argmin : le choix n'est pas continu, il saute d'un bloc à l'autre sans fournir de pente exploitable.],
) <nondiff>

C'est notamment pour ces raisons qu'il devient complexe de reproduire fidèlement un apprentissage complet qui guiderait vers les meilleures options pour ces fonctions. Nous verrons par la suite qu'il est possible de supprimer certaines opérations et de les rendre invisibles, cependant, l'optimisation devient alors aveugle à des éléments qui sont au cœur des choix lors de la compression. Il faut alors trouver le juste milieu pour que l'environnement d'apprentissage regroupe et puisse comprendre les éléments essentiels de cette optimisation.

== Méthodologie adoptée

Mener ce projet demandait de composer avec plusieurs contraintes. Cette section les présente, ainsi que les adaptations qui en ont découlé.

=== Limites

La première limite est celle de la connaissance. Bien que des bases existaient en compression vidéo et en apprentissage automatique grâce aux projets et cours précédents, les deux domaines réunis représentaient un gap important à combler. Une partie du travail a donc consisté en de la bibliographie, des tests et inévitablement des erreurs, qui font partie du processus d'apprentissage.

La deuxième est matérielle. Comme évoqué plus tôt, les ressources de calcul ne sont ni illimitées ni toujours accessibles. Les pannes ou périodes d'inaccessibilité de Glicid ont régulièrement imposé de réorienter le travail vers d'autres tâches : bibliographie, rédaction, analyse, tout ce qui ne nécessite pas de ressources de calcul importantes.

Enfin, la limite de temps est réelle, ce PFE s'inscrit dans un projet encore récent, et certaines questions n'ont pas encore de réponse définitive.

=== Étapes et adaptation

La première étape a été d'étudier les solutions existantes et de comprendre le domaine. Cette compréhension ne s'est pas arrêtée là, elle s'est aussi construite au fil du projet, au fur et à mesure des implémentations et des résultats.

Les indicateurs de réussite ont eux aussi évolué. Au départ, peu d'informations étaient disponibles pour réaliser ces choix, on s'est appuyé sur la littérature et les connaissances de l'équipe. L'avancement du projet a ensuite permis de valider ou d'ajuster ces outils d'évaluation, notamment grâce aux analyses de corrélation présentées dans le chapitre Implémentation.

L'implémentation a suivi une logique d'essais et d'erreurs, avec des tests parfois non concluants qui ont néanmoins permis de mieux comprendre les mécanismes du deep learning dans ce contexte. Face aux limites de temps, des choix ont été faits, privilégier des tests plus simples mais solides pour parvenir à des premiers résultats évaluables, plutôt que de s'éparpiller sur des pistes trop nombreuses.


== Solutions existantes

=== Deep learning et méthodes de remplacement

Lors de l'apprentissage d'un réseau de neurones, dans notre cas le #gls("filtre", "filtre"), le code qui réalise cet apprentissage est rempli d'opérations mathématiques qui sont les piliers de l'optimisation des paramètres du réseau. Pour permettre à chaque opération d'avoir sa place dans cette optimisation, un graphe de calcul est créé : il regroupe les différents calculs exécutés durant la boucle.

Ce graphe se parcourt dans les deux sens. À l'aller (le #gls("fwbw", "forward")), on calcule normalement le résultat à partir des entrées. Au retour (le #gls("fwbw", "backward")), on remonte le graphe en sens inverse pour calculer, pour chaque opération, le gradient, c'est-à-dire la contribution de chacune à l'erreur finale. C'est cette seconde étape qui permet d'ajuster le réseau.

Séparer ces deux passes ouvre une possibilité intéressante : on peut intervenir sur le #gls("fwbw", "backward") indépendamment du #gls("fwbw", "forward"). Deux outils en découlent. Le premier consiste à « détacher » une partie du graphe, de sorte que le gradient ne la traverse pas : la valeur est bien calculée à l'aller, mais aucun gradient ne remonte par ce chemin. La @forward_backward illustre ce principe sur un calcul simple.

Le second, plus puissant, consiste à remplacer le comportement d'une fonction au #gls("fwbw", "backward"). On exécute l'opération réelle à l'aller, mais on lui substitue une approximation dérivable au retour. C'est le principe du #gls("ste", "STE") (_Straight Through Estimator_) : pour un arrondi, par exemple, on applique le vrai arrondi au #gls("fwbw", "forward"), mais on fait « comme si » la fonction était l'identité au #gls("fwbw", "backward"), ce qui laisse passer un gradient exploitable.

C'est exactement ce mécanisme qui rend possible l'usage d'opérations bloquantes, voire d'un codec entier, au cœur de l'apprentissage : on garde le comportement réel là où il compte, tout en fournissant au réseau une pente artificielle mais utile pour apprendre.

#figure(
  canvas(length: 1cm, {
    import draw: *

    let arrow = (start, end) => line(start, end, mark: (end: ">", fill: black, scale: 0.6))

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

    arrow((0.25, ya + off), (mulx.at(0) - 0.3, mulx.at(1) + 0.15))
    arrow((0.25, yy + off), (mulx.at(0) - 0.3, mulx.at(1) - 0.05))
    arrow((mulx.at(0) + 0.3, mulx.at(1)), (addx.at(0) - 0.3, addx.at(1) + 0.1))
    arrow((0.25, yb + off), (addx.at(0) - 0.3, addx.at(1) - 0.15))
    arrow((addx.at(0) + 0.3, addx.at(1)), (rx.at(0) - 0.3, rx.at(1)))

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

    arrow((rx.at(0) - 0.3, rx.at(1)), (addx.at(0) + 0.3, addx.at(1)))
    arrow((addx.at(0) - 0.3, addx.at(1) + 0.1), (mulx.at(0) + 0.3, mulx.at(1)))
    arrow((addx.at(0) - 0.3, addx.at(1) - 0.15), (0.25, yb + off))
    arrow((mulx.at(0) - 0.3, mulx.at(1) - 0.05), (0.25, yy + off))
    line((mulx.at(0) - 0.3, mulx.at(1) + 0.15), (0.25, ya + off))

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

Le filtrage de prétraitement par IA est aujourd'hui une thématique bien présente dans la littérature. Pour autant, il reste difficile d'établir quelle méthode est la plus performante pour remplacer les outils de codage classiques durant l'apprentissage, et comment guider au mieux ce dernier. On peut regrouper les travaux existants autour de deux grandes familles de #gls("proxy", "proxy") : ceux qui reconstruisent une version simplifiée et différentiable d'un codec classique, et ceux qui entraînent un #gls("codec_neuronal", "codec neuronal") à imiter le comportement d'un codec cible. Nous présentons ici trois travaux représentatifs de ces deux approches.

*Neural Wrapping (CVPR 2025) — un codec neuronal comme #gls("proxy", "proxy")* @khan2025neural

Ce travail, mené par Sony, s'intéresse à du contenu de type jeu vidéo et à du streaming à des débits représentatifs de la diffusion 1080p. L'architecture combine un filtre de prétraitement et un filtre de post-traitement (un « neural wrapper ») encadrant le #gls("codec", "codec"). Ils utilisent des filtres légers, l'encodage lui-même utilisant au contraire des presets lents et de haute qualité, ce qui se rapproche des conditions que l'on souhaite tester pour ce projet.

Pour contourner la non-différentiabilité des codecs classiques, les auteurs n'essaient pas de reproduire les étapes du codec : ils entraînent un #gls("codec_neuronal", "codec neuronal") à l'imiter. Cet alignement se fait en deux phases. On aligne d'abord les images reconstruites par le proxy sur celles produites par le vrai codec, puis on apprend la distribution du débit avant de la recaler sur le débit réel mesuré. Pendant l'apprentissage de bout en bout, le proxy est réajusté à chaque itération, et une astuce de _stop-gradient_ — proche dans l'esprit du #gls("ste", "STE") — permet de transmettre au post-traitement les vraies images du codec tout en faisant circuler le gradient à travers le proxy neuronal.

L'intérêt principal est de repartir d'outils de codage neuronaux existants, réentraînables sur ses propres données, et d'obtenir une architecture relativement simple à appréhender. Malgré une différence de fonctionnement marquée avec un codec classique, les résultats montrent que l'approche reste cohérente une fois le filtre appliqué sur le vrai codec : les auteurs rapportent un gain moyen de l'ordre de #sym.minus 18,5 % de #gls("bdrate", "BD-rate") (le #gls("bdrate", "BD-rate") mesure l'économie moyenne de débit à qualité égale ; plus il est négatif, mieux c'est), et vérifient surtout que débit et distorsion du proxy et du codec cible se corrèlent fortement après l'alignement, condition nécessaire à un apprentissage par gradient.

*Limites.* La première limite tient au paradigme lui-même : les fonctions du codec (transformée, #gls("quantification", "quantification"), codage entropique) sont ici entièrement remplacées par des réseaux de neurones, qui réagissent différemment d'un vrai codec. On peut donc penser qu'un proxy plus proche du fonctionnement réel constituerait un meilleur simulateur pour l'apprentissage ; c'est précisément l'une des pistes explorées dans ce projet. Ensuite, réutiliser un codec neuronal existant contraint aux points de fonctionnement pour lesquels il a été conçu : entraîné à une qualité fixe, des variantes à débit variable apparaissent mais sont encore peu accessibles pour un réentraînement. De plus, l'alignement sur un nouveau codec cible reste coûteux ; les auteurs notent eux-mêmes un surcoût de calcul important pour l'alignement sur le VVC. Enfin, et c'est central pour notre projet, une grande partie des gains repose sur le post-traitement : leur étude d'ablation montre que le prétraitement seul dégrade même certaines #gls("metrique", "métriques") de fidélité (#gls("ssim", "SSIM"), MS-SSIM), et que seul l'entraînement conjoint du pré- et du post-traitement donne des gains cohérents sur l'ensemble des #gls("metrique", "métriques"). Or, un post-traitement côté client est difficile à déployer dans notre contexte (cf. les contraintes matérielles évoquées plus haut).
Un dernier point essentiel est leur choix de métriques durant l'apprentissage : ils utilisent une des composantes de #gls("vmaf", "VMAF"), ce qui facilite probablement les gains face à cette mesure.

*DPP (CVPR 2021) — un codec simplifié et différentiable* @chadha2021dpp

On retrouve ici du filtrage neuronal, mais uniquement en prétraitement : aucune composante n'est ajoutée côté décodeur, ce qui rend la méthode directement déployable. Pour remplacer le codec cible, les auteurs « virtualisent » les briques essentielles d'un codec hybride en versions différentiables : prédiction inter/intra, sélection du meilleur bloc, transformée fréquentielle (la #gls("dct", "DCT")) et #gls("quantification", "quantification"). Les opérations bloquantes pour l'apprentissage sont contournées par des approximations : un #gls("ste", "STE") pour l'argmin de la recherche de bloc, et un bruit uniforme additif pour remplacer l'arrondi de la quantification. Le gain moyen rapporté est d'environ 11 % sur plusieurs codecs (#gls("h264", "AVC"), #gls("av1", "AV1"), VVC).

*Limites.* L'implémentation paraît simple, mais cette simplicité vient surtout de la difficulté à reproduire fidèlement un codec complexe tout en gardant des fonctions dérivables et compatibles avec la mémoire des cartes graphiques (la recherche de blocs vectorisée est notamment coûteuse en mémoire). Par ailleurs, l'estimation du débit ne repose pas sur un calcul figé : elle s'appuie sur un modèle d'entropie *appris* (un prior factorisé sur des coefficients #gls("dct", "DCT") normalisés), ce qui réintroduit une composante apprise là où l'on cherchait justement à s'affranchir du « tout neuronal » et à reproduire la logique du codage théorique classique.

*Sandwiched Video Compression (Google, ICIP 2023) — codec simplifié avec encadrement pré/post* @isik2023sandwiched

Cette approche reprend l'idée du « sandwich » : un filtre de prétraitement et un filtre de post-traitement, très légers (de l'ordre de 100 000 paramètres, voire 57 000 pour la version allégée), encadrent un #gls("codec", "codec") standard, ici #gls("hevc", "H.265"). Le proxy de codec est, comme pour DPP, une version différentiable simplifiée : codage intra de type image (#gls("dct", "DCT") et quantification avec un estimateur de type _straight-through_, #gls("ste", "STE")), compensation de mouvement, sélection de mode inter/intra, codage du résidu, filtre de boucle, et une estimation de débit différentiable et simple. Cette approche obtient dans certains cas des gains aux alentours de 30 % de débit économisé sous la métrique perceptuelle #gls("lpips", "LPIPS").

*Limites.* L'évaluation porte sur #gls("hevc", "H.265") et sur des scénarios assez spécifiques, principalement avec le #gls("psnr", "PSNR") et #gls("lpips", "LPIPS"), ce qui rend la transposition directe à notre cas moins évidente. Et là encore, le post-traitement côté client pose les mêmes difficultés de déploiement. On peut d'ailleurs imaginer que les résultats sont en bonne partie dus à ce filtre en post-traitement, comme pour le premier papier présenté.


= Implémentation
== Objectif et difficultés

La mise en place d'un #gls("proxy", "proxy") fiable est la clé du projet : c'est lui qui permettra d'entraîner correctement le filtre et, plus tard, possiblement d'autres outils destinés à assister la compression. Tester différentes méthodologies de proxy était donc l'un des piliers du projet, et cela s'intègre naturellement dans le cadre d'un projet de fin d'études.

Comme évoqué dans la partie précédente, de nombreux travaux sont parvenus à dépasser les limites des codecs classiques pour entraîner un filtre. Mais la diversité des implémentations, des méthodes d'entraînement et d'évaluation rend difficile de savoir laquelle est la plus efficace dans notre cas précis : le filtre de prétraitement. À cela s'ajoute un obstacle pratique : ces travaux sont rarement accompagnés de leur code source, ce qui complique fortement leur ré-implémentation et, bien souvent, empêche d'en reproduire les résultats.

Il était donc indispensable de reprendre ces idées, de les adapter et d'en évaluer la pertinence, afin d'identifier les outils les plus adaptés à notre projet. Une contrainte nous était par ailleurs propre : notre cible était #gls("hevc", "H.265"), ce qui n'était pas forcément le cas des travaux cités.

Concrètement, notre implémentation poursuivait deux objectifs : reproduire un proxy par codage neuronal adapté à #gls("hevc", "H.265"), et réaliser une version simplifiée d'un #gls("codec", "codec") cherchant à se rapprocher de certains de ses choix.

== Architecture globale

Afin de comprendre les différents éléments nécessaires à l'apprentissage du filtre, voici un schéma qui explique la logique globale de l'apprentissage pour notre cas d'utilisation, une logique qui s'appliquera aux deux implémentations testées.

Dans ce schéma, le terme #gls("proxy", "proxy") est associé à la copie du codec pour simplifier la compréhension ; les scores liés aux #gls("metrique", "métriques") sont aussi remplacés par *résultat du filtre*, car dans cette boucle, les métriques nous servent de guide et définissent les résultats du filtre.


#figure(
  canvas(length: 1cm, {
    import draw: *
    let arrow = (s, e) => line(s, e, mark: (end: ">", fill: black, scale: 0.7))
    let cImg = rgb("#EEEDFE");  let cImgS = rgb("#534AB7")
    let cFilt = rgb("#F1EFE8"); let cFiltS = rgb("#5F5E5A")
    let cCod = rgb("#E6F1FB");  let cCodS = rgb("#185FA5")
    let cPrx = rgb("#E1F5EE");  let cPrxS = rgb("#0F6E56")
    let cRes = rgb("#FAEEDA");  let cResS = rgb("#BA7517")
    let cLoop = rgb("#D85A30")

    // ── ENTRÉE / IMAGES (pile de 3) ──
    rect((0.15, 3.35), (1.75, 4.55), fill: cImg.lighten(35%), stroke: 0.5pt + cImgS)
    rect((0.3, 3.55), (1.9, 4.75), fill: cImg.lighten(15%), stroke: 0.5pt + cImgS)
    rect((0.45, 3.75), (2.05, 4.95), fill: cImg, stroke: 0.6pt + cImgS)
    content((1.1, 5.55), text(size: 8pt, fill: cFiltS)[ENTRÉE])
    content((1.25, 2.9), text(size: 8.5pt, weight: "bold")[Images])

    // ── FILTRE ──
    arrow((2.25, 4.35), (3.4, 4.35))
    rect((3.5, 3.5), (5.4, 5.2), fill: cFilt, stroke: 0.7pt + cFiltS, radius: 3pt)
    content((4.45, 4.5), text(size: 9pt, weight: "bold")[Filtre])
    content((4.45, 4.05), text(size: 8pt)[(IA)])

    content((8.3, 7.7), text(size: 8pt, weight: "bold", fill: cFiltS)[RÉSULTATS DE COMPRESSION])

    // ── codec source (haut) ──
    arrow((5.55, 4.85), (7.0, 6.3))
    rect((7.0, 5.7), (9.6, 7.1), fill: cCod, stroke: 0.6pt + cCodS, radius: 3pt)
    content((8.3, 6.65), text(size: 8.5pt, weight: "bold", fill: cCodS)[Codec source])
    content((8.3, 6.15), text(size: 8pt)[(H.265)])

    // ── copie du codec (bas) ──
    arrow((5.55, 3.85), (7.0, 2.4))
    rect((7.0, 1.6), (9.6, 3.0), fill: cPrx, stroke: 0.6pt + cPrxS, radius: 3pt)
    content((8.3, 2.55), text(size: 8.5pt, weight: "bold", fill: cPrxS)[Copie du codec])
    content((8.3, 2.05), text(size: 8pt)[(simulateur)])

    // ── convergence vers le résultat ──
    arrow((9.7, 6.3), (11.4, 5.0))
    rect((11.5, 3.5), (13.9, 5.2), fill: cRes, stroke: 0.6pt + cResS, radius: 3pt)
    content((12.7, 4.55), text(size: 8pt, weight: "bold", fill: cResS)[Résultat du filtre])
    content((12.7, 4.05), text(size: 8pt)[(bonne qualité ?)])

    // ── boucle de correction ──
    bezier((12.6, 3.4), (4.45, 3.35), (11.5, -0.7), (5.5, -0.7),
      stroke: (paint: cLoop, thickness: 1.6pt),
      mark: (end: ">", fill: cLoop, scale: 0.9))
    content((8.5, 0.75), text(size: 8.5pt, weight: "bold", fill: cLoop)[Correction du filtre])
  }),
  caption: [Déroulement de la boucle d'apprentissage du filtre],
) <filtreGlobale>


Pour entrer plus en détail concernant l'architecture du filtre utilisée, nous avons fait le choix de reprendre une architecture simple liée à la partie pré-filtrage du papier @khan2025neural présenté plus tôt. Le détail des éléments composant ce filtre est disponible en @archi. Les détails de l'architecture étant fournis, cela facilite grandement l'implémentation. L'objectif ici est d'évaluer les solutions de proxy avec une architecture de filtre fonctionnelle ; cette architecture étant validée par les résultats fournis dans ces travaux, la reprendre simplifie l'étude de ce point. Dans une perspective future d'évolution visant des gains supplémentaires, cette architecture pourra largement évoluer.


== Proxy par codage neuronal

Cette première implémentation s'appuie sur la littérature récente et repose sur un #gls("codec_neuronal", "codec neuronal"). L'intérêt d'un tel outil est qu'il est, contrairement à #gls("hevc", "H.265"), entièrement différentiable : il peut donc prendre la place du #gls("codec", "codec") au cœur de la boucle d'apprentissage, à condition d'être au préalable amené à se comporter comme lui.

Pour comprendre la suite, on peut décrire un codec neuronal de façon simplifiée comme deux branches qui communiquent. La première encode puis décode l'information : elle transforme l'image en représentations abstraites, plus légères à transmettre, avant de reconstruire l'image à partir de ce qui a été reçu. La seconde estime le poids de cette information, c'est-à-dire en quelque sorte la complexité de l'image ; on retrouve ici un lien direct avec la théorie de l'information présentée en @th_info. Cette séparation est importante : c'est elle qui permettra d'aligner séparément la qualité et le débit sur le codec cible.

Ce fonctionnement a deux conséquences. D'abord, ces deux branches doivent être entraînées avec des objectifs différents : l'une sur la qualité de reconstruction, l'autre sur l'estimation du débit. Ensuite, et c'est le point le plus important, le codec encode à une qualité fixe : il n'existe pas de paramètre permettant de lui demander de compresser plus ou moins fortement, il code à la qualité qu'il a apprise. Si l'on veut couvrir plusieurs niveaux de qualité, il faut donc entraîner plusieurs modèles. Comme évoqué plus tôt, des approches récentes lèvent en partie cette limite en introduisant un débit variable, par exemple par modulation des caractéristiques @li2024dcvcfm, mais elles restent plus délicates à réentraîner pour notre cas d'usage, notamment car leur code source ne le permet pas.

Ces différents aspects se traduisent par plusieurs points de contrôle dans la construction de la pipeline d'entraînement. Il faut d'abord faire du codec neuronal un bon imitateur de notre codec cible, en deux temps : on l'entraîne d'abord à reproduire visuellement les images produites par #gls("hevc", "H.265") (avec ses défauts), puis on aligne son estimation de débit pour qu'il renvoie un coût proche de celui de #gls("hevc", "H.265"). Ce pré-entraînement en deux étapes est relativement coûteux.

Vient ensuite l'entraînement du filtre lui-même. Là, une difficulté apparaît : le filtre modifie les images, or le codec neuronal a appris à imiter #gls("hevc", "H.265") sur des images « normales ». Il risque donc de mal se comporter face à ces images modifiées, et de dériver. Pour limiter ce problème, nous avons retenu deux précautions. La première est de faire en sorte que le filtre se comporte au départ comme une fonction neutre, c'est-à-dire qu'il reproduise quasiment son image d'entrée : le codec n'est ainsi pas confronté d'emblée à des images trop différentes issues d'un modèle encore aléatoire. La seconde, reprise de la méthodologie de @khan2025neural, consiste à réaligner régulièrement le codec sur les images filtrées pour compenser cette dérive. Nous avons toutefois fait le choix de réaligner le codec à chaque epoch plutôt qu'à chaque itération, l'entraînement s'avérant plus stable de cette manière.

Reste la question de la qualité, puisque le codec encode à un niveau fixe. La logique du projet étant de se rapprocher des standards de la #gls("vod", "VOD"), nous avons choisi de travailler à un #gls("crf-qp", "CRF") (_Constant Rate Factor_) de 22, un bon compromis. À ce niveau, le filtre est entraîné sur une qualité élevée : il ne peut donc pas détruire massivement l'image, puisqu'il doit préserver cette qualité tout en réduisant le débit. On peut alors espérer que son comportement reste intéressant à plus basse qualité. Un entraînement à basse qualité aurait pu se justifier si la cible était explicitement les vidéos peu compressées, mais le filtre risquerait alors d'apprendre à sacrifier certains détails pour mieux préserver l'image globalement, un comportement qui ne serait probablement pas du tout apprécié à haute qualité.


== Proxy par codec simplifié

Afin de développer une méthode qui prend davantage en compte les réalités de la compression, nous avons fait le choix de créer une seconde version de proxy, cherchant cette fois à devenir un simulateur fidèle de #gls("hevc", "H.265"). La difficulté principale réside dans le fait que de nombreuses opérations complexes, optimisées pour s'exécuter rapidement sur des processeurs, doivent ici être transformées en simplifications à la fois différentiables et exécutables sur carte graphique. Cette dernière possède des propriétés très différentes du CPU, mais reste indispensable à l'entraînement par IA.

Comme nous l'avons vu en @limites_codec, les codecs comportent un grand nombre d'opérations inutilisables en l'état pour l'apprentissage, faute d'une pente exploitable. Cette implémentation repose donc sur un compromis : trouver des fonctions de remplacement qui restent fidèles à la logique des opérations principales du codec. Une telle version perd en fidélité, mais conserve l'essentiel, en restant dans le même paradigme que la cible #gls("hevc", "H.265"), là où un proxy purement neuronal s'en éloigne.

=== Sélection du meilleur bloc : du choix dur au mélange pondéré

La sélection du meilleur bloc candidat lors de la prédiction est l'une des opérations bloquantes identifiées précédemment, elle repose sur un argmin, un choix discret qui ne fournit aucun gradient exploitable (@nondiff). Les travaux existants comme @chadha2021dpp conservent cette opération mais la contournent par un #gls("ste", "STE"), forçant un gradient identité au retour. Cette approche fonctionne, mais elle laisse passer l'opération, elle ne porte alors d'information que sur le bloc effectivement choisi, ignorant les autres candidats.

Nous avons aussi retenu une autre approche : plutôt que de sélectionner un unique bloc, nous calculons une combinaison pondérée de l'ensemble des candidats. Chaque candidat reçoit un poids d'autant plus fort que son erreur de correspondance est faible. Concrètement, la prédiction finale mélange visuellement plusieurs blocs selon leur pertinence. L'intérêt est que le gradient circule à travers tous les candidats, et non plus seulement le gagnant.

#figure(
  canvas(length: 1cm, {
    import draw: *
    let arrow = (s, e) => line(s, e, mark: (end: ">", fill: black, scale: 0.55))

    // --- Approche STE (argmin) ---
    content((-0.3, 3.6), text(weight: "bold", size: 9pt)[(a) Argmin classique])
    let cand = ((0, 2.6, "C1", gray), (0, 1.8, "C2", red), (0, 1.0, "C3", gray), (0, 0.2, "C4", gray))
    for (x, y, lbl, col) in cand {
      rect((x, y - 0.22), (x + 0.7, y + 0.22), stroke: 0.6pt + col, radius: 1pt)
      content((x + 0.35, y), text(size: 7pt, fill: col)[#lbl])
    }
    content((1.9, 1.4), text(size: 11pt, weight: "bold")[argmin])
    rect((3.1, 1.18), (3.8, 1.62), stroke: 1pt + red, radius: 1pt)
    content((3.45, 1.4), text(size: 7pt, fill: red)[C2])
    arrow((0.75, 1.8), (1.3, 1.4))
    arrow((2.45, 1.4), (3.05, 1.4))
    content((3.45, 0.6), text(size: 6.5pt, fill: black)[1 seul bloc])
    content((3.45, 0.2), text(size: 6.5pt)[gradient via C2])

    // --- Approche soft-matching ---
    content((5.7, 3.6), text(weight: "bold", size: 9pt)[(b) Mélange pondéré])
    let cand2 = ((6, 2.6, "C1", 0.15), (6, 1.8, "C2", 0.55), (6, 1.0, "C3", 0.22), (6, 0.2, "C4", 0.08))
    for (x, y, lbl, w) in cand2 {
      rect((x, y - 0.22), (x + 0.7, y + 0.22), stroke: 0.6pt + blue, radius: 1pt)
      content((x + 0.35, y), text(size: 7pt)[#lbl])
      content((x + 1.5, y), text(size: 6.5pt, fill: blue)[#w])
      arrow((x + 0.75, y), (8.9, (1.2 + (y * 0.1))))
    }
    rect((9.0, 1.1), (10.5, 1.7), stroke: 1pt + blue, radius: 1pt)
    content((9.75, 1.4), text(size: 6.5pt, fill: blue)[Σ pondérée])
    content((9.75, 0.6), text(size: 6.5pt, fill: black)[gradient via])
    content((9.75, 0.25), text(size: 6.5pt, fill: black)[tous les candidats])
  }),
  caption: [Deux façons de gérer la sélection de bloc non différentiable. À gauche, le #gls("ste", "STE") garde le choix dur (argmin) et ne propage le gradient que par le bloc gagnant. À droite, notre approche par mélange pondéré (softmax) combine tous les candidats selon leur pertinence, laissant le gradient circuler à travers chacun.],
) <softmatch>

=== Zone de recherche et prédiction

Pour rester exécutable sur carte graphique malgré le coût des recherches de blocs, @chadha2021dpp propose une méthodologie reproduisant la complexité des opérations de prédictions pour les images clés, tout en respectant les contraintes mémoire. Nous reprenons alors une logique de la prédiction inter (@intermotion), mais en l'appliquant aussi au cas d'une seule image, la zone de recherche y est restreinte à ce qui est théoriquement déjà connu dans l'image en cours de décodage, c'est-à-dire la partie située au-dessus du bloc courant et à sa gauche (@zonecausale). Cette contrainte causale est essentielle, un décodeur ne dispose jamais des blocs « futurs », et l'ignorer reviendrait à entraîner le filtre sur une information indisponible à la reconstruction réelle. Cette méthode permet alors de reproduire des transformations complexes pour un coût minime ; il serait presque impossible de réaliser des opérations classiques de manière conditionnelle à l'instar d'un vrai codec, cette méthode semble donc être un bon compromis entre faisabilité et respect de la complexité des méthodes d'origine.

#figure(
  canvas(length: 0.62cm, {
    import draw: *
    let n = 7
    // grille
    for i in range(n + 1) {
      line((0, i), (n, i), stroke: 0.4pt + gray)
      line((i, 0), (i, n), stroke: 0.4pt + gray)
    }
    let cx = 3
    let cy = 3
    // zone connue
    for row in range(n) {
      for col in range(n) {
        let known = (row > cy) or (row == cy and col < cx)
        if known {
          rect((col, row), (col + 1, row + 1), fill: rgb(180, 210, 240), stroke: none)
        }
      }
    }
    // bloc courant
    rect((cx, cy), (cx + 1, cy + 1), fill: rgb(220, 90, 90), stroke: 0.8pt + black)
    content((cx + 0.5, cy + 0.5), text(size: 6.5pt, fill: white, weight: "bold")[?])
    // légende
    rect((n + 0.6, 5.2), (n + 1.3, 5.9), fill: rgb(180, 210, 240), stroke: none)
    content((n + 3.8, 5.55), text(size: 8pt)[zone connue (recherche)])
    rect((n + 0.6, 4.0), (n + 1.3, 4.7), fill: rgb(220, 90, 90), stroke: 0.6pt + black)
    content((n + 2.9, 4.35), text(size: 8pt)[bloc à prédire])
    rect((n + 0.6, 2.8), (n + 1.3, 3.5), fill: white, stroke: 0.4pt + gray)
    content((n + 4.5, 3.15), text(size: 8pt)[zone non décodée (non connue)])
  }),
  caption: [Zone de recherche causale pour la prédiction d'un bloc. Seule l'information déjà décodée (au-dessus et à gauche) est disponible.],
) <zonecausale>

=== Quantification et transformée

Une autre étape clé identifiée précédemment est la #gls("quantification", "quantification"), dont l'arrondi supprime de l'information et présente un gradient nul presque partout (@nondiff). Plusieurs options existent pour la rendre apprenable : remplacer la fonction pour l'apprentissage des poids par une alternative d'arrondi modifiée et optimisable en gardant la fonction de base pour le reste des opérations.

#figure(
  canvas(length: 1cm, {
    import draw: *
    let arrow = (start, end) => line(start, end, mark: (end: ">", fill: black, scale: 0.6))

    // axes
    arrow((0, 0), (4.4, 0))
    arrow((0, 0), (0, 4.2))
    content((4.5, 0), $x$, anchor: "west")
    content((0, 4.5), $Q(x)$)

    // arrondi dur : escalier (pointillés gris), marches en 0.5 / 1.5 / 2.5
    line((0, 0), (0.5, 0), (0.5, 1), (1.5, 1), (1.5, 2), (2.5, 2), (2.5, 3), (3.5, 3),
      stroke: (paint: gray, thickness: 1pt, dash: "dashed"))

    // arrondi adouci : somme de transitions tanh centrées sur les mêmes marches
    let beta = 6.0
    let sr = x => (
      0.5 * (1 + calc.tanh(beta * (x - 0.5)))
        + 0.5 * (1 + calc.tanh(beta * (x - 1.5)))
        + 0.5 * (1 + calc.tanh(beta * (x - 2.5)))
    )
    let pts = range(0, 36).map(i => {
      let x = i / 10.0
      (x, sr(x))
    })
    line(..pts, stroke: (paint: rgb("#534AB7"), thickness: 1.5pt))

    // annotation : pente exploitable
    arrow((3.0, 3.9), (1.84, 1.98))
    content((3.05, 4.05), text(size: 8pt)[pente exploitable])

    // annotation : palier plat (pente nulle)
    arrow((1.55, 0.45), (0.6, 0.98))
    content((1.9, 0.35), text(size: 8pt)[palier plat (pente nulle)])
  }),
  caption: [Arrondi dur (escalier, en pointillés) et sa version adoucie continue (_soft round_).],
) <softround>

L'arrondi réel a un gradient nul presque partout, la version adoucie suit les mêmes marches tout en gardant une legère pente, ce qui rend cette fonction optimisable.


L'autre option est de simuler la perte causée par cet arrondi par une alternative différente, par l'ajout d'un bruit aléatoire, comme dans les travaux de @chadha2021dpp. L'idée est de remplacer l'arrondi dur, non différentiable, par une perturbation dont l'effet s'en approche, tout en étant une fonction optimisable.



Concernant la transformation de l'image, les calculs reposent sur des matrices de #gls("dct", "DCT") permettant un traitement rapide. Notre cible étant #gls("hevc", "H.265"), nous avons veillé à employer les matrices effectivement utilisées par ce codec, et non les matrices théoriques de la #gls("dct", "DCT"). C'est une différence notable avec les différents projets, des travaux comme @chadha2021dpp visaient une optimisation plus générale, sans s'aligner sur un codec précis, là où notre objectif est explicitement de coller au mieux au comportement de #gls("hevc", "H.265").

Enfin, nous avons fait le choix de travailler sur des blocs de taille 8×8. Une évolution future pourra consister à introduire des tailles de blocs variables, comme le fait un codec réel, puis à en valider l'utilité dans notre cas d'usage.

=== Essais et échec d'implémentation
Durant le projet de nombreux tests ont été réalisés, beaucoup n'ont pas permis d'aboutir à une solution fiable mais ce sont aussi ces tests qui ont permis de continuer à rentrer plus en détail dans le sujet. Il existe un grand nombre de possibilités et établir les meilleures options est un problème complexe qui demande aussi une connaissance dans le domaine très poussée. Parfois certaines tentatives sont aussi des pertes de temps sèches, j'ai fini par les éviter le plus possible en me fixant des limites et en repartant parfois de choses plus simples mais établies afin de ne pas me perdre dans des solutions inutiles.

Il est important aussi de préciser que certaines tests n'ont pas réellement été des echecs mais la temporalité lié au projet de fin d'études limite le champs d'action, certaines idées ou améliorations prendront alors place pour le futur du porjet selon leur pertinance.

=== Bilan de l'implémentation

Cette implémentation s'est révélée particulièrement intéressante pour tester différents mécanismes. Durant son développement, plusieurs essais rapides n'ont apporté aucune amélioration nette, voire ont entraîné de fortes pertes, ce qui a permis de converger vers les choix présentés ci-dessus. L'objectif étant précisément de définir les bonnes pratiques d'un tel outil, des études comparant ces différentes méthodes sont présentées en @resultats.


== Méthode d'évaluation

La méthode d'évaluation est un point essentiel du projet. Nous l'avons vu en @contenteval, il existe de nombreux outils prévus pour évaluer la qualité vidéo. L'objectif pour nous est de définir les meilleurs outils pour refléter l'avis d'un utilisateur.

Dans notre cellule de nombreuses analyses ont été réalisées sur les #gls("metrique", "métriques") afin d'estimer quels outils pourraient être les plus pertinents pour ce projet. Nous verrons dans cette section un bref résumé qui expliquera alors les choix réalisés.

On compare donc plusieurs #gls("metrique", "métriques") selon leur accord avec le jugement d'utilisateurs (le score #gls("mos", "MOS")). Plus le score (corrélation de Spearman) est proche de 1, plus la métrique classe les vidéos comme le ferait un observateur humain. On teste cet accord dans deux situations : quand le contenu varie peu dans l'image (faible variabilité) et quand il varie beaucoup (forte variabilité).

Pour comprendre les résultats il est aussi important de présenter les différentes métriques.

#gls("vmaf", "VMAF") (Video Multi-Method Assessment Fusion) est une métrique que nous avons déjà évoquée, elle possède aussi une version durcie, VMAF-NEG, qui pénalise un rehaussement du contraste ; elle est reconnue pour être plus robuste à certaines conditions grâce à des limites que la version classique n'a pas.
UVQ (Universal Video Quality) est une métrique plus récente, basée sur l'IA, qui a appris à partir de scores #gls("mos", "MOS"). Delta UVQ est une variante d'UVQ qui prend en compte les différences entre l'image originale et l'image compressée, car cette mesure est _No-Reference_, ce qui peut parfois causer des écarts en fonction de l'image originale. #gls("lpips", "LPIPS") (Learned Perceptual Image Patch Similarity) est une métrique basée sur un réseau de neurones entraîné pour prédire la similarité perceptuelle entre deux images. CVVDP (Color Video Visual Difference Predictor) est une métrique qui modélise la perception humaine des différences de couleur et de luminance.

Les tableaux ci-dessous ne montrent que les métriques retenues comme candidates, les autres, moins pertinentes pour notre usage, ont été écartées pour la clarté.

Les deux tests suivants sont ciblés. Le premier jeu de données est basé sur des vidéos qui ont été encodées avec différentes versions du codec #gls("hevc", "H.265"), qui est notre cible d'optimisation, et des variations de qualité. Avoir une métrique qui réagit de manière pertinente face aux vidéos qui sortent de ces différentes versions est un bon indicateur de sa pertinence pour notre projet.
Le second jeu de données est basé sur des vidéos encodées avec un encodage par régions d'intérêt (ROI), c'est-à-dire que certaines zones de l'image sont encodées avec plus de qualité que d'autres, ce qui est un cas proche d'un filtrage IA. Avoir une métrique qui réagit de manière pertinente face à ces vidéos est aussi un bon indicateur de sa pertinence pour notre projet.

#figure(
  caption: [Accord avec la référence sur différents encodages #gls("hevc", "H.265"). ↑ : plus haut = meilleur.],
  table(
    columns: (auto, 1fr, 1fr),
    align: (left, center, center),
    stroke: 0.5pt + rgb("#888"),
    inset: 6pt,
    table.header([*Métrique*], [*Faible variabilité* ↑], [*Forte variabilité* ↑]),
    [*VMAF*], [0.926], [0.737],
    [*VMAF-NEG*], [0.928], [0.721],
    [*UVQ*], [0.756], [*0.824*],
    [*Delta UVQ*], [*0.937*], [0.722],
    [*LPIPS*], [0.786], [0.520],
    [*CVVDP*], [0.782], [0.451],
  ),
)

#figure(
  caption: [Accord avec la référence sur un encodage par régions d'intérêt (ROI), un cas proche d'un filtrage IA. ↑ : plus haut = meilleur.],
  table(
    columns: (auto, 1fr, 1fr),
    align: (left, center, center),
    stroke: 0.5pt + rgb("#888"),
    inset: 6pt,
    table.header([*Métrique*], [*Faible variabilité* ↑], [*Forte variabilité* ↑]),
    [*VMAF*], [0.899], [0.808],
    [*VMAF-NEG*], [0.803], [0.702],
    [*UVQ*], [0.803], [0.754],
    [*Delta UVQ*], [0.904], [0.850],
    [*LPIPS*], [0.881], [*0.880*],
    [*CVVDP*], [*0.905*], [0.784],
  ),
)


#strong[#gls("vmaf", "VMAF") et UVQ (ou sa variante Delta UVQ)] sont les valeurs sûres. Elles restent bien classées dans presque toutes les situations : VMAF est solide un peu partout, et UVQ / Delta UVQ arrive souvent en tête, y compris quand le contenu varie beaucoup (0.824 sur le premier jeu, 0.850 sur le second). Ce sont donc des candidats fiables et polyvalents pour évaluer notre filtre. Elles sont d'ailleurs reconnues dans la littérature pour leur fiabilité, et sont utilisées dans de nombreux travaux et aussi par l'industrie.

#strong[#gls("lpips", "LPIPS")] devient intéressante dans notre cas précis. Le second jeu de données repose sur un encodage par régions d'intérêt, c'est-à-dire un codage qui concentre ses efforts sur les zones importantes de l'image, exactement le genre de comportement qu'un filtre IA cherche à produire. Or c'est justement là que LPIPS obtient ses meilleurs scores (0.881 et 0.880, la meilleure métrique en forte variabilité). Comme ce cas d'usage ressemble au nôtre, LPIPS mérite d'être considérée, alors qu'elle était moins convaincante sur l'encodage classique.

#strong[CVVDP] est un candidat valable par sa conception. Contrairement aux autres, elle est construite directement sur un modèle de la vision humaine (la façon dont l'œil perçoit les contrastes et les couleurs). Cette base théorique en fait un choix légitime, et elle se classe d'ailleurs en tête sur l'encodage par régions d'intérêt à faible variabilité (0.905).

En résumé, #gls("vmaf", "VMAF") et UVQ / Delta UVQ s'imposent comme les métriques principales, tandis que LPIPS et CVVDP pourraient apporter des informations complémentaires.

Nous le voyons ici : aucune métrique n'est parfaite face à la perception humaine, il est donc important de croiser les résultats pour avoir une idée plus précise de la qualité des images reconstruites. On peut cependant évoquer la limite de ces métriques pour notre cas d'utilisation, des images modifiées par IA, où il est difficile pour le moment d'assurer la fiabilité des résultats obtenus. Ce qui mènera ce projet vers des tests face à de vrais utilisateurs dans le futur.


== Guide d'optimisation
// TODO Rajouter une xeplication sur des tests qui on montré des gains mais qui ne modifiait aps l'iamge et qu'il était fort probable que ces gains venaient majoritairement d'une faille exploitée par le réseau de neuronnes.


Nous l'avons vu, le guide d'apprentissage doit satisfaire deux exigences à la fois : être un bon simulateur de ce que percevrait un utilisateur, et rester facilement optimisable pour que les poids du filtre soient ajustés dans la bonne direction.

De nombreuses combinaisons de #gls("metrique", "métriques") sont possibles, mais toutes ne peuvent pas être testées. Or, l'objectif de ce projet porte avant tout sur les différentes approches de remplacement du #gls("codec", "codec") durant l'apprentissage, et non sur la recherche du guide idéal. Il paraît donc justifié de retenir un choix simple et cohérent, respectant nos critères de départ, quitte à approfondir cet aspect dans la suite du projet. À cela s'ajoute une précaution méthodologique, nous l'avons évoqué dans les limites des travaux existants, certains projet entraînent le filtre sur une métrique puis évaluent les performances sur cette même métrique, ce qui fausse probablement l'analyse. Nous chercherons donc à dissocier le guide d'apprentissage des outils servant à l'évaluation finale.

Le guide retenu cherche un compromis entre simplicité et fidélité à la perception humaine. Il associe deux composantes : une perte L1 et la métrique #gls("dists", "DISTS").

La perte L1 est une fonction simple, orientée fidélité : elle mesure l'écart direct entre l'image filtrée et l'image source, dans le même esprit que le #gls("psnr", "PSNR") évoqué plus tôt, peu précis perceptuellement mais facile à optimiser. Elle joue ici le rôle de garde-fou, en empêchant le filtre de trop s'éloigner de l'image d'origine.

#gls("dists", "DISTS") apporte la dimension perceptuelle. Il s'appuie sur un réseau de neurones et est calibré sur des jugements humains de similarité. Entraîné à partir de paires d'images, il est théoriquement capable de savoir si une texture différente au niveau des pixels est acceptable pour un utilisateur. C'est ce qui rend #gls("dists", "DISTS") pertinent ici : sa tolérance aux textures, par conception, lui permet de considérer comme similaires deux textures différentes d'une même zone tant qu'elles restent acceptables pour l'œil. Autrement dit, il laisse au filtre la liberté de modifier l'image au niveau du détail, sans le pénaliser tant que la satisfaction de l'utilisateur n'est pas affectée. C'est exactement le type de souplesse que l'on recherche pour réduire le débit sans dégrader la qualité perçue.

L1 et #gls("dists", "DISTS") sont donc complémentaires : la première ancre le résultat sur la source et évite les dérives, la seconde guide les modifications dans une direction compatible avec la perception humaine.

== Données d'entrainement

Pour entraîner un réseau de neurones, les données utilisées sont un point clé : il faut disposer d'un grand nombre d'exemples, mais aussi d'exemples de bonne qualité. Il existe assez peu de jeux de données qui répondent à ces exigences tout en étant accessibles publiquement. Nous avons fait le choix de reprendre un dataset utilisé dans de nombreux projets liant l'image et le deep learning, notamment pour les travaux de @khan2025neural : le dataset Vimeo90K, qui possède un grand nombre d'images (environ 90 000). La qualité des images étant variable, on peut toutefois considérer ce point comme un défaut pour notre cas d'usage, qui vise des vidéos de bonne qualité pour de la diffusion VOD.

== Limites et perspectives

Une première limite tient au jeu de données. Nous avons repris celui du papier
@khan2025neural, ce qui présentait l'avantage de s'appuyer sur une base déjà
éprouvée pour ce type de travaux. Une évolution possible consisterait à passer à
un jeu de données comme BVI-DVC comportant moins d'images, mais composé d'images de
meilleure qualité et plus récentes. Un tel changement pourrait améliorer la
pertinence de l'apprentissage, et fait partie des pistes envisagées pour la
suite du projet.

La seconde limite concerne le guide d'apprentissage. Le choix retenu ici est
volontairement simple, et il gagnera à être optimisé pour obtenir des résultats
plus nets. Ce point n'est pas un oubli mais une étape à part entière du projet :
l'objectif de ce PFE portait avant tout sur les approches de remplacement du
codec, et l'affinement du guide constitue un travail ultérieur, que les outils
mis en place ici rendront justement possible.


= Résultats et analyses <resultats>

== En tant que #gls("proxy", "Proxy")
Cette section a pour but d'évaluer les performances de ces différentes méthodes en tant que copie de ce que fait réellement #gls("hevc", "H.265"), le but est donc d'évaluer la pertinence des images sorties par ces outils, mais aussi d'évaluer si elles sont capables d'ordonner de manière précise les différents contenus au niveau du débit et donc du coût réel des différentes vidéos.

Cette première évaluation permet aussi de mettre en avant les différentes approches pour la version du proxy simplifié, et voir et comprendre les mécanismes qui vont jouer ou non sur la qualité de reconstruction. Ce qui permettra de réaliser des choix plus pertinents pour la suite du projet.

Les deux méthodes étant différentes, cette évaluation se fera donc sur un point de qualité qui peut être atteignable par les différentes options.
Pour rappel, le proxy neuronal est entraîné à reproduire une qualité fixe (#gls("crf-qp", "CRF") 22 dans notre cas), pour le comparer avec la seconde approche il faut alors se placer à QP 22, ce qui va légèrement différer mais permet tout de même de voir à quel point ces outils sont pertinents ou non ; pour en valider les résultats, nous verrons aussi les résultats à CRF 22.

Ces tests seront réalisés sur des vidéos du dataset MCL-JCV, qui est un dataset de référence pour l'évaluation de la compression vidéo. L'objectif est de ne pas utiliser des vidéos similaires à celles qui ont permis d'entraîner le proxy neuronal, afin de ne pas biaiser les résultats. Le dataset MCL-JCV est composé de 30 vidéos HD, ce qui suffit pour obtenir des résultats fiables, mais pas trop pour ne pas alourdir les calculs. Il est aussi intéressant de noter que ce dataset est composé de vidéos très différentes, ce qui permet d'avoir une idée plus précise de la pertinence des outils sur différents types de contenus.


== Fidélité de reconstruction

Pour évaluer la fidélité de structure des images, nous l'avons vu, le #gls("psnr", "PSNR") reste une métrique simple, peu fiable pour la perception humaine mais qui reste un bon indicateur de la fidélité de reconstruction. Le #gls("ssim", "SSIM") est lui plus précis et plus proche de la perception humaine, il est donc intéressant de le croiser avec le PSNR pour avoir une idée plus précise de la qualité des images reconstruites. De plus durant l'entraînement du proxy neuronal, la métrique MSE (Mean Squared Error) est utilisée pour guider l'apprentissage, cette métrique est directement liée au PSNR, il est donc logique de la croiser avec le SSIM pour avoir une idée plus précise de la qualité des images reconstruites sans biais.

#let hi = rgb("#e8f0fb")

#figure(
  caption: [Fidélité proxy vs x265, mode CRF. ↑ : plus haut = meilleur.],
  table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr),
    align: (left, center, center, center, center),
    stroke: 0.5pt + rgb("#888"),
    inset: 6pt,
    table.header([], [*PSNR intra* ↑], [*SSIM intra* ↑], [*PSNR inter* ↑], [*SSIM inter* ↑]),
    [*round · softmax*], [*40.41*], [0.9574], [39.52], [0.9507],
    [*round · argmin*], [39.43], [0.9453], [38.35], [0.9319],
    [*noise · softmax*], [37.82], [0.9184], [37.22], [0.9110],
    [*noise · argmin*], [37.83], [0.9184], [37.22], [0.9110],
    [*neuronal*], [36.85], [*0.9769*], [*40.68*], [*0.9805*],
  ),
)

#figure(
  caption: [Fidélité proxy vs x265, mode QP constant. ↑ : plus haut = meilleur.],
  table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr),
    align: (left, center, center, center, center),
    stroke: 0.5pt + rgb("#888"),
    inset: 6pt,
    table.header([], [*PSNR intra* ↑], [*SSIM intra* ↑], [*PSNR inter* ↑], [*SSIM inter* ↑]),
    [*round · softmax*], [*42.70*], [0.9738], [*41.57*], [0.9664],
    [*round · argmin*], [41.41], [0.9627], [40.00], [0.9480],
    [*noise · softmax*], [39.40], [0.9363], [38.66], [0.9272],
    [*noise · argmin*], [39.40], [0.9363], [38.66], [0.9272],
    [*neuronal*], [36.97], [*0.9756*], [41.17], [*0.9817*],
  ),
)

Le proxy neuronal reconstruit les images les plus ressemblantes, en particulier sur les images prédites à partir des précédentes (colonnes _inter_), où il devance nettement toutes les autres versions. Ce réseau a été entraîné pour copier le vrai codec, donc il excelle à cette tâche. Il est tout de même intéressant de voir que les scores PSNR ne sont pas toujours bons alors que le SSIM si, ce qui signifie en simplifiant qu'il ne reproduit pas fidèlement les pixels mais conserve la structure de l'image, ce qui est finalement le but recherché. Le proxy neuronal est donc un bon imitateur du codec, en particulier au niveau structurel.

Parmi nos versions simplifiées, la variante `round · softmax` est la plus proche du vrai codec, les autres réglages s'en éloignent un peu. Le softmax est la fonction que nous avions présentée, elle permet de mélanger les candidats de prédiction plutôt que d'en choisir un seul. Cela a pour effet de lisser légèrement le résultat, ce qui est apprécié par le PSNR notamment, ce qui explique ces résultats. On peut tout de même valider la pertinence du proxy simplifié, car lui n'a pas appris à reproduire fidèlement les images. Il est intéressant de noter que ces performances sont obtenues à cette qualité qui est haute mais devient moins bonne si l'on choisit de traiter des images de plus basse qualité, car le proxy simplifié ne reprend pas toutes les logiques d'optimisations complexes du véritable codec, des optimisations qui vont être bénéfiques surtout sur des images de plus basse qualité. Notre simulateur fonctionne donc très bien à haute qualité, moins à basse qualité.


// TODO : mettre un exemple visuel des vidéos en CRF 22, mais aussi un exemple d'une image à basse qualité du codec pour le proxy simplifié

Ce constat nous a donc obligé à utiliser cet outil avec plus de précaution et rester dans une plage limité de qualité afin d'éviter de s'éloigner trop de l'outil d'origine.

== Corrélation de débit

Pour estimer si nos outils sont de bons simulateurs, il est aussi important de voir s'ils sont capables de prédire dans la même direction que le vrai codec, c'est-à-dire si les vidéos qui sont plus lourdes pour le vrai codec sont aussi plus lourdes pour nos outils. Pour cela nous avons utilisé la corrélation de Spearman, qui est une mesure statistique permettant de mesurer la force et la direction entre deux variables. Cette mesure est adaptée à notre cas car elle ne se base pas sur les valeurs absolues mais sur l'ordre des valeurs, ce qui est exactement ce que nous voulons savoir : si les vidéos sont ordonnées de la même manière par nos outils et par le vrai codec. 

#figure(
  caption: [Corrélation débit estimé vs H.265 (Spearman), mode CRF. ↑ : plus haut = meilleur.],
  table(
    columns: (auto, 1fr, 1fr),
    align: (left, center, center),
    stroke: 0.5pt + rgb("#888"),
    inset: 6pt,
    table.header([], [*classement clips \ (intra)* ↑], [*classement clips \ (inter)* ↑]),
    [*arrondi · softmax*], [*0.93*], [0.67],
    [*arrondi · argmin*], [0.91], [0.86],
    [*bruit · softmax*], [*0.93*], [0.67],
    [*bruit · argmin*], [0.91], [*0.88*],
    [*neuronal*], [0.87], [0.85],
  ),
)

#figure(
  caption: [Corrélation débit estimé vs H.265 (Spearman), mode QP constant. ↑ : plus haut = meilleur.],
  table(
    columns: (auto, 1fr, 1fr),
    align: (left, center, center),
    stroke: 0.5pt + rgb("#888"),
    inset: 6pt,
    table.header([], [*classement clips \ (intra)* ↑], [*classement clips \ (inter)* ↑]),
    [*arrondi · softmax*], [*0.98*], [0.72],
    [*arrondi · argmin*], [*0.98*], [*0.92*],
    [*bruit · softmax*], [*0.98*], [0.72],
    [*bruit · argmin*], [*0.98*], [*0.92*],
    [*neuronal*], [0.93], [0.91],
  ),
)

Ici, la version simplifiée qui faisait les plus belles images (`softmax`) n'est _pas_ la meilleure pour juger du poids des fichiers. C'est le réglage plus proche du fonctionnement réel d'un codec (`argmin`) qui devine le mieux quelles vidéos seront lourdes ou légères, et il fait ici aussi bien que le proxy neuronal. En clair, faire une belle image et bien estimer le poids d'un fichier sont deux qualités différentes, et aucune version simplifiée ne gagne sur les deux tableaux à la fois, c'est justement la force du proxy neuronal, qui réussit bien dans les deux cas.


== Synthèse : deux profils, deux usages

Comme simple imitateur du vrai codec, le proxy neuronal semble le meilleur : il réalise les images les plus ressemblantes et estime bien le poids des fichiers. Rien d'étonnant, puisqu'il a été entraîné pour ça. Son inconvénient : il ne fonctionne qu'à un seul niveau de qualité, celui sur lequel il a été entraîné. On peut aussi prédire que son comportement plus éloigné du paradigme de la compression vidéo classique pourrait le rendre moins efficace si on l'utilise pour guider l'apprentissage d'un filtre.

Notre proxy simplifié, lui, fonctionne comme un vrai codec : il découpe l'image en blocs et les compresse à la manière de #gls("hevc", "H.265"). Cette proximité lui donne de vrais atouts. Il estime le poids des fichiers presque aussi bien que le proxy neuronal, il reste compréhensible, et surtout il s'adapte à tous les niveaux de qualité, même s'il devient moins fidèle quand on descend en basse qualité, là où le proxy neuronal est bloqué sur un seul niveau. Ces points en font donc un bon candidat pour guider l'apprentissage d'un filtre.

De par notre implémentation présenté dans @filtreGlobale, les deux proxy possèdent une architecture commune qui prend la version de H265 en évaluation de la qualité d'image, et va cependant calculer les poids sur le proxy, ce qui a aussi été expliqué dans le papier @khan2025neural, cela permet notament d'éviter de travailler sur un domaine trop éloigné de la cible, les iamges évaluées sortent alors du vrai codec. Cela signifie donc que la fidélité d'image importe moins directement notre architecture et au niveau de comment le réseau va apprendre les options seront similaire, c'est le but de cette conception. Le point essentiel se trouve donc plutôt dans l'estimation de débit. Pour le proxy simplifié, les meilleurs scores sont obtenus avec la version "ste-argmin", qui est la version où l'estimation de débit reçoit bien le choix d'un bloc unique et pas un mélange de blocs mais va bien apprendre sur ce mélange de blocs. Pour la suite fort de ce constat nous testerons alors uniquement le paramètres concernant la modification de l'arrondi, c'est à dire le choix entre produire un bruit aléatoire pour simuler la quantification ou réaliser cette quantifiaction et ne pas apprendre sur cette étape. Deux paramètres notés ici "arrondi" et "bruit".


== Résultats face aux #gls("metrique", "métriques")


#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 0.5cm,
    image("images/rd_UVQ_MEAN_N.png"), image("images/rd_VMAF_MEAN_N.png"), 
    grid.cell(colspan: 2)[
      #align(center)[#image("images/rd_VMAF_NEG_MEAN_N.png", width:50%)]
    ]
  ),
  caption: [Résultats Optimisation filtre avec proxy neuronal],
)

Ces résultats montrent que le proxy neuronal optimise bien le filtre, les scores VMAF et VMAF-NEG sont assez parlant et montrent un gain assez net (2.5 points VMAF par exemple pour le premier point en basse qualité). Cependant on remarque une contradiction la métrique UVQ semble ne pas apprécier les modifications du filtre, ce qui est un point à creuser pour comprendre pourquoi cette métrique ne réagit pas comme les autres, elle reste tout de même inchangé à basse qualité.

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 0.5cm,
    image("images/rd_UVQ_MEAN_S1.png"), 
    image("images/rd_VMAF_MEAN_S1.png"),
    grid.cell(colspan: 2)[
      #align(center)[#image("images/rd_VMAF_NEG_MEAN_S1.png", width: 50%)]
    ]
  ),
  caption: [Résultats Optimisation filtre avec proxy simplifié version "arrondi"],
)

Ces résultats montrent que le proxy simplifié optimise très peu au vu de ce contenu, les différences restent dans les marges d'erreurs des métriques on ne pas pas spécifier de gain mais un accord semble tout de même exister à basse qualité où les trois métriques s'accordent sur un possible gain minime du filtre.

#figure(
  grid(
    columns: (1fr, 1fr),
    gutter: 0.5cm,
    image("images/rd_UVQ_MEAN_Noise.png"),
    image("images/rd_VMAF_MEAN_Noise.png"),
    grid.cell(colspan: 2)[
      #align(center)[#image("images/rd_VMAF_NEG_MEAN_Noise.png", width: 50%)]
    ],
  ),
  caption: [Résultats optimisation filtre avec proxy simplifié version « bruit »],
)

Cette version n'a pas donné de résultats intérressant, il est possible au vu de ces métriques et le coût d'image évolue mais n'apporte pas de bénéfice face à un encode classique. On voit cependant qu'à absse qualité le point gardant un coût (bpp) similaire est au dessus sur toutes les mesures, ce qui pourrait définir que cette méthode permet aussi un gain minime à basse qualité.

== Test visuel
Afin d'avoir une idée des effets du filtre sur les images voici quelques exemples où l'ont voir de différences intérressantes à analyser. Ces iamges proviennent bien sûr des iamges de test et pas celles utilisées durant l'apprentissage.
Il est possible que certains détails ne soient visible qu'en zoomant.

#align(center)[
  #figure(
    image("images/src5CRF32Fonctionnepasmal.png", width: 125%),
    caption: [Exemple CRF 32, SRC 5],
  ) <crf32src5>
]
Dans ce premier exemple on peut notamment voir que certaines textures du mur sont mieux concervés par le filtre simplifié tout en diminuant le coût de l'image.


#align(center)[
  #figure(
    image("images/retireBruiteCRF37SRC05.png", width: 125%),
    caption: [Exemple CRF 37, SRC 5],
  ) <crf37src5>
]
Cet exemple met en avant l'effet débruitage du filtre les artefacts de compression visibles à bassse qualité sont atténués par les différents filtres, cela s'accompagne aussi d'un gain en poids.

#align(center)[
  #figure(
    image("images/debruitesimplifieCRF37SRC14.png", width: 125%),
    caption: [Exemple CRF 37, SRC 14],
  ) <crf37src14>
]
Ici le premier filtre semble bien mieux conserver les textures liés au vetement, cependant on remarque une perte d'intensité lumineuse. Ici encore le coût est réduit.

#align(center)[
  #figure(
    image("images/cielbleuExempleCRF22SRC13.png", width: 125%),
    caption: [Exemple CRF 22, SRC 13],
  ) <crf22src13>
]

Cet exemple reprend un ciel bleu exemple typique que nous avions évoqué, ici encore le coût diminue malgré une scène simple.

#align(center)[
  #figure(
    image("images/neuronalFlouteSRC18CRF22.png", width: 125%),
    caption: [Exemple CRF 22, SRC 18],
  ) <crf22src18>
]

Cet exemple met en avant aussi les dérives, ici on voit le filtre neuronal qui vient flouter assez visiblement le personnage, ce qui est un effet indésirable. Le coût diminue mais la qualité perçue aussi.

== Limites et perspectives
Les résultats ne montrent pas une optimisation claire, visuellement certains exemples montrent tout de même une modification qui semble pertinente quand on regarde les détails, au regard des exemples visuels et des métriques qui s'accordent plutôt pour dire qu'à basse qualité le filtre a un intérêt pour conserver certaines textures ou limiter le bruit de compression. Cette limite pourrait comme évoqué plus tôt venir du jeu de données utilisé qui comporte aussi des iamges de moins bonne qualité, ce qui s'éloigne donc de la cible d'optimisation.
Nous sommes encore à stade précoce du projet et ne pas avoir de résultats clairs est normal l'objectif ici était aussi de mettre en avant les différences face aux outils que l'on a mis en place et de voir comment ils se comportent.

Par la suite il faudra alors voir s'il est possible d'utiliser d'autres mesures afin de guider au mieux l'apprentissage car il semble assez clair que le choix simple utilisé ici pour guider l'apprentissage n'est pas suffisant pour obtenir un gain net.
Les deux options offrent tout de même des possibilités différentes, le proxy simplifié pourra largement être modifié afin d'obtenir des performances plus intérressantes en replicant par exemple des méthodes plus avancées, mais les scores obtenus pour sa fidélité d'image montrent tout de même que l'implémentation et les choix sont valides les différences liés aux deux options retenus ne sont pas significative.

Il semble aussi assez clair que la majorité de la tâche se trouvera dans le choix du guide d'apprentissage, ici assez simple, il faudra trouver des méthodes plus robustes pour guider l'apprentissage et obtenir un gain net. Il faudra aussi voir si les métriques utilisées sont suffisantes pour juger de la qualité des images, car il semble que certaines ne soient pas assez sensibles aux modifications apportées par le filtre.

= Conclusion

Ce projet de fin d'études s'attaque à une question concrète : peut-on, à l'aide de l'IA, optimiser la compression vidéo en amont d'un codec existant comme #gls("hevc", "H.265"). Le cœur du travail a consisté à lever le principal verrou technique, l'impossibilité d'apprendre directement à travers un codec classique, en étudiant, adaptant et évaluant différentes approches de #gls("proxy", "proxy"). Deux voies ont été explorées : un proxy par codage neuronal et un codec simplifié différentiable, chacune avec ses forces et ses limites théorique le but était d'évaluer aussi sur un cas d'uasge concret leur pertinance. 

Les résultats ont montrés que les outils semblaient être des bon recopieur de la cible H.265 en particulier pour reproduir des images de bonnes qualités.

Les résultats face aux métriques montre parfois de soptimisations à faible qualité mais les écarts sont faible, ce qui vient aussi de la difficulté de la tâche, de slimites sur ces résultats sont à poser les métriques actuelles ne sont pas assuremment fiable pour notre cas d'usage d'iamges apssées transformée par IA.
Cependant on remarque parmis les différents exemples visuels que les modifications ont parfois permis de garder certaines textures, limiter le bruit de compression, ce qui prouve qu'une optimisation de ce type est possible mais il reste à en optimiser les effets afin d'obtenir des gains plus intérressants.

Ce travail s'accompagne d'un constat important : la qualité d'une optimisation dépend de nombreux éléments : du proxy,de la #gls("metrique", "métrique") qui guide l'apprentissage, des données utilisées. 

Au-delà de l'aspect technique, ce rapport aura cherché à répondre à trois questions transversales. Sur le plan économique, on retiendra que les enjeux de la #gls("vod", "VOD"), bande passante, stockage, énergie, rendent toute optimisation en amont directement profitable aux acteurs du secteur, et donc à notre cellule. Sur le plan organisationnel, le projet illustre comment une petite structure, à l'interface d'un laboratoire et d'une entreprise, s'organise autour de réunions régulières et de ressources mutualisées pour mener un travail d'apprentissage automatique. Sur le plan humain, enfin, il montre qu'une équipe jeune compense un certain manque d'expérience par une réelle capacité d'adaptation, une veille constante et un partage de connaissances au quotidien, autant d'atouts pour aborder des sujets de pointe malgré des compétences en début de projet limitées par le manque d'expérience.

Ce PFE ne constitue qu'une étape du projet, les outils mis en place ont vocation à être réutilisés, améliorés et adaptés. La validation finale, par de vrais utilisateurs, viendra confirmer la pertinence des optimisations une fois celles-ci suffisamment mûres.


= Bilan personnel

Ce projet aura été, avant tout, une période d'apprentissage dense. J'y ai
découvert un grand nombre de concepts, dans des domaines à la fois riches et
exigeants — la compression vidéo comme le deep learning —, et cette montée en
compétence progressive constitue l'un des aspects les plus enrichissants de ces
mois de travail.

Ce cheminement ne s'est pas fait sans difficultés. J'ai parfois eu du mal à me
contenter de solutions simples : la recherche de résultats plus aboutis m'a
conduit, à certains moments, vers des pistes trop ambitieuses, sources de
frustration lorsqu'elles n'aboutissaient pas. J'ai appris, au fil du projet, à
accepter la difficulté réelle de la tâche et à revenir vers des approches plus
mesurées mais solides, quitte à progresser plus lentement. C'est sans doute
l'un des enseignements les plus utiles de ce PFE, au-delà de son seul contenu
technique.

Je dois aussi reconnaître que rester pleinement mobilisé sur des sujets aussi
pointus, et sur une durée longue, n'est pas toujours évident. La complexité du
domaine demande un effort de concentration soutenu, c'est ce qui
rend l'organisation et la discipline de travail d'autant plus importantes.

J'ai par ailleurs conscience que les résultats obtenus restent, à ce stade,
encore peu aboutis. Ce constat n'est pas un échec, il correspond aussi à la période du projet, qui est encore jeune, et il ouvre à des perspectives pour la suite. Ce PFE constitue donc un point d'étape important
il aura permis de mettre au clair les idées, de développer les premiers outils et
de dégager les directions qui guideront la poursuite du projet un travail de
clarification et d'apprentissage dont la valeur dépasse celle des seuls résultats chiffrés.


#pagebreak()
= Glossaire

/ AV1 <av1>: Codec vidéo libre et ouvert, développé par l'Alliance for Open Media, successeur de VP9. Plus efficace que #gls("hevc", "H.265") à qualité égale, mais bien plus coûteux en calcul, ce qui limite son décodage sur le matériel ancien.

/ BD-rate <bdrate>: *Bjøntegaard Delta rate.* Mesure de référence pour comparer deux codeurs : elle exprime l'économie moyenne de débit à qualité égale. Plus elle est négative, plus l'économie est importante.

/ CABAC <cabac>: *Context-Adaptive Binary Arithmetic Coding.* Méthode de codage entropique utilisée par #gls("hevc", "H.265"), combinant deux optimisations : le choix de probabilités selon le contexte (les coefficients voisins) et leur mise à jour adaptative au fil du codage.

/ CDN <cdn>: *Content Delivery Network.* Réseau de diffusion de contenu. Serveurs répartis mondialement qui stockent des copies de la vidéo pour la diffuser depuis le serveur le plus proche de l'utilisateur, réduisant la latence et les coûts.

/ Chrominance <chrominance>: *Composantes de couleur.* Composantes d'une image portant l'information de couleur (chrominance bleue et chrominance rouge). L'œil y étant moins sensible, elles sont fortement sous-échantillonnées lors de la compression.

/ Codec <codec>: *Coder-decoder.* Outil chargé de compresser la vidéo à l'encodage (côté fournisseur) et de la reconstituer au décodage (côté utilisateur).

/ Codec neuronal <codec_neuronal>: Codec dont les étapes de compression et de décompression sont réalisées par des réseaux de neurones. Entièrement différentiable, il peut servir de #gls("proxy", "proxy") au sein d'un apprentissage, contrairement à un codec classique.

/ CRF / QP <crf-qp>: *Constant Rate Factor / Quantization Parameter.* Paramètres réglant l'intensité de la compression : plus leur valeur est élevée, plus la quantification est forte, donc plus la vidéo est légère mais dégradée. Le CRF vise une qualité constante tandis que le QP fixe un niveau de quantification rigide.

/ DCT <dct>: *Discrete Cosine Transform.* Transformée en cosinus discrète. Transformation appliquée aux blocs de l'image qui réorganise l'information par fréquences, séparant les zones lisses (basses fréquences) des zones de détail (hautes fréquences), sans perte d'information.

/ DISTS <dists>: *Deep Image Structure and Texture Similarity.* Métrique de qualité perceptuelle s'appuyant sur un réseau de neurones, calibrée sur des jugements humains. Sa particularité est sa tolérance aux différences de texture, ce qui en fait un guide adapté à l'optimisation visée par ce projet.

/ Filtre <filtre>: Dans ce projet, réseau de neurones appliqué en amont de la compression (prétraitement) pour modifier l'image afin de la rendre plus facile à compresser, sans dégrader la qualité perçue.

/ Forward / Backward <fwbw>: Les deux passes du graphe de calcul d'un réseau de neurones. Le _forward_ (aller) calcule le résultat à partir des entrées ; le _backward_ (retour) remonte le graphe pour calculer les gradients qui permettent d'ajuster les paramètres.

/ FPS <fps>: *Frames Per Second.* Images par seconde. Nombre d'images affichées chaque seconde dans une vidéo (couramment 30 ou 60). Plus il est élevé, plus la redondance temporelle entre images consécutives est forte.

/ GOP <gop>: *Group Of Pictures.* Groupe d'images. Ensemble d'images consécutives codées ensemble, organisé autour d'une image de référence (intra) dont dépendent les images suivantes (prédites). Limiter sa taille évite de s'appuyer sur une image d'une autre scène.

/ H.264 <h264>: *Advanced Video Coding (AVC).* Norme de compression vidéo créée en 2003. Bien qu'ancien, il reste le codec le plus utilisé aujourd'hui, grâce à son support matériel quasi universel.

/ HEVC / H.265 <hevc>: *High Efficiency Video Coding.* Norme de compression vidéo, successeur de #gls("h264", "H.264"), offrant une efficacité accrue à qualité égale. C'est le codec ciblé par ce projet, retenu pour son support matériel répandu.

/ LPIPS <lpips>: *Learned Perceptual Image Patch Similarity.* Métrique de qualité perceptuelle fondée sur les activations d'un réseau de neurones, cherchant à corréler avec le jugement humain de similarité entre deux images.

/ Luminance <luminance>: *Intensité lumineuse.* Composante d'une image représentant son intensité lumineuse (les niveaux de gris). L'œil humain y est très sensible. C'est sur cette composante que se concentre le filtre développé dans ce projet.

/ Métrique <metrique>: *Évaluation de qualité.* Mesure visant à évaluer la qualité d'une vidéo, le plus souvent en cherchant à prédire le jugement qu'en porterait un utilisateur humain.

/ MOS <mos>: *Mean Opinion Score.* Note d'opinion moyenne. Moyenne des notes de qualité attribuées par un panel d'utilisateurs à un contenu vidéo. C'est la référence « humaine » à laquelle on compare les métriques pour évaluer leur fiabilité.

/ Proxy <proxy>: *Modèle de substitution.* Dans ce projet, modèle de substitution différentiable reproduisant le comportement d'un codec réel, afin de pouvoir guider l'apprentissage d'un réseau de neurones là où le codec d'origine ne le permettrait pas.

/ PSNR <psnr>: *Peak Signal-to-Noise Ratio.* Mesure de fidélité comparant pixel à pixel l'image dégradée à la source. Simple à calculer, mais corrèle mal avec la perception humaine.

/ Quantification <quantification>: *Réduction de précision.* Étape de la compression qui réduit la précision des coefficients issus de la #gls("dct", "DCT") (division puis arrondi). C'est l'étape où l'information est volontairement perdue, principalement sur les hautes fréquences, pour alléger le poids de la vidéo.

/ RGB <rgb>: *Red, Green, Blue.* Espace de représentation des couleurs où chaque pixel est décrit par trois valeurs (rouge, vert, bleu). Ces canaux sont fortement corrélés, ce qui le rend peu efficace pour la compression.

/ SSIM <ssim>: *Structural Similarity Index Measure.* Métrique de qualité comparant la similarité structurelle entre deux images (luminance, contraste, structure). Plus proche de la perception humaine que le #gls("psnr", "PSNR").

/ STE <ste>: *Straight Through Estimator.* Technique permettant de faire traverser une opération non dérivable. On exécute l'opération réelle à l'aller (forward) et on lui substitue une approximation dérivable au retour (backward). C'est ce qui rend possible l'usage d'un codec au cœur de l'apprentissage.

/ SVR <svr>: *Support Vector Regression.* Modèle d'apprentissage automatique « frugal » (peu coûteux par rapport à un réseau de neurones), utilisé notamment par la métrique #gls("vmaf", "VMAF") pour relier les caractéristiques extraites d'une vidéo à un score de qualité.

/ VLM <vlm>: *Vision Language Model.* Modèle vision-langage. Modèle d'IA récent combinant compréhension d'image et de texte, offrant une analyse plus fine du contenu, mais coûteux en mémoire et difficile à utiliser comme guide d'apprentissage.

/ VMAF <vmaf>: *Video Multimethod Assessment Fusion.* Métrique de qualité développée par Netflix, devenue un standard de l'industrie. Elle combine plusieurs indicateurs extraits de l'image et du mouvement via un modèle appris (#gls("svr", "SVR")) pour prédire la note qu'un utilisateur moyen donnerait. Elle ne traite que la luminance.

/ VOD <vod>: *Video On Demand.* Vidéo à la demande. Mode de diffusion où chaque utilisateur déclenche un flux vidéo dédié au moment qu'il choisit, par opposition à une diffusion unique captée simultanément par tous comme la TNT.

/ YUV <yuv>: *Luminance / Chrominance.* Espace de représentation séparant l'intensité lumineuse (luminance) des informations de couleur (chrominances). Mieux adapté à la compression que le #gls("rgb", "RGB"), car il permet de réduire la couleur sans trop affecter la perception.

#pagebreak()

#bibliography("ref.bib", style: "ieee", title: "Références bibliographiques")


#pagebreak()

= Annexes
== Annexe 1 : Étude sur les plus gros challenges du secteur VOD/Streaming <challengesVOD>
#align(center)[
  #figure(
    image("images/prioriteEtude.png", width: 100%, height: 450pt),
    caption: [Illustration des challenges principaux face à un panel d'entreprises du secteur Streaming/#gls("vod", "VOD") pour l'année 2024-2025 @bitmovin2024report],
  )
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

== Annexe 3 : Architecture du filtre neuronal <archi>

#figure(
  grid(
    columns: 2,
    gutter: 1em,
    grid.cell(colspan: 2, image("images/archiFilter.png", width: 110%)),
    image("images/convblock.png", width: 90%),
    image("images/resBlock.png", width: 140%),
  ),
  caption: [Architecture du réseau et ses briques de base : architecture globale (haut), en bas, convblock (gauche) et resblock (droite). @khan2025neural],
)


= Remerciements

Je remercie tout d'abord les différentes parties qui m'ont permis de réaliser ce projet de fin d'études : Capacités, Polytech Nantes ainsi que l'ITII.

Je remercie aussi l'équipe IPI qui n'est pas directement liée à mon contrat mais fait partie de mon quotidien et m'offre un environnement de travail agréable ainsi que la proximité à différentes expertises, ce qui m'a permis d'évoluer durant ces trois années d'alternance.

Je remercie aussi mon équipe tutorale, notamment Bruno Theillac, mon référent apprentissage, pour ses nombreux conseils, Matthieu Perreira Da Silva, mon tuteur pédagogique, pour ses conseils et ses retours notamment sur la vulgarisation technique et les contraintes du PFE.
Enfin mon tuteur industriel Pierre Lebreton, pour sa confiance durant ce projet, ses conseils et sa disponibilité.


= Résumé

*Français*

Ce projet de fin d'études explore une question du secteur de la vidéo à la demande : peut-on, grâce à l'intelligence artificielle, optimiser la compression vidéo en amont d'un codec existant comme H.265 ? L'idée est d'appliquer un filtre neuronal de prétraitement qui rend l'image plus facile à compresser, réduisant le poids du fichier final à qualité perçue équivalente.
Le principal verrou est technique : les outils de compréssion classiques ne sont pas optimisable et s'intègrent donc mal dans l'apprentissage d'un réseau de neurones. Le travail a consisté à étudier, adapter et évaluer deux approches de proxy contournant cette limite : un proxy par codage neuronal, entraîné à imiter H.265, et un proxy par codec simplifié, reproduisant les briques essentielles de la compression sous une forme différentiable. Une attention particulière a été portée au choix des métriques de qualité, pour guider l'apprentissage comme pour évaluer les résultats sans biais.
Au-delà de la technique, le rapport examine le projet sous les angles économique, organisationnel et humain.

*Mots-clés :* compression vidéo, H.265, apprentissage profond, prétraitement, proxy de codec, qualité perçue, métrique.

*Anglais*
This final-year project investigates a concrete challenge in the video-on-demand sector: can artificial intelligence be used to optimise video compression upstream of an existing codec such as H.265, without modifying end-user devices? The idea is to apply a neural pre-processing filter that makes each frame easier to compress, reducing the final file size at equivalent perceived quality.
The main obstacle is technical: conventional codecs are not differentiable and therefore integrate poorly into the training of a neural network. The work consisted in studying, adapting and evaluating two proxy approaches to overcome this limitation: a neural-coding proxy, trained to mimic H.265, and a simplified-codec proxy, reproducing the essential building blocks of compression in a differentiable form. Particular attention was paid to the choice of quality metrics, both to guide learning and to evaluate results without bias.
Beyond the technical aspect, this report also examines the project from economic, organisational and human perspectives.

*Keywords :* video compression, H.265, deep learning, pre-processing, codec proxy, perceived quality, metric.