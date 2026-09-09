# prinsurf

## Installation

You can install the development version of prinsurf from
[GitHub](https://github.com/) with:

``` r

library(devtools)
install_github("RaeesaGaney91/prinsurf")
```

## Example

``` r

fit <- prinsurf(X, scale = TRUE)          # X: n x p numeric matrix
fit                                        # summary
plot(fit, group = my_factor)               # bare biplot (sample coordinates only)
plot(fit, vars = colnames(X), group = my_factor)  # one contour panel per variable
predict(fit, "my_var")                     # per-sample values read off that variable's contours
contour_predictive_error(fit)              # per-variable RMS contour-reading error
predictivity(fit)                          # per-sample predictivity
```
