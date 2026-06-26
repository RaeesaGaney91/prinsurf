# prinsurf

Principal surface biplots with smooth **gradient-flow axes**.

`prinsurf` fits a two-dimensional principal surface to a numeric data matrix and
builds calibrated biplot axes for it by gradient flow: each variable's axis is the
steepest-ascent trajectory of its fitted coordinate function. Such an axis is
smooth by construction, crosses the variable's contour lines orthogonally, and
reduces to the ordinary PCA-biplot axis when the surface is flat. Variables whose
fitted value has an interior extremum, or whose axis spans too little of the
variable's range, are *deferred* and read from contour lines instead.

```r
fit <- prinsurf(X, scale = TRUE)   # X: n x p numeric matrix
fit                                 # summary
plot(fit, group = my_factor)        # biplot with calibrated axes
psaxis(fit, "my_var")               # one variable's axis (or a deferral flag)
predictivity(fit)                   # per-sample predictivity
```

Base R only (no compiled code, no non-CRAN dependencies).
