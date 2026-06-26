#' @export
print.prinsurf <- function(x, ...) {
  cat(sprintf("Principal surface fit: %d samples, %d variables\n",
              nrow(x$lambda), length(x$varnames)))
  cat(sprintf("  loess span %.2f, converged in %d iterations\n", x$span, x$iterations))
  cat(sprintf("  variables: %s\n", paste(x$varnames, collapse = ", ")))
  invisible(x)
}

## ---- internal plotting helpers --------------------------------------
.axis_markers <- function(axis, cal, mu) {
  out <- lapply(mu, function(m) {
    for (i in 1:(nrow(axis) - 1)) {
      lo <- min(cal[i], cal[i + 1]); hi <- max(cal[i], cal[i + 1])
      if (hi > lo && m >= lo && m <= hi) {
        f <- (m - cal[i]) / (cal[i + 1] - cal[i]); pt <- axis[i, ] + f * (axis[i + 1, ] - axis[i, ])
        tg <- axis[i + 1, ] - axis[i, ]; tg <- tg / sqrt(sum(tg^2))
        return(list(pt = pt, nrm = c(-tg[2], tg[1]), val = m))
      }
    }
    NULL
  })
  out[!vapply(out, is.null, logical(1))]
}

.draw_axis <- function(ax, name, col = "grey25", tick = 0.05, n = 5) {
  graphics::lines(ax$axis, col = col, lwd = 1.9)
  mu <- pretty(range(ax$cal), n); mu <- mu[mu > min(ax$cal) & mu < max(ax$cal)]
  for (m in .axis_markers(ax$axis, ax$cal, mu)) {
    p <- m$pt; nv <- m$nrm * tick
    graphics::segments(p[1] - nv[1], p[2] - nv[2], p[1] + nv[1], p[2] + nv[2], col = col, lwd = 1.4)
    graphics::text(p[1] + 1.7 * nv[1], p[2] + 1.7 * nv[2], formatC(m$val, format = "g", digits = 2),
                   col = col, cex = 0.6)
  }
  tip <- ax$axis[which.max(ax$cal), ]
  graphics::text(tip[1], tip[2], name, col = col, font = 2, cex = 0.7, pos = 4, offset = 0.25)
}

#' Plot a principal-surface biplot
#'
#' Draws the sample coordinates with calibrated gradient-flow axes for the
#' monotone variables. Variables that are deferred (interior extremum or low
#' coverage) are not drawn as axes; pass their names to \code{contours} to overlay
#' their contour lines instead.
#'
#' @param x A \code{"prinsurf"} object.
#' @param vars Variables to draw axes for (default: all).
#' @param group Optional factor to colour the sample points.
#' @param contours Optional variable name(s) whose contour lines to overlay.
#' @param col_axis Colour for the axes.
#' @param pch,cex Point symbol and size for samples.
#' @param ... Passed to the initial \code{plot}.
#' @return Invisibly, a character vector of the variables that were deferred.
#' @export
plot.prinsurf <- function(x, vars = NULL, group = NULL, contours = NULL,
                          col_axis = "grey25", pch = 16, cex = 0.7,
                          defer = TRUE, cover_min = 0.55, delta = 0.05, ...) {
  lam <- x$lambda
  if (is.null(vars)) vars <- x$varnames
  rng <- apply(lam, 2, range); pad <- 0.28 * (rng[2, ] - rng[1, ])
  cols <- if (is.null(group)) "grey60" else
    grDevices::hcl.colors(nlevels(as.factor(group)), "Dark 3")[as.integer(as.factor(group))]
  graphics::plot(lam, pch = pch, cex = cex, col = cols,
                 xlim = rng[, 1] + c(-pad[1], pad[1]), ylim = rng[, 2] + c(-pad[2], pad[2]),
                 xlab = expression(lambda[1]), ylab = expression(lambda[2]), ...)
  if (!is.null(contours)) for (v in contours) {
    ax <- psaxis(x, v)
    graphics::contour(ax$g1, ax$g2, ax$M, add = TRUE, col = "grey70", nlevels = 6,
                      lwd = 0.6, labcex = 0.5)
  }
  deferred <- character(0)
  for (v in vars) {
    ax <- psaxis(x, v, defer = defer, cover_min = cover_min, delta = delta)
    if (isTRUE(ax$monotone)) .draw_axis(ax, v, col = col_axis)
    else deferred <- c(deferred, v)
  }
  if (!is.null(group))
    graphics::legend("topright", levels(as.factor(group)),
                     col = grDevices::hcl.colors(nlevels(as.factor(group)), "Dark 3"),
                     pch = pch, bty = "n", cex = 0.8)
  invisible(deferred)
}

#' Fitted (reconstructed) values from a principal surface
#'
#' Returns the fitted surface values \eqn{\hat f_j(\lambda_i)} for every sample
#' and variable -- the principal-surface reconstruction of the data, which
#' underlies its sample predictivity.
#' @param object A \code{"prinsurf"} object.
#' @param ... Ignored.
#' @return An \eqn{n \times p} matrix of fitted values.
#' @export
fitted.prinsurf <- function(object, ...) {
  p <- length(object$varnames)
  out <- vapply(seq_len(p), function(j) .ps_eval(object, object$lambda, j),
                numeric(nrow(object$lambda)))
  colnames(out) <- object$varnames
  out
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

#' Predict a variable's values from the biplot
#'
#' For a monotone variable, predicts by orthogonally projecting each sample's
#' coordinate onto the variable's calibrated gradient-flow axis. For a deferred
#' variable (no axis), returns the surface value \eqn{\hat f_j(\lambda_i)} (the
#' contour reading), with a message.
#' @param object A \code{"prinsurf"} object.
#' @param var Variable name or index.
#' @param ... Ignored.
#' @return A numeric vector of predicted values, one per sample.
#' @export
predict.prinsurf <- function(object, var, ...) {
  VAR <- .ps_var(object, var)
  ax <- psaxis(object, VAR)
  pred <- if (isTRUE(ax$monotone)) .proj_pred(ax$axis, ax$cal, object$lambda)
  else {
    message(sprintf("'%s' is deferred (no axis); returning surface values f_hat(lambda).",
                    object$varnames[VAR]))
    .ps_eval(object, object$lambda, VAR)
  }
  ## return on the variable's original scale (undo the centring/scaling done at fit time)
  pred * object$scale[VAR] + object$center[VAR]
}
