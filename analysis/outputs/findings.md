# Ames lot area and sale price by neighborhood

## Summary

The analysis uses all 2,930 homes in `AmesHousing-1.csv`. Lot area and sale price have a modest positive Pearson correlation across the full dataset (**r = 0.267**). Within neighborhoods the association varies: among neighborhoods with at least two homes, 22 have a positive correlation and five have a negative correlation. Correlation describes linear association; it does not show that larger lots cause higher sale prices.

For neighborhoods with comparatively larger samples, the positive association is strongest in **StoneBr** (r = 0.732, 51 homes), **NridgHt** (r = 0.663, 166), and **Somerst** (r = 0.643, 182). **NAmes** (r = 0.488, 443) and **OldTown** (r = 0.488, 239) show moderate positive associations. **Gilbert** (r = -0.038, 165), **Mitchel** (r = -0.033, 114), and **IDOTRR** (r = -0.029, 93) show little linear association. Neighborhood estimates based on few sales are unstable: GrnHill has two homes, and Landmrk has one, so its correlation and trend cannot be estimated.

The scatterplot shows each home and a within-neighborhood ordinary least squares line where there are at least three homes. Panels have independent axes to make local patterns visible; slopes and point distances should not be compared visually across panels without accounting for those scale differences. The CSV contains each neighborhood's home count, average lot area, average sale price, Pearson correlation, estimated price change per additional 1,000 sq ft, count of flagged large lots, and sensitivity estimates.

## Unusually large lots and influence

Using the conventional global upper outlier fence of Q3 + 1.5 x IQR, a lot area above **17,728 sq ft** is flagged. This marks **127 homes (4.3%)**. It is a screening rule, not evidence that the records are errors: large lots can be genuine properties, especially in neighborhoods with larger parcels. The largest lot is **215,245 sq ft in Timber** (sale price $375,000); the next largest are 164,660 sq ft in Timber and 159,000 sq ft in ClearCr.

Large lots have leverage because they are far from the main concentration of lot sizes, and their sale prices do not always increase in proportion to area. As a sensitivity check only, recalculating the overall correlation without the 127 flagged lots changes it from **0.267 to 0.417**. This suggests large-lot observations weaken the overall positive linear correlation. Neighborhood impacts are mixed: for example, Gilbert changes from r = -0.038 to 0.334 and Mitchel from -0.033 to 0.170, while Edwards changes from 0.366 to 0.206 and OldTown from 0.488 to 0.334. The summary CSV reports this comparison for every neighborhood.

**No homes were removed from the primary analysis or visualization.** The outlier-excluded calculations are shown only as a sensitivity check, because observations should not be dropped solely for being large; removal would require a documented data error or a clearly justified change in the question.

## Files

- Analysis code: [`ames_neighborhood_lot_price.R`](../ames_neighborhood_lot_price.R)
- Neighborhood summary: [`neighborhood_summary.csv`](neighborhood_summary.csv)
- Scatterplot: [`lot_area_sale_price_by_neighborhood.png`](lot_area_sale_price_by_neighborhood.png)

Run the analysis from the repository root with `Rscript analysis/ames_neighborhood_lot_price.R`. It requires R, `ggplot2`, and `scales`.
