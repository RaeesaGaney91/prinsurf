## Evaluation grid of one variable's fitted coordinate function, used both to
## draw contours (plot.prinsurf()) and to read values from them (predict.prinsurf(),
## contour_predictive_error(), via .contour_read()). Grid nodes far from any
## sample (beyond a neighbour-density-based radius) are left NA so contours and
## reading stop at the support of the data.
.ps_grid <- function(object, var, N = 55) {
  VAR <- .ps_var(object, var)
  lam <- object$lambda
  g1 <- seq(min(lam[, 1]), max(lam[, 1]), length.out = N)
  g2 <- seq(min(lam[, 2]), max(lam[, 2]), length.out = N)
  grid <- as.matrix(expand.grid(l1 = g1, l2 = g2))
  fg <- .ps_eval(object, grid, VAR)
  rad <- 2.5 * sqrt(diff(range(lam[, 1]))^2 + diff(range(lam[, 2]))^2) / sqrt(nrow(lam))
  nn <- apply(grid, 1, function(q) sqrt(min(colSums((t(lam) - q)^2))))
  fg[nn >= rad] <- NA
  list(g1 = g1, g2 = g2, M = matrix(fg, N, N))
}

## Bilinear interpolation of a grid Mat (N x N, over g1 x g2) at point (x, y).
## NA outside the grid range or where a corner node is unsupported (NA).
.ps_bilin <- function(Mat, x, y, g1, g2) {
  N <- length(g1)
  if (is.na(x) || x < g1[1] || x > g1[N] || y < g2[1] || y > g2[N]) return(NA)
  i <- min(max(findInterval(x, g1), 1), N - 1); k <- min(max(findInterval(y, g2), 1), N - 1)
  ax <- (x - g1[i]) / (g1[i + 1] - g1[i]); ay <- (y - g2[k]) / (g2[k + 1] - g2[k])
  (1 - ax) * (1 - ay) * Mat[i, k] + ax * (1 - ay) * Mat[i + 1, k] +
    (1 - ax) * ay * Mat[i, k + 1] + ax * ay * Mat[i + 1, k + 1]
}

## Read a variable's value at 2-D coordinates L by bilinear interpolation of the
## same evaluation grid drawn as contours in plot.prinsurf() -- i.e. the value a
## reader would obtain by interpolating between the printed contour lines. Falls
## back to the exact fitted coordinate function where the grid is unsupported
## (NA neighbour, e.g. very close to the support boundary).
.contour_read <- function(object, var, L, N = 55) {
  VAR <- .ps_var(object, var)
  g <- .ps_grid(object, VAR, N = N)
  L <- matrix(L, ncol = 2)
  out <- vapply(seq_len(nrow(L)), function(i) .ps_bilin(g$M, L[i, 1], L[i, 2], g$g1, g$g2), numeric(1))
  miss <- is.na(out)
  if (any(miss)) out[miss] <- .ps_eval(object, L[miss, , drop = FALSE], VAR)
  out
}
