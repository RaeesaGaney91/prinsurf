## ---- shared internal helpers -----------------------------------------
## Cross-cutting internals used by psaxis.R, diagnostics.R and plot.R.

## evaluate the fitted coordinate function of variable j at 2-D coordinates L
.ps_eval <- function(object, L, j) {
  L <- matrix(L, ncol = 2)
  stats::predict(object$models[[j]],
                 data.frame(l1 = L[, 1], l2 = L[, 2]))
}

## masked evaluation grid of variable VAR over the sample coordinates:
## an N x N grid spanning the lambda range, with values set to NA beyond
## a data-support radius. Returns list(g1, g2, M). Used by psaxis() for
## the gradient flow and by plot.prinsurf() for contour drawing.
.ps_grid <- function(object, VAR, N = 55) {
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

## resolve a variable given as name or index to an integer column
.ps_var <- function(object, var) {
  if (is.character(var)) {
    v <- match(var, object$varnames)
    if (is.na(v)) stop("Unknown variable: ", var)
    v
  } else {
    v <- as.integer(var)
    if (v < 1 || v > length(object$varnames)) stop("Variable index out of range.")
    v
  }
}

## orthogonal-projection reading of samples onto a calibrated axis
.proj_pred <- function(A, cal, pts) {
  vapply(seq_len(nrow(pts)), function(i) {
    P <- pts[i, ]; best <- Inf; val <- NA
    for (s in 1:(nrow(A) - 1)) {
      a <- A[s, ]; b <- A[s + 1, ]; ab <- b - a; L2 <- sum(ab^2); if (L2 == 0) next
      ta <- max(0, min(1, sum((P - a) * ab) / L2)); pr <- a + ta * ab; dd <- sum((P - pr)^2)
      if (dd < best) { best <- dd; val <- cal[s] + ta * (cal[s + 1] - cal[s]) }
    }
    val
  }, numeric(1))
}
