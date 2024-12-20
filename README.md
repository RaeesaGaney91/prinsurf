
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
#> [1] 1.0000000 0.8050027 0.9828361
#> [1] 2.00000000 0.05651982 0.92728639
#> [1] 3.0000000 0.1133866 0.8221446
#> [1] 4.0000000 0.0140032 0.8106319
#> [1] 5.000000000 0.007191001 0.804802647
#> [1] 6.00000000 0.05562977 0.84957363
#> [1] 7.00000000 0.02563281 0.87135060
#> [1] 8.000000000 0.007452823 0.864856574
#> [1] 9.00000000 0.01939636 0.88163164
#> [1] 10.000000000  0.008002025  0.874576806
```

<img src="man/figures/README-example-1.png" width="100%" />

    #> Warning in snapshot3d(scene = x, width = width, height = height): webshot =
    #> TRUE requires the webshot2 package and Chrome browser; using rgl.snapshot()
    #> instead

<img src="../../../../../../private/var/folders/rt/kyvx8b4s3tz_8rwvs23fcxmr0000gn/T/RtmpqXE9Tf/file80a54a62415f.png" width="100%" />

    #> Warning in writeWebGL(dir = "docs", filename = "docs/surface3d.html"): 'writeWebGL' is deprecated.
    #> Use 'rglwidget' instead.
    #> See help("Deprecated")
    #> Warning in writeWebGL(dir = "docs", filename = "docs/surface3d.html"): webshot = TRUE requires the webshot2 package and Chrome browser; using rgl.snapshot() instead

[View Interactive 3D Surface
Plot](https://RaeesaGaney91.github.io/prinsurf/surface3d.html)

## Report Bugs and Support

If you encounter any issues or have questions, please open an issue on
the GitHub repository.
