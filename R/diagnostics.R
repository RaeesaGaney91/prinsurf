#' Maximum turning angle of an axis
#'
#' Returns the largest turning angle (in degrees) between successive segments of
#' an axis after resampling to equal arc length, a measure of how kinked the axis
#' is. A smooth gradient-flow axis has a small value; an independent-marker
#' back-projection axis has large kinks.
#' @param A An \eqn{m \times 2} matrix of axis vertices (e.g. \code{psaxis(...)$axis}).
#' @return The maximum turning angle in degrees, or \code{NA} if undefined.
#' @export
kink_max <- function(A) {
  if (is.null(A) || nrow(A) < 3) return(NA_real_)
  A <- A[c(TRUE, rowSums(abs(diff(A))) > 1e-9), , drop = FALSE]
  if (nrow(A) < 3) return(NA_real_)
  d <- sqrt(rowSums(diff(A)^2)); s <- c(0, cumsum(d)) / sum(d)
  su <- seq(0, 1, length.out = 100)
  Ar <- cbind(stats::approx(s, A[, 1], su, ties = "ordered")$y,
              stats::approx(s, A[, 2], su, ties = "ordered")$y)
  dd <- diff(Ar); ang <- atan2(dd[, 2], dd[, 1]); da <- abs(diff(ang))
  max(pmin(da, 2 * pi - da)) * 180 / pi
}

#' Sample predictivity of a principal-surface biplot
#'
#' For each sample, the proportion of its squared length reconstructed by the
#' fitted surface, \eqn{1 - \lVert x_i - \hat f(\lambda_i) \rVert^2 /
#' \lVert x_i \rVert^2}. This is the principal-surface analogue of biplot sample
#' predictivity and is read from the sample's position on the surface.
#' @param object A \code{"prinsurf"} object.
#' @return A numeric vector of per-sample predictivities (with the overall mean as
#'   the attribute \code{"overall"}).
#' @export
predictivity <- function(object) {
  X <- object$X                       # working (centred / scaled) data
  Xhat <- fitted(object)
  Xc <- scale(X, scale = FALSE)
  sst <- rowSums(Xc^2)
  pred <- 1 - rowSums((X - Xhat)^2) / sst
  attr(pred, "overall") <- mean(pred)
  pred
}

#' Axis predictivity of a principal-surface biplot
#'
#' For each variable that receives a calibrated gradient-flow axis, the proportion
#' of its variance recovered by orthogonally projecting the samples onto that axis
#' and reading the calibration, \eqn{1 - \sum_i (x_{ij} - \hat x_{ij})^2 /
#' \sum_i (x_{ij} - \bar x_j)^2}. Deferred variables (no axis) are returned as
#' \code{NA}, since they are read from contours rather than an axis.
#' @param object A \code{"prinsurf"} object.
#' @return A named numeric vector of per-variable axis predictivities, with the
#'   mean over non-deferred variables as the attribute \code{"overall"}.
#' @seealso \code{\link{predictivity}} for sample predictivity.
#' @export
axis_predictivity <- function(object) {
  vn <- object$varnames
  out <- vapply(seq_along(vn), function(j) {
    ax <- psaxis(object, j)
    if (!isTRUE(ax$monotone)) return(NA_real_)
    pred <- .proj_pred(ax$axis, ax$cal, object$lambda)
    x <- object$X[, j]
    1 - sum((x - pred)^2) / sum((x - mean(x))^2)
  }, numeric(1))
  names(out) <- vn
  attr(out, "overall") <- mean(out, na.rm = TRUE)
  out
}
