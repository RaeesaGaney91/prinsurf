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
  X <- object$X                       # working data, already centred (and scaled)
  Xhat <- fitted(object)
  pred <- 1 - rowSums((X - Xhat)^2) / rowSums(X^2)
  attr(pred, "overall") <- mean(pred)
  pred
}

#' Standard predictive error of biplot axes
#'
#' For each variable that receives a calibrated gradient-flow axis, the
#' root-mean-square difference between the value obtained by orthogonally
#' projecting each sample onto the axis and the variable's true value. This is the
#' per-axis mean standard predictive error of the predictive-biplot tradition
#' (Gower and coworkers); lower is better, in the units of the working data.
#' Deferred variables (read from contours, no axis) are returned as \code{NA}.
#' @param object A \code{"prinsurf"} object.
#' @return A named numeric vector of per-axis RMS predictive errors, with the mean
#'   over non-deferred axes as the attribute \code{"overall"}.
#' @seealso \code{\link{predictivity}} for sample predictivity.
#' @export
axis_predictive_error <- function(object) {
  vn <- object$varnames
  out <- vapply(seq_along(vn), function(j) {
    ax <- psaxis(object, j)
    if (!isTRUE(ax$monotone)) return(NA_real_)
    pred <- .proj_pred(ax$axis, ax$cal, object$lambda)
    sqrt(mean((object$X[, j] - pred)^2))
  }, numeric(1))
  names(out) <- vn
  attr(out, "overall") <- mean(out, na.rm = TRUE)
  out
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
