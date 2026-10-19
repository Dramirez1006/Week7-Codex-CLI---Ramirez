#!/usr/bin/env Rscript

# Explore the association between lot area and sale price by Ames neighborhood.
# Run from the repository root with: Rscript analysis/ames_neighborhood_lot_price.R
# All homes are retained in the primary summaries and plotted trends. The
# separate sensitivity columns compare results after omitting globally large
# lots (the 1.5*IQR rule) solely to show how influential those observations are.

suppressPackageStartupMessages(library(ggplot2))

input_file <- "AmesHousing-1.csv"
output_dir <- file.path("analysis", "outputs")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

homes <- read.csv(input_file, stringsAsFactors = FALSE, check.names = FALSE)
required <- c("Lot Area", "SalePrice", "Neighborhood")
if (!all(required %in% names(homes))) {
  stop("Dataset is missing one or more required columns: ", paste(required, collapse = ", "))
}
if (anyNA(homes[required])) stop("Missing values found in analysis columns.")
homes$LotArea <- as.numeric(homes[["Lot Area"]])
homes$SalePrice <- as.numeric(homes[["SalePrice"]])
homes$Neighborhood <- factor(homes$Neighborhood)

# A global 1.5*IQR upper fence flags unusually large lots for review. It is a
# screening convention, not a reason to discard observations.
lot_q <- quantile(homes$LotArea, c(0.25, 0.75), names = FALSE)
lot_iqr <- diff(lot_q)
large_lot_fence <- lot_q[2] + 1.5 * lot_iqr
homes$LargeLot <- homes$LotArea > large_lot_fence

summarize_group <- function(d) {
  n <- nrow(d)
  fit <- if (n >= 2 && length(unique(d$LotArea)) >= 2) lm(SalePrice ~ LotArea, data = d) else NULL
  r <- if (n >= 2 && sd(d$LotArea) > 0 && sd(d$SalePrice) > 0) cor(d$LotArea, d$SalePrice) else NA_real_
  data.frame(
    homes = n,
    average_lot_area_sq_ft = mean(d$LotArea),
    average_sale_price = mean(d$SalePrice),
    pearson_correlation = r,
    trend_dollars_per_1000_sq_ft = if (is.null(fit)) NA_real_ else unname(coef(fit)["LotArea"] * 1000),
    unusually_large_lots = sum(d$LargeLot),
    correlation_without_large_lots = {
      kept <- d[!d$LargeLot, ]
      if (nrow(kept) >= 2 && sd(kept$LotArea) > 0 && sd(kept$SalePrice) > 0) cor(kept$LotArea, kept$SalePrice) else NA_real_
    },
    trend_without_large_lots_dollars_per_1000_sq_ft = {
      kept <- d[!d$LargeLot, ]
      if (nrow(kept) >= 2 && length(unique(kept$LotArea)) >= 2) unname(coef(lm(SalePrice ~ LotArea, data = kept))["LotArea"] * 1000) else NA_real_
    }
  )
}

pieces <- lapply(split(homes, homes$Neighborhood, drop = TRUE), summarize_group)
summary <- do.call(rbind, pieces)
summary$Neighborhood <- rownames(summary)
rownames(summary) <- NULL
summary <- summary[, c("Neighborhood", "homes", "average_lot_area_sq_ft", "average_sale_price",
                       "pearson_correlation", "trend_dollars_per_1000_sq_ft", "unusually_large_lots",
                       "correlation_without_large_lots", "trend_without_large_lots_dollars_per_1000_sq_ft")]
summary <- summary[order(summary$Neighborhood), ]
write.csv(summary, file.path(output_dir, "neighborhood_summary.csv"), row.names = FALSE, na = "")

# Facets use independent axes so local patterns remain visible. Trend lines use
# all observations in groups with at least three sales; orange points mark large
# lots without excluding them. With fewer than three sales a line is not useful.
trend_data <- homes[as.integer(table(homes$Neighborhood)[as.character(homes$Neighborhood)]) >= 3, ]
plot <- ggplot(homes, aes(x = LotArea, y = SalePrice)) +
  geom_point(aes(color = LargeLot), alpha = 0.68, size = 1.25) +
  scale_color_manual(values = c(`FALSE` = "#315A7D", `TRUE` = "#D97732"),
                     labels = c(`FALSE` = "Within IQR fence", `TRUE` = "Above large-lot fence"),
                     name = "Lot size") +
  geom_smooth(data = trend_data, method = "lm", formula = y ~ x, se = FALSE,
              color = "#242424", linewidth = 0.55) +
  facet_wrap(~ Neighborhood, scales = "free", ncol = 4) +
  scale_x_continuous(labels = scales::label_number(big.mark = ",")) +
  scale_y_continuous(labels = scales::label_dollar(big.mark = ",")) +
  labs(title = "Lot area and sale price by Ames neighborhood",
       subtitle = sprintf("All %s homes shown; black lines are within-neighborhood linear trends. Facets have independent scales.",
                          format(nrow(homes), big.mark = ",")),
       x = "Lot area (sq ft)", y = "Sale price (USD)",
       caption = sprintf("Orange points exceed the global 1.5×IQR fence (%s sq ft) and remain included. Trend lines omitted for groups with fewer than 3 sales.",
                         format(round(large_lot_fence), big.mark = ","))) +
  theme_minimal(base_size = 9) +
  theme(legend.position = "bottom", strip.text = element_text(face = "bold", size = 8),
        panel.grid.minor = element_blank(), plot.title = element_text(face = "bold"))

ggsave(file.path(output_dir, "lot_area_sale_price_by_neighborhood.png"), plot,
       width = 14, height = 13, units = "in", dpi = 220, bg = "white")

cat("Rows:", nrow(homes), " Neighborhoods:", nlevels(homes$Neighborhood), "\n")
cat("Large-lot fence:", round(large_lot_fence), "sq ft; flagged:", sum(homes$LargeLot), "\n")
cat("Overall Pearson correlation:", round(cor(homes$LotArea, homes$SalePrice), 3), "\n")
cat("Wrote summary CSV and scatterplot to", output_dir, "\n")
