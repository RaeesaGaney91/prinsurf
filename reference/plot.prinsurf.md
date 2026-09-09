# Plot a principal-surface biplot

Draws the sample coordinates. If `vars` is given, draws one panel per
named variable, each showing the sample coordinates together with that
variable's contour lines - the surface's analogue of a biplot axis, read
by interpolating between contour lines rather than by projection onto a
single calibrated axis. With no `vars`, a single panel of sample
coordinates is drawn with no contours.

## Usage

``` r
# S3 method for class 'prinsurf'
plot(
  x,
  vars = NULL,
  group = NULL,
  col_contour = "grey40",
  nlevels = 6,
  pch = 16,
  cex = 0.7,
  asp = 1,
  ...
)
```

## Arguments

- x:

  A `"prinsurf"` object.

- vars:

  Variables to contour, one panel each (default: none – a bare scatter
  of sample coordinates).

- group:

  Optional factor to colour the sample points.

- col_contour:

  Colour for the contour lines.

- nlevels:

  Number of contour levels per panel.

- pch, cex:

  Point symbol and size for samples.

- asp:

  Aspect ratio of each panel; the default `1` keeps the two surface
  coordinates on a common scale, so distances in the biplot are
  comparable in every direction.

- ...:

  Passed to each panel's initial `plot`.

## Value

Invisibly, `vars`.
