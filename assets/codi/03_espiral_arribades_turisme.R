# Spiral plot: arribades mensuals a establiments de vacances i curta estada · Espanya
# Dades: Eurostat TOUR_OCC_ARM (tour_occ_arm__custom_23799938_linear.csv), mensual
# Requereix: install.packages(c("ggplot2", "scales"))
# Posa el CSV a la mateixa carpeta que aquest script, o canvia ruta_dades.

library(ggplot2)

# ---- Paràmetres ------------------------------------------------------------
ruta_dades <- "tour_occ_arm__custom_23799938_linear.csv"
pais       <- "Spain"
# establiments de descans turístic (Holiday and other short-stay accommodation)
# alternativa amb sèrie més llarga (des de 1990): "Hotels and similar accommodation"
nace       <- "Holiday and other short-stay accommodation"

# ---- Lectura i filtre ------------------------------------------------------
dades <- read.csv(ruta_dades, stringsAsFactors = FALSE)

# Total de residents i no residents, valor en nombre (no variacions percentuals)
d <- subset(dades,
            geo == pais & c_resid == "Total" & unit == "Number" & nace_r2 == nace)

d <- d[order(d$TIME_PERIOD), ]
d$data <- as.Date(paste0(d$TIME_PERIOD, "-01"))
d$any  <- as.integer(format(d$data, "%Y"))
d$mes  <- as.integer(format(d$data, "%m"))

stopifnot(!anyNA(d$OBS_VALUE), !anyDuplicated(d$data))
idx <- (d$any - min(d$any)) * 12 + (d$mes - 1)
stopifnot(all(diff(idx) == 1))    # sèrie mensual contínua, sense forats

# ---- Geometria -------------------------------------------------------------
# Angle = mes (gener a dalt, sentit horari). Radi = 1 + any: cada any és una volta.
d$r     <- 1 + idx / 12
d$theta <- 2 * pi * (d$mes - 1) / 12
d$x     <- d$r * sin(d$theta)
d$y     <- d$r * cos(d$theta)

# Cada segment va del mes anterior al mes actual. El gruix i el color
# corresponen al nombre d'arribades del mes final del segment.
n <- nrow(d)
seg <- data.frame(
  x     = d$x[-n],   y    = d$y[-n],
  xend  = d$x[-1],   yend = d$y[-1],
  valor = d$OBS_VALUE[-1]
)

# Etiquetes de l'any al costat de cada gener (on comença cada volta)
anys <- d[d$mes == 1, ]
anys$lx <- -0.12

# Etiquetes de mes a la part exterior
noms_mes <- data.frame(
  mes = 1:12,
  nom = c("Gen", "Feb", "Mar", "Abr", "Mai", "Jun",
          "Jul", "Ago", "Set", "Oct", "Nov", "Des")
)
rl <- max(d$r) + 0.8
noms_mes$x <- rl * sin(2 * pi * (noms_mes$mes - 1) / 12)
noms_mes$y <- rl * cos(2 * pi * (noms_mes$mes - 1) / 12)

ultim_mes  <- format(max(d$data), "%m/%Y")
primer_mes <- format(min(d$data), "%m/%Y")

# ---- Gràfic ----------------------------------------------------------------
# Un sol color en gradient (blau): el valor es llegeix pel color i pel gruix.
p <- ggplot(seg, aes(x = x, y = y, xend = xend, yend = yend,
                     colour = valor, linewidth = valor)) +
  geom_segment(lineend = "round") +
  geom_text(data = anys, aes(x = lx, y = y, label = any),
            inherit.aes = FALSE, hjust = 1, size = 3, colour = "grey25") +
  geom_text(data = noms_mes, aes(x = x, y = y, label = nom),
            inherit.aes = FALSE, colour = "grey40", size = 3.2) +
  scale_colour_gradient(
    low    = "#C6DBEF",
    high   = "#08306B",
    name   = "Arribades\nmensuals",
    labels = scales::label_number(scale = 1e-6, suffix = " M", decimal.mark = ",")
  ) +
  scale_linewidth_continuous(range = c(0.3, 3), guide = "none") +
  coord_equal() +
  labs(
    title    = paste0("Arribades a establiments de vacances i curta estada · ", pais),
    subtitle = paste0(primer_mes, " – ", ultim_mes,
                      " · cada volta és un any · gruix i color = nombre d'arribades"),
    caption  = paste0("Font: Eurostat, TOUR_OCC_ARM (residents i no residents, Number). ",
                      "Eurostat marca una ruptura de sèrie (flag 'b') al gener de 2012.")
  ) +
  theme_void(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(colour = "grey30"),
        legend.position = "right",
        plot.margin = margin(12, 12, 12, 12))

# ---- Sortida ---------------------------------------------------------------
dir.create("sortides", showWarnings = FALSE)
ggsave(file.path("sortides", "espiral_arribades_ES.png"),
       p, width = 10, height = 9, dpi = 200)

print(d[, c("TIME_PERIOD", "OBS_VALUE")])
