#' Posterior predictive plot comparing the outcome standard deviation vs the distribution of the predicted posterior standard deviations.
#'
#' Histogram with the distribution of the predicted posterior standard deviations, compared with the standard deviations of the observed outcome.
#'
#' @references Fernández-i-Marín, Xavier (2016) ggmcmc: Analysis of MCMC Samples and Bayesian Inference. Journal of Statistical Software, 70(9), 1-20. doi:10.18637/jss.v070.i09
#' @param D Data frame whith the simulations. Notice that only the posterior outcomes are needed, and so either the ggs() call limits the parameters to the outcomes or the user provides a family of parameters to limit it.
#' @param outcome vector (or matrix or array) containing the observed outcome variable. Currently only a vector is supported.
#' @param family Name of the family of parameters to plot, as given by a character vector or a regular expression. A family of parameters is considered to be any group of parameters with the same name but different numerical value between square brackets (as beta[1], beta[2], etc). 
#' @param bins integer indicating the total number of bins in which to divide the histogram. Defaults to 30, which is the same as geom_histogram()
#' 
#' @return A \code{ggplot} object.
#' @export
#' @examples
#' data(linear)
#' ggs_ppsd(ggs(s.y.rep), outcome=y)
ggs_ppsd <- function(D, outcome, family=NA, bins=30) {
  # Manage subsetting a family of parameters
  if (!is.na(family)) {
    D <- get_family(D, family=family)
  }
  # Check that the lengths of the outcome and the predicted posterior are equal
  lo <- length(outcome)
  lpp <- attributes(D)$nParameters
  if (lo != lpp) {
    stop("The length of the outcome must be equal to the number of Parameters of the ggs object.")
  }
  # Calculate the posterior predictive means at each iteration
  ppSD <- D %>%
    dplyr::group_by(Iteration) %>%
    dplyr::summarize(sd=sd(value))
  sd <- sd(outcome, na.rm=TRUE)
  # Calculate binwidths
  ppSDbw <- calc_bin(ppSD$sd, bins=bins)
  names(ppSDbw)[names(ppSDbw)=="x"] <- "Posterior predictive standard deviation"
  # Plot
  f <- ggplot(ppSDbw, aes(xmin = `Posterior predictive standard deviation`,
                          xmax = `Posterior predictive standard deviation` + width,
                          ymin = 0, ymax = count)) +
    geom_rect() +
    xlab("Posterior predictive mean") + ylab("count") +
    geom_vline(xintercept=sd)
  return(f)
}
