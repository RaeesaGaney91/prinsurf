# Fitted (reconstructed) values from a principal surface

Returns the fitted surface values \\\hat f_j(\lambda_i)\\ for every
sample and variable: the point on the surface at which sample \\i\\
sits, written back in the coordinates of the original variables. Row
\\i\\ is the surface's reconstruction of sample \\i\\ – what the fit
says the sample would be if it lay exactly on the surface – and the
residual \\x_i - \hat f(\lambda_i)\\ is the part of the sample the
surface does not capture, which is what
[`predictivity`](https://raeesaganey91.github.io/prinsurf/reference/predictivity.md)
summarises.

## Usage

``` r
# S3 method for class 'prinsurf'
fitted(object, ...)
```

## Arguments

- object:

  A `"prinsurf"` object.

- ...:

  Ignored.

## Value

An \\n \times p\\ matrix of fitted values, in working (centred,
optionally scaled) units.

## Details

Values are in the working units used for fitting: centred, and divided
by each variable's standard deviation if the surface was fitted with
`scale = TRUE`. This is the scale on which residuals and
[`predictivity`](https://raeesaganey91.github.io/prinsurf/reference/predictivity.md)
are computed.
[`predict.prinsurf`](https://raeesaganey91.github.io/prinsurf/reference/predict.prinsurf.md)
differs in two ways: it reads values off the plotted contour grid rather
than evaluating the coordinate functions exactly, and it returns them on
the variables' original scales.

## See also

[`predictivity`](https://raeesaganey91.github.io/prinsurf/reference/predictivity.md)
for the per-sample quality of this reconstruction, and
[`predict.prinsurf`](https://raeesaganey91.github.io/prinsurf/reference/predict.prinsurf.md)
for the values a reader obtains from the contours.
