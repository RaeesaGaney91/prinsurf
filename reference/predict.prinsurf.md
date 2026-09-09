# Predict all variables from the biplot contours

Reads every variable's value for every sample off that variable's
contour lines at the sample's biplot position \\\lambda_i\\ – the same
interpolation used to draw the contours in
[`plot.prinsurf`](https://raeesaganey91.github.io/prinsurf/reference/plot.prinsurf.md).
Values come from the contour grid alone: a sample whose position is not
covered by the supported part of the grid has no contours to read, and
is returned as `NA` for every variable.

## Usage

``` r
# S3 method for class 'prinsurf'
predict(object, ...)
```

## Arguments

- object:

  A `"prinsurf"` object.

- ...:

  Ignored.

## Value

An \\n \times p\\ matrix of values read from the contours, on the
variables' original scales, with `NA` rows where the biplot cannot be
read.

## See also

[`contour_predictive_error`](https://raeesaganey91.github.io/prinsurf/reference/contour_predictive_error.md)
to measure this reading against the variables' actual values, and
[`fitted.prinsurf`](https://raeesaganey91.github.io/prinsurf/reference/fitted.prinsurf.md)
for the surface's own reconstruction of the data.
