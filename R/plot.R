#' Plot a principal-surface biplot
#'
#' Draws the sample coordinates with calibrated gradient-flow axes for the
#' monotone variables. Axis tick marks and contour levels are labelled in each
#' variable's original units (the centring and scaling applied at fit time are
#' undone for display), matching the values returned by
#' \code{\link{predict.prinsurf}}. Variables that are deferred (interior extremum or low
#' coverage) are not drawn as axes; their contour lines can be overlaid via
#' \code{contours} instead.
#'
#' @param x A \code{"prinsurf"} object.
#' @param vars Variables to draw axes for. If omitted, axes are drawn for all
#'   variables; if \code{NULL}, no axes are drawn and only the samples (and any
#'   requested contours) are shown.
#' @param group Optional factor to colour the sample points.
#' @param contours Contour lines to overlay. Either a character vector of
#'   variable names, whose contours are overlaid on the single biplot (each
#'   set labelled with its variable name at its maximum), or \code{TRUE},
#'   which draws a multi-panel display with one panel per variable showing
#'   the samples and that variable's contours (no axes are drawn in this
#'   mode). Combine with \code{vars = NULL} to show only the samples and the
#'   requested contours, e.g. \code{plot(fit, vars = NULL, contours = "x")}.
#' @param col_axis Colour for the axes.
#' @param col_contour Colour(s) for the contour lines and their name labels,
#'   recycled across the contour variables. Default: \code{"grey40"} for a
#'   single contour variable, or a qualitative palette
#'   (\code{hcl.colors(k, "Dark 2")}) when several are drawn. Ignored for a
#'   variable when \code{col_by_level = TRUE}.
#' @param col_by_level Logical; if \code{TRUE}, contour lines are coloured by
#'   their marker value through \code{level_pal} (colour encodes the
#'   calibration, low to high), instead of the single \code{col_contour}
#'   colour. Only the calibrated lines are coloured; the plane between them is
#'   left blank.
#' @param level_pal Name of a sequential \code{\link[grDevices]{hcl.colors}}
#'   palette used when \code{col_by_level = TRUE} (default \code{"YlOrRd"},
#'   light = low, intense = high).
#' @param n_contours Number of contour levels to draw (default 10).
#' @param pch,cex Point symbol and size for samples.
#' @param defer,cover_min,delta Passed to \code{\link{psaxis}} for each axis;
#'   see there for details.
#' @param ... Passed to the initial \code{plot}.
#' @return Invisibly, a character vector of the variables that were deferred
#'   (empty in the multi-panel contour mode, where no axes are attempted).
#' @export
plot.prinsurf <- function(x, vars, group = NULL, contours = NULL,
                          col_axis = "grey25", col_contour = NULL,
                          col_by_level = FALSE, level_pal = "YlOrRd", n_contours = 10,
                          pch = 16, cex = 0.7,
                          defer = TRUE, cover_min = 0.55, delta = 0.05, ...) {
  lam <- x$lambda
  if (missing(vars)) vars <- x$varnames
  if (is.null(vars)) vars <- character(0)
  if (isFALSE(contours)) contours <- NULL
  if (isTRUE(contours)) contours <- x$varnames
  if (length(contours)) {
    col_contour <- if (is.null(col_contour)) {
      if (length(contours) > 1) grDevices::hcl.colors(length(contours), "Dark 2")
      else "grey40"
    } else rep_len(col_contour, length(contours))
  }
  rng <- apply(lam, 2, range); pad <- 0.28 * (rng[2, ] - rng[1, ])
  xlim <- rng[, 1] + c(-pad[1], pad[1]); ylim <- rng[, 2] + c(-pad[2], pad[2])
  gf <- if (is.null(group)) NULL else as.factor(group)
  cols <- if (is.null(gf)) "grey60" else
    grDevices::hcl.colors(nlevels(gf), "Dark 3")[as.integer(gf)]

  ## multi-panel contour mode: one panel per variable, samples + contours
  if (length(contours) > 1) {
    nr <- floor(sqrt(length(contours))); nc <- ceiling(length(contours) / nr)
    op <- graphics::par(mfrow = c(nr, nc), mar = c(3.5, 3.5, 2, 1),
                        mgp = c(2.1, 0.7, 0))
    on.exit(graphics::par(op), add = TRUE)
    for (k in seq_along(contours)) {
      VAR <- .ps_var(x, contours[k])
      g <- .ps_grid(x, VAR)
      M <- g$M * x$scale[VAR] + x$center[VAR]   # display in original units
      graphics::plot(lam, type = "n", xlim = xlim, ylim = ylim,
                     main = x$varnames[VAR], axes = FALSE,
                     xlab = "", ylab = "", ...)
      graphics::points(lam, pch = pch, cex = cex, col = cols)
      graphics::box()
      .draw_contours(g$g1, g$g2, M, n_contours, col_by_level, level_pal,
                     col_contour[k], lwd = 0.7, labcex = 0.6)
    }
    if (!is.null(gf))
      graphics::legend("topright", levels(gf),
                       col = grDevices::hcl.colors(nlevels(gf), "Dark 3"),
                       pch = pch, bty = "n", cex = 0.8)
    return(invisible(character(0)))
  }

  ## single-panel biplot: samples, optional single-variable contours, axes
  graphics::plot(lam, type = "n", xlim = xlim, ylim = ylim,
                 axes = FALSE, xlab = "", ylab = "", ...)
  graphics::points(lam, pch = pch, cex = cex, col = cols)
  graphics::box()
  if (length(contours)) for (k in seq_along(contours)) {
    VAR <- .ps_var(x, contours[k])
    g <- .ps_grid(x, VAR)
    M <- g$M * x$scale[VAR] + x$center[VAR]   # display in original units
    .draw_contours(g$g1, g$g2, M, n_contours, col_by_level, level_pal,
                   col_contour[k], lwd = 0.6, labcex = 0.5)
    ## name the contour set at its maximum -- with no calibrated axis on the
    ## plot, nothing else identifies which variable the contours belong to
    im <- which(M == max(M, na.rm = TRUE), arr.ind = TRUE)[1, ]
    graphics::text(g$g1[im[1]], g$g2[im[2]], x$varnames[VAR],
                   col = if (col_by_level) "grey30" else col_contour[k],
                   font = 3, cex = 0.7)
  }
  deferred <- character(0)
  for (v in vars) {
    ax <- psaxis(x, v, defer = defer, cover_min = cover_min, delta = delta)
    if (isTRUE(ax$monotone)) {
      VAR <- .ps_var(x, v)
      ax$cal <- ax$cal * x$scale[VAR] + x$center[VAR]  # ticks in original units
      .draw_axis(ax, x$varnames[VAR], col = col_axis)
    } else deferred <- c(deferred, v)
  }
  if (!is.null(gf))
    graphics::legend("topright", levels(gf),
                     col = grDevices::hcl.colors(nlevels(gf), "Dark 3"),
                     pch = pch, bty = "n", cex = 0.8)
  invisible(deferred)
}

## ---- internal plotting helpers --------------------------------------

## locate calibration markers mu along an axis polyline; returns, for each
## marker inside the axis range, its point, unit normal and value
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

## draw contour lines of a field M, either in one colour or coloured by level
## through a sequential palette (colour = calibration). Levels are the pretty
## values of M so the mapping is stable across panels of the same variable.
.draw_contours <- function(g1, g2, M, n_contours, by_level, pal, col1,
                           lwd = 0.6, labcex = 0.5) {
  lev <- pretty(range(M, na.rm = TRUE), n_contours)
  lev <- lev[lev > min(M, na.rm = TRUE) & lev < max(M, na.rm = TRUE)]
  if (length(lev) == 0) return(invisible())
  col <- if (by_level) grDevices::hcl.colors(length(lev), pal, rev = TRUE)
         else rep(col1, length(lev))
  graphics::contour(g1, g2, M, add = TRUE, levels = lev, col = col,
                    lwd = lwd, labcex = labcex)
}

## draw one calibrated axis: polyline, tick marks at pretty values, name label
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
