#!/usr/bin/env Rscript

# Create a ranked correlation bar chart from the existing analysis summary.
# Run from the repository root with: Rscript analysis/create_neighborhood_correlation_chart.R

suppressPackageStartupMessages(library(ggplot2))

summary_file <- file.path("analysis", "outputs", "neighborhood_summary.csv")
output_file <- file.path("analysis", "outputs", "neighborhood_correlation_bar_chart.png")
summary <- read.csv(summary_file, stringsAsFactors = FALSE)
too_few <- summary[summary$homes < 3 | is.na(summary$pearson_correlation), ]
summary <- summary[summary$homes >= 3 & !is.na(summary$pearson_correlation), ]
if (!nrow(summary)) stop("No neighborhoods have a calculable Pearson correlation.")

# Two homes can produce a perfect +/-1 correlation by construction, so omit
# groups with fewer than three homes. Other low-count groups stay visible but
# are marked for caution; 30 is a practical warning threshold, not a guarantee.
summary$low_sample <- summary$homes < 30
summary$label <- sprintf("%s  (n = %d)", summary$Neighborhood, summary$homes)
summary$label <- factor(summary$label, levels = summary$label[order(summary$pearson_correlation)])
summary$label_x <- ifelse(summary$pearson_correlation >= 0.965, 0.97,
                          summary$pearson_correlation + ifelse(summary$pearson_correlation >= 0, 0.035, -0.035))
summary$label_hjust <- ifelse(summary$pearson_correlation >= 0.965, 1,
                              ifelse(summary$pearson_correlation >= 0, 0, 1))

plot <- ggplot(summary, aes(x = pearson_correlation, y = label, fill = low_sample)) +
  geom_col(width = 0.72) +
  geom_vline(xintercept = 0, color = "#303030", linewidth = 0.55) +
  geom_text(aes(x = label_x, label = sprintf("%.2f", pearson_correlation), hjust = label_hjust),
            size = 3.2, color = "#202020") +
  scale_fill_manual(values = c(`FALSE` = "#356B8C", `TRUE` = "#D97732"), guide = "none") +
  scale_x_continuous(limits = c(-1, 1), breaks = seq(-1, 1, by = 0.25),
                     expand = expansion(mult = c(0, 0))) +
  labs(title = "Lot area and sale price correlation by Ames neighborhood",
       subtitle = "Pearson correlations, ranked from strongest positive to weakest",
       x = "Correlation between Lot Area and SalePrice", y = NULL,
       caption = sprintf("Orange = 3–29 homes; interpret correlations cautiously.\n%s omitted because samples are too small for reliable interpretation.",
                         paste(sprintf("%s (n = %d)", too_few$Neighborhood, too_few$homes), collapse = "; "))) +
  theme_minimal(base_size = 11) +
  theme(axis.text.y = element_text(size = 9.5, color = "#222222"),
        axis.text.x = element_text(color = "#222222"),
        panel.grid.major.y = element_blank(), panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold", size = 15),
        plot.caption = element_text(hjust = 0, size = 8.5, margin = margin(t = 8)),
        plot.margin = margin(12, 30, 20, 12))

ggsave(output_file, plot, width = 11, height = 11, units = "in", dpi = 240, bg = "white")
cat("Chart:", output_file, "\n")
cat("Neighborhoods plotted:", nrow(summary), " Low-sample neighborhoods marked:", sum(summary$low_sample),
    " Omitted for too few homes:", nrow(too_few), "\n")
