
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
surface <- principal.surface(X)
#> [1] 1.0000000 0.6688169 1.2841119
#> [1] 2.0000000 0.0360009 1.2378827
#> [1] 3.00000000 0.05462674 1.30550421
#> [1] 4.0000000 0.1116504 1.4512642
#> [1] 5.00000000 0.04221104 1.39000485
#> [1] 6.00000000 0.04954614 1.45887422
#> [1] 7.0000000 0.1045443 1.3063572
#> [1] 8.00000000 0.09602328 1.43179787
#> [1] 9.00000000 0.09023632 1.56099804
#> [1] 10.00000000  0.03068216  1.51310325
```

<img src="man/figures/README-example-1.png" width="100%" />

``` r
rgl.snapshot("3d_plot.png")
```

<figure>
<img src="3d_plot.png" alt="3D Plot" />
<figcaption aria-hidden="true">3D Plot</figcaption>
</figure>

## Report Bugs and Support

If you encounter any issues or have questions, please open an issue on
the GitHub repository.
