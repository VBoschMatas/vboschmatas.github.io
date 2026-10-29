---
layout: default
title: PAC 2 - Visualització de Dades
permalink: /pac2/
description: Tres visualitzacions amb R i ggplot2 a partir de dades obertes d'Eurostat.
---

# PAC 2 - Visualització de Dades

Aquesta pàgina recull les tres visualitzacions de la PAC 2. Cada una s'ha fet amb R i ggplot2 a partir de dades obertes d'Eurostat. Sota de cada gràfic hi ha el codi R que el genera.

## 1. Piràmide: persones en R+D per sector

Persones investigadores en R+D a Espanya el 2024, per sector d'execució. La piràmide és un triangle dividit en franges horitzontals: l'àrea de cada franja és proporcional al nombre de persones. Les empreses sense ànims de lucre (0,6 %) són la franja de la punta.

Font: [`Eurostat, TSC00003`](https://ec.europa.eu/eurostat/databrowser/view/tsc00003/default/table?lang=en)

<img style="max-width:100%; width:auto; height:auto;" src="{{ '/assets/img/piramide-rd-sector.png' | relative_url }}" alt="Piràmide de la distribució de persones en R+D per sector a Espanya el 2024. Estudis avançats i educació 51,3 %, empreses privades 34,2 %, secció governamental 13,9 % i empreses sense ànims de lucre 0,6 %.">

Codi: [`01_piramide_rd_sector.R`]({{ '/assets/codi/01_piramide_rd_sector.R' | relative_url }}).

## 2. Dot matrix: superfície agrícola utilitzada

Superfície agrícola utilitzada a Espanya el 2024. Cada punt representa el 0,5 % de la superfície. Les terres de conreu (46 %) i els prats i pastures permanents (33 %) ocupen gairebé vuit de cada deu hectàrees. Els horts familiars (0,5 %) surten amb un sol punt.

Font: [Eurostat, TAG00025](https://ec.europa.eu/eurostat/databrowser/view/tag00025/default/table?lang=en&category=t_agr.t_apro.t_apro_cp)

<img style="max-width:100%; width:auto; height:auto;" src="{{ '/assets/img/dot-matrix-sau.png' | relative_url }}" alt="Graella de 200 punts amb la superfície agrícola utilitzada d'Espanya el 2024: 46 % terres de conreu, 33 % prats i pastures permanents, 20,6 % cultius permanents i 0,5 % horts familiars.">

Codi: [`02_dot_matrix_sau.R`]({{ '/assets/codi/02_dot_matrix_sau.R' | relative_url }}).

## 3. Espiral: arribades a establiments de vacances

Arribades mensuals a establiments de vacances i de curta estada a Espanya, de gener de 2012 a agost de 2026. Cada volta de l'espiral és un any i cada posició és un mes (gener a dalt, sentit horari). El gruix i el color de la línia mostren el nombre d'arribades: com més turistes, més gruixuda i més fosca.

Font: [`Eurostat, TOUR_OCC_ARM`](https://ec.europa.eu/eurostat/databrowser/view/tour_occ_arm__custom_23799938/default/table)

<img style="max-width:100%; width:auto; height:auto;" src="{{ '/assets/img/espiral-arribades-turisme.webp' | relative_url }}" alt="Espiral amb una volta per any de 2012 a 2026. Cada mes és una posició angular i el gruix i el color de la línia mostren el nombre d'arribades mensuals a establiments de vacances i curta estada a Espanya.">

Codi: [`03_espiral_arribades_turisme.R`]({{ '/assets/codi/03_espiral_arribades_turisme.R' | relative_url }}).
