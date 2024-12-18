
<!-- README.md is generated from README.Rmd. Please edit that file -->

# prinsurf

<!-- badges: start -->
<!-- badges: end -->

The goal of prinsurf is to construct a principal surface to a
$p$-dimensional dataset.

## Installation

You can install the development version of prinsurf from
[GitHub](https://github.com/) with:

``` r
library(devtools)
devtools::install_github("RaeesaGaney91/prinsurf")
```

## Example

This is a basic example:

``` r
library(prinsurf)
surface <- principal.surface(iris[,1:3])
#> [1] 1.0000000 0.1863326 7.2079573
#> [1] 2.000000000 0.003988568 7.179207870
#> [1] 3.00000000 0.06336495 7.63411800
#> [1] 4.00000000 0.08301524 7.00036984
#> [1] 5.00000000 0.01244264 7.08747294
#> [1] 6.00000000 0.05079004 7.44744594
#> [1] 7.00000000 0.05868702 7.88451431
#> [1] 8.00000000 0.02749157 7.66775665
#> [1] 9.0000000 0.1244757 8.6222062
#> [1] 10.00000000  0.04449618  8.23855097
```

<img src="man/figures/README-example-1.png" width="100%" />
