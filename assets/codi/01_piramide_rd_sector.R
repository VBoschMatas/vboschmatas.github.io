# Piràmide: distribució de persones en R+D per sector · Espanya, 2024
# Dades: Eurostat TSC00003 (tsc00003_linear.csv)
# Requereix: install.packages(c("ggplot2", "scales"))
# Posa el CSV a la mateixa carpeta que aquest script, o canvia ruta_dades.

library(ggplot2)

# ---- Paràmetres ------------------------------------------------------------
ruta_dades  <- "tsc00003_linear.csv"
pais        <- "Spain"
any_analisi <- 2024

# ---- Lectura i filtre ------------------------------------------------------
dades <- read.csv(ruta_dades, stringsAsFactors = FALSE)

# Persones investigadores (head count), total de sexes, sense la suma de sectors
d <- subset(dades,
            geo == pais & TIME_PERIOD == any_analisi &
              sex == "Total" & prof_pos == "Researchers" &
              unit == "Head count" & sectperf != "All sectors")

total_oficial <- dades$OBS_VALUE[dades$geo == pais & dades$TIME_PERIOD == any_analisi &
                                   dades$sex == "Total" & dades$prof_pos == "Researchers" &
                                   dades$sectperf == "All sectors"]
stopifnot(nrow(d) == 4, sum(d$OBS_VALUE) == total_oficial)

etiquetes <- c(
  "Business enterprise sector" = "Empreses privades",
  "Government sector"          = "Secció Gubernamental",
  "Higher education sector"    = "Estudis avançats i educació",
  "Private non-profit sector"  = "Empreses sense ànims de lucre"
)

colors <- c(
  "Business enterprise sector" = "#872013",
  "Higher education sector"    = "#08A04D",
  "Government sector"          = "#F4A522",
  "Private non-profit sector"  = "#92C5DE"
)

# ---- Geometria de la piràmide ----------------------------------------------
# Un triangle de base W i alçada H. Cada sector és una franja horitzontal
# l'àrea de la qual és proporcional a les persones que té. Els costats són rectes,
# així el conjunt és una piràmide real. El sector més petit va a la punta.
# Àrea des de la punta fins a una alçada t: (t/H)^2 de l'àrea total,
# per tant t = H * sqrt(fracció acumulada) fa que cada franja tingui l'àrea justa.
d <- d[order(d$OBS_VALUE), ]
n <- nrow(d)
H <- 1
W <- 2

fraccio_acumulada <- cumsum(d$OBS_VALUE) / total_oficial
t_fi  <- H * sqrt(fraccio_acumulada)   # distància des de la punta fins a la vora inferior
t_ini <- c(0, t_fi[-n])                # distància des de la punta fins a la vora superior
d$yt   <- H - t_ini                    # vora superior de cada franja
d$yb   <- H - t_fi                     # vora inferior
d$ymid  <- (d$yt + d$yb) / 2
d$etiqueta <- etiquetes[d$sectperf]
d$pct   <- d$OBS_VALUE / total_oficial * 100

# Amplada de la piràmide a una alçada y (0 a la punta, W/2 a la base)
mitja <- function(y) (W / 2) * (H - y) / H
d$mitja_mid <- mitja(d$ymid)

fmt_num <- function(x) format(x, big.mark = ".", decimal.mark = ",", scientific = FALSE, trim = TRUE)
fmt_pct <- function(x) paste0(gsub("\\.", ",", sprintf("%.1f", x)), " %")

# Quatre vèrtexs per franja: dos a la vora superior i dos a la inferior
poligons <- do.call(rbind, lapply(seq_len(n), function(i) {
  data.frame(
    id     = i,
    sectperf = d$sectperf[i],
    x = c(-mitja(d$yt[i]), mitja(d$yt[i]), mitja(d$yb[i]), -mitja(d$yb[i])),
    y = c(d$yt[i], d$yt[i], d$yb[i], d$yb[i])
  )
}))

# ---- Gràfic ----------------------------------------------------------------
p <- ggplot() +
  geom_polygon(data = poligons, aes(x = x, y = y, group = id, fill = sectperf),
               colour = "white", linewidth = 0.6) +
  # Línies de referència des de cada franja fins a les columnes de text
  geom_segment(data = d, aes(x = mitja_mid + 0.02, xend = W / 2 + 0.03,
                             y = ymid, yend = ymid),
               colour = "grey65", linetype = "dotted") +
  geom_segment(data = d, aes(x = -mitja_mid - 0.02, xend = -W / 2 - 0.03,
                             y = ymid, yend = ymid),
               colour = "grey65", linetype = "dotted") +
  geom_text(data = d, aes(x = -W / 2 - 0.04, y = ymid, label = etiqueta),
            hjust = 1, size = 3.8) +
  geom_text(data = d, aes(x = W / 2 + 0.04, y = ymid,
                          label = paste0(fmt_num(OBS_VALUE), "  (", fmt_pct(pct), ")")),
            hjust = 0, size = 3.8, fontface = "bold") +
  scale_fill_manual(values = colors, guide = "none") +
  coord_cartesian(xlim = c(-1.6, 1.6), ylim = c(-0.05, H + 0.05), clip = "off") +
  labs(
    title    = paste0("Distribució de persones en R+D per sector · Espanya, ", any_analisi),
    subtitle = paste0("Persones investigadores (recompte). Total de sectors: ",
                      fmt_num(total_oficial), " persones"),
    caption  = paste0("Font: Eurostat, TSC00003. L'àrea de cada franja és proporcional al nombre de persones.")
  ) +
  theme_void(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(colour = "grey30"),
        plot.margin = margin(12, 12, 12, 12))

# ---- Sortida ---------------------------------------------------------------
dir.create("sortides", showWarnings = FALSE)
ggsave(file.path("sortides", paste0("piramide_rd_sector_ES_", any_analisi, ".png")),
       p, width = 10, height = 7, dpi = 200)

print(d[, c("sectperf", "OBS_VALUE", "pct")])
