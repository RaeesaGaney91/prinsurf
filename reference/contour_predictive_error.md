# Contour reading error

For each variable, the root-mean-square difference between the value
read from the variable's contour lines at each sample's biplot position
(as
[`predict.prinsurf`](https://raeesaganey91.github.io/prinsurf/reference/predict.prinsurf.md)
does) and the sample's actual value. This measures how accurately a
variable can be recovered by reading its contours, combining the
surface's lack of fit for that variable with the small loss from
interpolating between contour lines; lower is better, in the units of
the working data. Samples that fall outside the supported part of the
contour grid cannot be read and are excluded; their number is returned
as the attribute `"n.unread"`.

## Usage

``` r
contour_predictive_error(object)
```

## Arguments

- object:

  A `"prinsurf"` object.

## Value

A named numeric vector of per-variable RMS contour-reading errors, with
the mean over all variables as the attribute `"overall"` and the number
of unreadable samples as the attribute `"n.unread"`.

## See also

[`predictivity`](https://raeesaganey91.github.io/prinsurf/reference/predictivity.md)
for whole-sample reconstruction.
