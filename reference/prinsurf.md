# Fit a principal surface

Fits a two-dimensional principal surface to a numeric data matrix using
the iterative expectation / projection algorithm of Hastie and Stuetzle
(1989), with the coordinate functions estimated by local regression
(`loess`).

## Usage

``` r
prinsurf(X, max.iter = 10, span = 0.6, scale = FALSE, verbose = FALSE)
```

## Arguments

- X:

  A numeric matrix or data frame, \\n \times p\\. Column names are used
  as variable names; if absent, `V1, V2, ...` are assigned.

- max.iter:

  Maximum number of expectation/projection iterations.

- span:

  The `loess` span (\\\alpha\\) used for the coordinate functions.

- scale:

  Logical; if `TRUE` each variable is standardised to unit standard
  deviation before fitting (recommended when variables are on very
  different scales). Variables are always centred.

- verbose:

  Logical; print the relative change and residual sum of squares at each
  iteration.

## Value

An object of class `"prinsurf"`: a list with elements `lambda` (the \\n
\times 2\\ surface coordinates of the samples), `fj.mat` (the fitted
surface coordinates of the samples in the working units), `models` (the
per-variable `loess` coordinate functions), `varnames`, `center`,
`scale`, `span` and `iterations`.

## References

Hastie, T. and Stuetzle, W. (1989) Principal curves. *Journal of the
American Statistical Association* **84**, 502–516.

## Examples

``` r
set.seed(1)
s <- runif(120, -1, 1); t <- runif(120, -1, 1)
X <- cbind(x = s, y = t, z = 0.7 * s + 0.9 * t^2) +
     matrix(rnorm(360, 0, 0.03), 120, 3)
fit <- prinsurf(X, max.iter = 6)
fit
#> Principal surface fit: 120 samples, 3 variables
#>   loess span 0.60, converged in 4 iterations
#>   variables: x, y, z
```
