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

#' Contour reading error
#'
#' For each variable, the root-mean-square difference between the value read
#' from the variable's contour lines at each sample's biplot position (as
#' \code{\link{predict.prinsurf}} does) and the sample's actual value. This
#' measures how much is lost by reading a variable off its contours rather than
#' from the sample's full reconstructed position (see
#' \code{\link{predictivity}}); lower is better, in the units of the working
#' data.
#' @param object A \code{"prinsurf"} object.
#' @return A named numeric vector of per-variable RMS contour-reading errors,
#'   with the mean over all variables as the attribute \code{"overall"}.
#' @seealso \code{\link{predictivity}} for whole-sample reconstruction.
#' @export
contour_predictive_error <- function(object) {
  vn <- object$varnames
  out <- vapply(seq_along(vn), function(j) {
    pred <- .contour_read(object, j, object$lambda)
    sqrt(mean((object$X[, j] - pred)^2))
  }, numeric(1))
  names(out) <- vn
  attr(out, "overall") <- mean(out)
  out
}
