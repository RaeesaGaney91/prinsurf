
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
#> [1] 1.0000000 0.7828242 1.0170291
#> [1] 2.0000000 0.1043076 0.9109452
#> [1] 3.00000000 0.01774763 0.92711236
#> [1] 4.00000000 0.03854133 0.89138021
#> [1] 5.00000000 0.03291638 0.92072123
#> [1] 6.00000000 0.01574138 0.90622781
#> [1] 7.00000000 0.06762219 0.96750891
#> [1] 8.00000000 0.01082235 0.95703820
#> [1] 9.00000000 0.01906273 0.93879443
#> [1] 10.000000000  0.004525712  0.934545720
```

<img src="man/figures/README-example-1.png" width="100%" />

    #> Warning in snapshot3d(scene = x, width = width, height = height): webshot =
    #> TRUE requires the webshot2 package and Chrome browser; using rgl.snapshot()
    #> instead

<img src="../../../../../../private/var/folders/rt/kyvx8b4s3tz_8rwvs23fcxmr0000gn/T/RtmptL4mkz/file7f092f09b105.png" width="100%" />

## Report Bugs and Support

If you encounter any issues or have questions, please open an issue on
the GitHub repository.
