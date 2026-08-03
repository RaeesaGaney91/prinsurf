#' @export
print.prinsurf <- function(x, ...) {
  cat(sprintf("Principal surface fit: %d samples, %d variables\n",
              nrow(x$lambda), length(x$varnames)))
  cat(sprintf("  loess span %.2f, converged in %d iterations\n", x$span, x$iterations))
  cat(sprintf("  variables: %s\n", paste(x$varnames, collapse = ", ")))
  invisible(x)
}

#' Plot a principal-surface biplot
#'
#' Draws the sample coordinates. If \code{vars} is given, draws one panel per
#' named variable, each showing the sample coordinates together with that
#' variable's contour lines -- the surface's analogue of a biplot axis, read by
#' interpolating between contour lines rather than by projection onto a single
#' calibrated axis. With no \code{vars}, a single panel of sample coordinates is
#' drawn with no contours.
#'
#' @param x A \code{"prinsurf"} object.
#' @param vars Variables to contour, one panel each (default: none -- a bare
#'   scatter of sample coordinates).
#' @param group Optional factor to colour the sample points.
#' @param col_contour Colour for the contour lines.
#' @param nlevels Number of contour levels per panel.
#' @param pch,cex Point symbol and size for samples.
#' @param ... Passed to each panel's initial \code{plot}.
#' @return Invisibly, \code{vars}.
#' @export
plot.prinsurf <- function(x, vars = NULL, group = NULL,
                          col_contour = "grey40", nlevels = 6,
                          pch = 16, cex = 0.7, ...) {
  lam <- x$lambda
  rng <- apply(lam, 2, range); pad <- 0.28 * (rng[2, ] - rng[1, ])
  cols <- if (is.null(group)) "grey60" else
    grDevices::hcl.colors(nlevels(as.factor(group)), "Dark 3")[as.integer(as.factor(group))]

  npanel <- max(length(vars), 1)
  if (npanel > 1) {
    nc <- ceiling(sqrt(npanel)); nr <- ceiling(npanel / nc)
    op <- graphics::par(mfrow = c(nr, nc)); on.exit(graphics::par(op))
  }

  for (i in seq_len(npanel)) {
    v <- if (length(vars)) vars[i] else NULL
    graphics::plot(lam, pch = pch, cex = cex, col = cols, axes = FALSE,
                   xlim = rng[, 1] + c(-pad[1], pad[1]), ylim = rng[, 2] + c(-pad[2], pad[2]),
                   xlab = expression(lambda[1]), ylab = expression(lambda[2]),
                   main = if (is.null(v)) "" else v, ...)
    graphics::box()
    if (!is.null(v)) {
      g <- .ps_grid(x, v)
      graphics::contour(g$g1, g$g2, g$M, add = TRUE, col = col_contour, nlevels = nlevels,
                        lwd = 0.7, labcex = 0.6)
    }
    if (!is.null(group) && i == 1)
      graphics::legend("topright", levels(as.factor(group)),
                       col = grDevices::hcl.colors(nlevels(as.factor(group)), "Dark 3"),
                       pch = pch, bty = "n", cex = 0.7)
  }
  invisible(vars)
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

#' Predict a variable's values from the biplot
#'
#' Predicts each sample's value of \code{var} by reading it off the variable's
#' contour lines at the sample's biplot position \eqn{\lambda_i} -- the same
#' interpolation used to draw the contours in \code{\link{plot.prinsurf}}.
#' @param object A \code{"prinsurf"} object.
#' @param var Variable name or index.
#' @param ... Ignored.
#' @return A numeric vector of predicted values, one per sample, on the
#'   variable's original scale.
#' @seealso \code{\link{contour_predictive_error}} to measure this reading
#'   against the variable's actual values.
#' @export
predict.prinsurf <- function(object, var, ...) {
  VAR <- .ps_var(object, var)
  pred <- .contour_read(object, VAR, object$lambda)
  ## return on the variable's original scale (undo the centring/scaling done at fit time)
  pred * object$scale[VAR] + object$center[VAR]
}
