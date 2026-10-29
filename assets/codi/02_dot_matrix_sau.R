# Dot matrix: superfície agrícola utilitzada (SAU) a Espanya, 2024
# Dades: Eurostat TAG00025 (tag00025_linear.csv)
# Requereix: install.packages("ggplot2")
# Posa el CSV a la mateixa carpeta que aquest script, o canvia ruta_dades.

library(ggplot2)

# ---- Paràmetres ------------------------------------------------------------
ruta_dades  <- "tag00025_linear.csv"
pais        <- "Spain"
any_analisi <- 2024
punts       <- 200   # 1 punt = 0,5 % de la SAU
files       <- 20    # 20 punts per fila: graella de 20 x 10

# ---- Lectura i filtre ------------------------------------------------------
dades <- read.csv(ruta_dades, stringsAsFactors = FALSE)
d <- subset(dades, geo == pais & TIME_PERIOD == any_analisi)

sau   <- d$OBS_VALUE[d$crops == "Utilised agricultural area"]
parts <- d[d$crops != "Utilised agricultural area", ]
stopifnot(length(sau) == 1, nrow(parts) == 4)

etiquetes <- c(
  "Arable land"         = "Terres de conreu",
  "Permanent grassland" = "Prats i pastures permanents",
  "Permanent crops"     = "Cultius permanents",
  "Kitchen gardens"     = "Horts familiars"
)

colors <- c(
  "Arable land"         = "#E69F00",
  "Permanent grassland" = "#009E73",
  "Permanent crops"     = "#CC79A7",
  "Kitchen gardens"     = "#0072B2"
)

fmt <- function(x, decimals = 1) gsub("\\.", ",", sprintf(paste0("%.", decimals, "f"), x))

# ---- Resum per categoria ---------------------------------------------------
resum <- data.frame(crops = names(etiquetes), etiqueta = unname(etiquetes),
                    stringsAsFactors = FALSE)
resum$hectarees <- parts$OBS_VALUE[match(resum$crops, parts$crops)]
resum$pct       <- resum$hectarees / sau * 100
resum$llegenda  <- paste0(resum$etiqueta, " · ", fmt(resum$pct), " %")

# ---- Assignació de punts (mètode de restes més grans) ----------------------
# Cada categoria rep la part entera del seu percentatge. Els punts que sobren
# es reparteixen per la fracció decimal més gran, perquè el total sigui exacte.
quota      <- resum$hectarees / sau * punts
assignats  <- floor(quota)
pendents   <- punts - sum(assignats)
ordre_res  <- order(quota - assignats, decreasing = TRUE)
assignats[ordre_res[seq_len(pendents)]] <- assignats[ordre_res[seq_len(pendents)]] + 1
stopifnot(sum(assignats) == punts)

# ---- Graella: un punt per unitat -------------------------------------------
categories <- rep(resum$crops, times = assignats)
graella <- data.frame(
  crops = factor(categories, levels = resum$crops),
  i     = seq_along(categories)
)
graella$col <- (graella$i - 1) %% files + 1
graella$fila <- (punts / files) - floor((graella$i - 1) / files)

# ---- Gràfic ----------------------------------------------------------------
p <- ggplot(graella, aes(x = col, y = fila, colour = crops)) +
  geom_point(size = 7, shape = 16) +
  scale_colour_manual(values = colors, breaks = resum$crops,
                      labels = resum$llegenda, name = NULL) +
  coord_equal() +
  labs(
    title    = paste0("Superfície agrícola utilitzada a Espanya, ", any_analisi),
    subtitle = paste0("Total: ", fmt(sau / 1000), " milions d'hectàrees · 1 punt = 0,5 %"),
    caption  = "Font: Eurostat, TAG00025 (Main area - thousand hectares)"
  ) +
  theme_void(base_size = 12) +
  theme(legend.position = "bottom",
        legend.direction = "vertical",
        legend.justification = "left",
        plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(colour = "grey30"),
        plot.margin = margin(12, 12, 12, 12))

# ---- Sortida ---------------------------------------------------------------
dir.create("sortides", showWarnings = FALSE)
ggsave(file.path("sortides", paste0("dot_matrix_sau_ES_", any_analisi, ".png")),
       p, width = 8, height = 8, dpi = 200)

print(resum[, c("etiqueta", "hectarees", "pct")])
print(data.frame(categoria = resum$etiqueta, punts = assignats))
