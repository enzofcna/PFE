#set page(
  paper: "a4",
  margin: (x: 2.5cm, top: 2.5cm, bottom: 2.5cm)
)
#set text(
  font: "Liberation Serif",
  size: 11pt,
  lang: "fr"
)

#place(top + left, scope: "column")[
  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 0cm,
    align: center + horizon,
    rect(width: 80%, height: 80pt, stroke: 0.5pt + gray, radius: 2pt)[
      #image("images\logos\popo.webp", width: 180%)
    ],
    rect(width: 80%, height: 90pt, stroke: 0.5pt + gray, radius: 2pt)[
      #image("images\logos\ITII.webp", width: 100%)
    ],
    rect(width: 80%, height: 90pt, stroke: 0.5pt + gray, radius: 2pt)[
      #image("images\logos\capa.webp", width: 120%)
    ]
  )

  #v(5cm)

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
      #text(size: 9.5pt, style: "italic")[Référent apprentissage]
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

= Introduction
Votre texte d'introduction commence ici sur une nouvelle page propre avec la numérotation activée.