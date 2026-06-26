#' Gradient-flow biplot axis for one variable
#'
#' Constructs the calibrated gradient-flow axis for a single variable of a fitted
#' principal surface: the steepest-ascent trajectory of the variable's fitted
#' coordinate function, started from the centroid of the sample coordinates. The
#' axis is smooth, crosses the variable's contours orthogonally, and carries a
#' monotone calibration. A variable is deferred (no axis) when its fitted value
#' has an interior extremum beyond the support boundary (Criterion 1) or when the
#' constructed axis spans too little of the variable's range (Criterion 2); such
#' variables are read from contour lines instead.
#'
#' @param object A \code{"prinsurf"} object.
#' @param var Variable name or column index.
#' @param N Grid resolution for evaluating the coordinate function and gradient.
#' @param h Integration step for the gradient flow.
#' @param steps Maximum number of integration steps in each direction.
#' @param delta Boundary-extremum margin, as a fraction of the value range.
#' @param cover_min Minimum fraction of the variable's range the axis must span.
#' @param defer Logical; if FALSE, deferral is switched off and a calibrated
#'   axis is returned for every variable that yields a non-degenerate flow
#'   (Criteria 1 and 2 are not applied).
#'
#' @return An object of class \code{"psaxis"}: a list with \code{axis} (an
#'   \eqn{m \times 2} matrix of axis vertices, or \code{NULL} if deferred),
#'   \code{cal} (the calibration value at each vertex), \code{monotone} (logical;
#'   \code{FALSE} when deferred), \code{coverage}, \code{var}, and the evaluation
#'   grid \code{g1}, \code{g2}, \code{M} used for drawing contours.
#'
#' @examples
#' set.seed(1)
#' s <- runif(120, -1, 1); t <- runif(120, -1, 1)
#' X <- cbind(x = s, y = t, z = 0.7 * s + 0.9 * t^2) +
#'      matrix(rnorm(360, 0, 0.03), 120, 3)
#' fit <- prinsurf(X, max.iter = 6)
#' ax <- psaxis(fit, "z")
#' ax$monotone
#' @export
psaxis <- function(object, var, N = 55, h = 0.03, steps = 800,
                   delta = 0.10, cover_min = 0.55, defer = TRUE) {
  stopifnot(inherits(object, "prinsurf"))
  VAR <- .ps_var(object, var)
  lam <- object$lambda
  g1 <- seq(min(lam[, 1]), max(lam[, 1]), length.out = N)
  g2 <- seq(min(lam[, 2]), max(lam[, 2]), length.out = N)
  grid <- as.matrix(expand.grid(l1 = g1, l2 = g2))
  fg <- .ps_eval(object, grid, VAR)
  rad <- 2.5 * sqrt(diff(range(lam[, 1]))^2 + diff(range(lam[, 2]))^2) / sqrt(nrow(lam))
  nn <- apply(grid, 1, function(q) sqrt(min(colSums((t(lam) - q)^2))))
  fg[nn >= rad] <- NA
  M <- matrix(fg, N, N)
  gx <- gy <- matrix(NA, N, N)
  for (i in 2:(N - 1)) for (k in 2:(N - 1)) {
    gx[i, k] <- (M[i + 1, k] - M[i - 1, k]) / (g1[i + 1] - g1[i - 1])
    gy[i, k] <- (M[i, k + 1] - M[i, k - 1]) / (g2[k + 1] - g2[k - 1])
  }
  mk_defer <- function(cov = NA)
    structure(list(axis = NULL, cal = NULL, monotone = FALSE, coverage = cov,
                   var = object$varnames[VAR], g1 = g1, g2 = g2, M = M),
              class = "psaxis")

  ## Criterion 1: interior extremum beyond the support boundary
  sup <- !is.na(M); bnd <- matrix(FALSE, N, N)
  for (i in 1:N) for (k in 1:N) {
    if (!sup[i, k]) next
    if (i == 1 || i == N || k == 1 || k == N) { bnd[i, k] <- TRUE; next }
    if (!sup[i - 1, k] || !sup[i + 1, k] || !sup[i, k - 1] || !sup[i, k + 1])
      bnd[i, k] <- TRUE
  }
  intr <- sup & !bnd; rngM <- diff(range(M, na.rm = TRUE))
  if (defer && any(intr) && any(bnd) &&
      ((max(M[intr]) > max(M[bnd]) + delta * rngM) ||
       (min(M[intr]) < min(M[bnd]) - delta * rngM)))
    return(mk_defer())

  ## gradient flow (RK4) from the supported node nearest the centroid
  bilin <- function(Mat, x, y) {
    if (is.na(x) || x < g1[1] || x > g1[N] || y < g2[1] || y > g2[N]) return(NA)
    i <- min(max(findInterval(x, g1), 1), N - 1); k <- min(max(findInterval(y, g2), 1), N - 1)
    ax <- (x - g1[i]) / (g1[i + 1] - g1[i]); ay <- (y - g2[k]) / (g2[k + 1] - g2[k])
    (1 - ax) * (1 - ay) * Mat[i, k] + ax * (1 - ay) * Mat[i + 1, k] +
      (1 - ax) * ay * Mat[i, k + 1] + ax * ay * Mat[i + 1, k + 1]
  }
  gu <- function(P) {
    v <- c(bilin(gx, P[1], P[2]), bilin(gy, P[1], P[2]))
    if (any(is.na(v))) return(NULL)
    nv <- sqrt(sum(v^2)); if (nv < 1e-6) return(NULL)
    v / nv
  }
  flow <- function(st, dir) {
    pa <- matrix(st, 1, 2); P <- st
    for (s in 1:steps) {
      k1 <- gu(P);              if (is.null(k1)) break
      k2 <- gu(P + dir * h / 2 * k1); if (is.null(k2)) break
      k3 <- gu(P + dir * h / 2 * k2); if (is.null(k3)) break
      k4 <- gu(P + dir * h * k3);     if (is.null(k4)) break
      P <- P + dir * h / 6 * (k1 + 2 * k2 + 2 * k3 + k4); pa <- rbind(pa, P)
    }
    pa
  }
  vg <- which(!is.na(gx) & !is.na(gy), arr.ind = TRUE)
  if (nrow(vg) == 0) return(mk_defer())
  gpts <- cbind(g1[vg[, 1]], g2[vg[, 2]])
  st <- gpts[which.min(rowSums(sweep(gpts, 2, colMeans(lam))^2)), ]
  fw <- flow(st, +1); bw <- flow(st, -1)
  axis <- rbind(fw[nrow(fw):1, , drop = FALSE], bw[-1, , drop = FALSE])
  if (nrow(axis) > 2)
    axis <- axis[c(TRUE, rowSums(abs(diff(axis))) > 1e-6), , drop = FALSE]
  if (nrow(axis) < 3) return(mk_defer(0))
  cal <- .ps_eval(object, axis, VAR)

  ## Criterion 2: the axis must span the variable's range over the samples
  fsamp <- .ps_eval(object, lam, VAR)
  coverage <- diff(range(cal)) / diff(range(fsamp))
  if (defer && is.finite(coverage) && coverage < cover_min) return(mk_defer(coverage))

  structure(list(axis = axis, cal = cal, monotone = TRUE, coverage = coverage,
                 var = object$varnames[VAR], g1 = g1, g2 = g2, M = M),
            class = "psaxis")
}

#' @export
print.psaxis <- function(x, ...) {
  if (isTRUE(x$monotone))
    cat(sprintf("psaxis for '%s': calibrated axis, %d vertices, range [%.2f, %.2f], coverage %.2f\n",
                x$var, nrow(x$axis), min(x$cal), max(x$cal), x$coverage))
  else
    cat(sprintf("psaxis for '%s': deferred to contour reading (coverage %s)\n",
                x$var, ifelse(is.na(x$coverage), "NA", sprintf("%.2f", x$coverage))))
  invisible(x)
}
