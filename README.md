
<!-- README.md is generated from README.Rmd. Please edit that file -->

# prinsurf

<!-- badges: start -->
<!-- badges: end -->

The goal of prinsurf is to construct a principal surfaces that are
two-dimensional surfaces that pass through the middle of a
$p$-dimensional dataset.

## Installation

You can install the development version of prinsurf from
[GitHub](https://github.com/) with:

``` r
library(devtools)
devtools::install_github("RaeesaGaney91/prinsurf")
```

## Example

This is a basic example on a simulated data set:

``` r
library(prinsurf)
library(rgl)
surface <- principal.surface(X)
#> [1] 1.0000000 0.7552702 1.0275726
#> [1] 2.00000000 0.06922002 0.95644399
#> [1] 3.0000000 0.0153415 0.9417707
#> [1] 4.00000000 0.04627398 0.98535019
#> [1] 5.00000000 0.02334001 0.96235211
#> [1] 6.000000000 0.008327922 0.954337712
#> [1] 7.000000000 0.003055226 0.951421995
#> [1] 8.00000000 0.00951877 0.96047836
#> [1] 9.00000000 0.01086723 0.97091610
#> [1] 10.0000000  0.0109745  0.9815714
```

<img src="man/figures/README-example-1.png" width="100%" />

    #> Warning in snapshot3d(scene = x, width = width, height = height): webshot =
    #> TRUE requires the webshot2 package and Chrome browser; using rgl.snapshot()
    #> instead

<img src="../../../../../../private/var/folders/rt/kyvx8b4s3tz_8rwvs23fcxmr0000gn/T/Rtmps0iMk9/file7d036a53b63d.png" width="100%" />

## Report Bugs and Support

If you encounter any issues or have questions, please open an issue on
the GitHub repository.
