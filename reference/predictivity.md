# Sample predictivity of a principal-surface biplot

For each sample, the proportion of its squared length reconstructed by
the fitted surface, \\1 - \lVert x_i - \hat f(\lambda_i) \rVert^2 /
\lVert x_i \rVert^2\\. This is the principal-surface analogue of biplot
sample predictivity and is read from the sample's position on the
surface.

## Usage

``` r
predictivity(object)
```

## Arguments

- object:

  A `"prinsurf"` object.

## Value

A numeric vector of per-sample predictivities (with the overall mean as
the attribute `"overall"`).
