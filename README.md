# How does the relationship between lot size and sale price vary across neighborhoods in Ames, Iowa?

**Codex session date:** October 19, 2026

## Primary visualization: neighborhood correlations

![Horizontal bar chart of Pearson correlations between lot area and sale price by neighborhood](analysis/outputs/neighborhood_correlation_bar_chart.png)

## Findings summary

This analysis uses 2,930 home sales across 28 Ames neighborhoods. It compares each home's lot area (`Lot Area`) with its sale price (`SalePrice`) using the Pearson correlation. A positive correlation means larger lots tend to be associated with higher sale prices in that neighborhood; a negative correlation means the observed pattern goes in the other direction. Correlation describes an association, not proof that lot size causes a price change.

Across all homes, the relationship is modestly positive (r = 0.267). The neighborhood results vary. Among neighborhoods with larger samples, StoneBr has the strongest positive correlation (r = 0.732; 51 homes), followed by NridgHt (r = 0.663; 166 homes) and Somerst (r = 0.643; 182 homes). BrkSide (r = 0.577; 108 homes) also has a clear positive association. In Gilbert, Mitchel, and IDOTRR, correlations are close to zero, indicating little linear relationship in these sales. Some neighborhoods have negative correlations, including Greens (r = -0.685), but Greens has only eight homes, so that estimate is particularly uncertain.

Sample size matters when comparing the bars. The chart labels each neighborhood with its number of homes and colors groups with 3–29 homes orange to flag estimates for caution. GrnHill (2 homes) and Landmrk (1 home) are omitted from the ranking because their results are too limited for reliable interpretation. For example, Blueste has a high correlation (r = 0.888) but only 10 homes. Its estimate should not be treated as strong evidence about the neighborhood overall.

The analysis also checked unusually large lots using the common 1.5×IQR rule. It flagged 127 lots above approximately 17,728 square feet. These lots remain in the primary analysis because a large value alone does not show that a record is wrong. As a sensitivity check, the overall correlation rises from 0.267 to 0.417 when those flagged lots are excluded, suggesting they weaken the overall linear association. The neighborhood effects vary, so this check is not a reason to discard the homes.

See the [detailed findings](analysis/outputs/findings.md), [neighborhood summary table](analysis/outputs/neighborhood_summary.csv), [original scatterplot](analysis/outputs/lot_area_sale_price_by_neighborhood.png), and [chart generation script](analysis/create_neighborhood_correlation_chart.R).
