#' Generate Uniform Random Numbers Using GPU 
#'
#' This function generates random numbers from a uniform distribution.
#'
#' @param n number of observations. This must be a scalar.
#' @param min,max lower and upper bounds of the distribution. Must be finite. 
#' @param nthread number of threads launched per block. 
#' @param dp whether calculate using double precision. Default is FALSE.
#' @return a vector of random deviates.
#' @export
#' @examples
#' n <- 2^20
#' dat1 <- ppda::runif_gpu(n)
#' dat2 <- stats::runif(n)
#' den1 <- density(dat1)
#' den2 <- density(dat2)
#' 
#' ## Identical result
#' par(mfrow=c(1, 2), mar = c(4, 5.3, 0.82, 1))
#' hist(dat2, breaks = "fd", freq = FALSE, ylim = c(0, 1.1))
#' lines(den1$x, den1$y,lwd=2)
#' hist(dat1, breaks = "fd", freq = FALSE, ylim = c(0, 1.1))
#' lines(den2$x, den2$y,lwd=2)
#' par(mfrow=c(1,1))
#'
#' \dontrun{
#' require(microbenchmark)
#' res <- microbenchmark(ppda::runif_gpu(n, dp=FALSE), 
#'                       ppda::runif_gpu(n, dp=TRUE),
#'                       stats::runif(n), times=100L)
#' ## Unit: milliseconds
#' ##                        expr       min        lq      mean    median  
#' ##  ppda::runif(n, dp = FALSE)  3.960948  4.710212  5.179495  4.877518  
#' ##  ppda::runif(n, dp = TRUE)   5.876643  6.592802  7.122335  6.731998  
#' ##             stats::runif(n) 23.213792 23.983485 24.776863 24.022213 
#' ##        uq       max neval cld
#' ##  5.310155  28.70379   100   a  
#' ##  6.957797  31.85638   100   b 
#' ## 24.789670  49.04686   100   c
#' }
runif_gpu <- function(n, min = 0, max = 1, nthread = 32, dp = FALSE) {
  if ( length(min) != 1 | length(max) != 1 ) 
    stop("min and max must be a scalar!")
  .C("runif_entry", as.integer(n),  as.double(min), as.double(max),
     as.integer(nthread), as.logical(dp), numeric(n), PACKAGE = "ppda")[[6]]
}

#' Generate Gaussian Random Numbers using GPU 
#'
#' This function generates random numbers from a normal distribution.
#'
#' @param n numbers of observation. Must be a scalar
#' @param mean mean. Must be a scalar.
#' @param sd standard deviation. Must be a scalar.
#' @param nthread number of threads launched per block.
#' @param dp whether calculate using double precision. Default is FALSE.
#' @return a double vector
#' @export
#' @examples
#' n <- 2^20
#' dat1 <- ppda::rnorm_gpu(n)
#' dat2 <- stats::rnorm(n)
#' den1 <- density(dat1)
#' den2 <- density(dat2)
#' 
#' ## Identical 
#' par(mfrow=c(1, 2))
#' hist(dat2, breaks="fd", freq=FALSE)
#' lines(den1$x, den1$y,lwd=2)
#' hist(dat1, breaks="fd", freq=FALSE)
#' lines(den2$x, den2$y,lwd=2)
#' par(mfrow=c(1, 1))
#'
#' \dontrun{
#' require(microbenchmark)
#' res <- microbenchmark(ppda::rnorm_gpu(n, dp=TRUE), 
#'                       ppda::rnorm_gpu(n, dp=FALSE),
#'                       stats::rnorm(n), times=100L)
#' }
#' ## Unit: milliseconds
#' ##                     expr       min        lq      mean    median        uq
#' ## ppda::rnorm(n, dp=TRUE)   6.616550  6.845842  7.452962  6.978157  7.537696
#' ## ppda::rnorm(n, dp=FALSE)  4.002644  4.140652  4.479556  4.258824  4.752049
#' ## stats::rnorm(n)          58.169916 58.236266 59.341414 58.283129 58.880208
#' ##       max neval cld
#' ## 34.97274   100    b 
#' ## 11.70719   100    a  
#' ## 80.32002   100    c
rnorm_gpu <- function(n, mean = 0, sd = 1, nthread = 32, dp = FALSE) {
  if ( length(mean) != 1 | length(sd) != 1 )
        stop("mean and sd must be a scalar!")
  if (sd < 0) stop("sd must be greater than 0!")
  .C("rnorm_entry", as.integer(n), as.double(mean), as.double(sd),
    as.integer(nthread), as.logical(dp), numeric(n), PACKAGE = "ppda")[[6]]
}

#' Generate Random Numbers from a Truncated Normal Distribution  
#'
#' This function generates random numbers from a truncated normal 
#' distribution.
#' 
#' @param n number of observations. Must be scalar an integer
#' @param mean mean. Must be a scalar
#' @param sd standard deviations. Must be a scalar
#' @param lower lower bound. Must be a scalar
#' @param upper upper bound. Must be a scalar
#' @param nthread number of threads launched per block.
#' @param dp whether calculate using double precision. Default is FALSE.
#' @return a double vector
#' @export
#' @examples
#' n <- 2^20
#' dat1 <- ppda::rtnorm_gpu(n, mean=-1, sd=1.2, lower=0, upper=Inf)
#' 
#' \dontrun{
#' ## https://github.com/TasCL/tnorm
#' dat2 <- tnorm::rtnorm(n, mean=-1, sd=1.2, lower=0, upper=Inf)
#' dat3 <- msm::rtnorm(n, mean=-1, sd=1.2, lower=0, upper=Inf)
#' den2 <- density(dat2)
#' den3 <- density(dat3)
#' summary(dat2)
#' summary(dat3)
#' }
#' 
#' den1 <- density(dat1)
#' summary(dat1)
#' 
#' \dontrun{
#' par(mfrow=c(1,3))
#' hist(dat2, breaks="fd", freq=FALSE)
#' lines(den1$x, den1$y,lwd=2) ## gpu
#' lines(den2$x, den2$y,lwd=2) ## tnorm
#' lines(den3$x, den3$y,lwd=2) ## msn
#' 
#' hist(dat1, breaks="fd", freq=FALSE)
#' lines(den1$x, den1$y,lwd=2) ## gpu
#' lines(den2$x, den2$y,lwd=2) ## tnorm
#' lines(den3$x, den3$y,lwd=2) ## msn
#' 
#' hist(dat3, breaks="fd", freq=FALSE)
#' lines(den1$x, den1$y,lwd=2) ## gpu
#' lines(den2$x, den2$y,lwd=2) ## tnorm
#' lines(den3$x, den3$y,lwd=2) ## msn
#' par(mfrow=c(1,1))
#' }
#' 
#' ## Unit: milliseconds
#' ##            expr         min         lq       mean     median         
#' ##  ppda::rtnorm(n)   1.173537   1.417016   1.978613   1.423757   
#' ## tnorm::rtnorm(n)   7.475374   8.317984   8.544317   8.345958   
#' ##   msm::rtnorm(n)  54.597366 109.426265 103.025877 110.050924 
#' ##         uq        max
#' ##   1.580943   6.976541
#' ##   9.120224  10.220493
#' ## 119.054471 125.192521
#' 
rtnorm_gpu <- function(n, mean = 0, sd = 1, lower = -Inf, upper = Inf, 
  nthread = 32, dp = FALSE) 
{
  if( length(mean) != 1 | length(sd) != 1 | length(lower) != 1 | 
      length(upper) != 1) { stop("mean, sd, lower, or upper must be a scalar!") }
  if(upper <= lower) stop("upper must be greater than lower!")
  if(sd < 0) stop("Standard deviation cannot be negative!") 

  out <- .C("rtnorm_entry", as.integer(n), as.double(mean),
      as.double(sd), as.double(lower), as.double(upper),
      as.integer(nthread), as.logical(dp), numeric(n), NAOK = TRUE, 
    PACKAGE = "ppda")[[8]]
  return(out)
}


#' Generate Random Numbers from a Canonical LBA Model 
#'
#' This function generates two-accumulator LBA random numbers. \code{rlba_n1} 
#' draws only node 1 random numbers. 
#'
#' @param n numbers of observation. Must be an integer.
#' @param b threshold. \eqn{b - A/2} is response caution.
#' @param A the upper bound of start-point. This is the upper boundary for a 
#' uniform distribution that draws a start value of the sensory evidence. 
#' The average (across trials) start-evidence is \eqn{A/2}.
#' @param mean_v mean drift rates. This must be a 2-element vector.
#' @param sd_v drift rate standard deviations. This must be a 2-element vector.
#' @param t0 non-decision time. Must be a scalar.
#' @param nthread number of threads launched per block.
#' @param dp whether calculate using double precision. Default is FALSE.
#' @return a data frame with first column named RT and second column named R.
#' @export
#' @examples
#' n <- 2^20
#' dat1 <- ppda::rlba(n, nthread = 64) 
#' \dontrun{
#' dat2 <- ggdmc::rlba(n , A = .5, b = 1, t0 = .5, mean_v = c(2.4, 1.6), 
#'                     sd_v = c(1, 1))
#' dat2 <- data.frame(RT = dat2[,1], R = dat2[,2])
#' dat3 <- rtdists::rLBA(n, b = 1, A = .5, mean_v = c(2.4, 1.6), sd_v = c(1, 1), 
#'                       t0 = .5, silent = TRUE)
#' names(dat3) <- c("RT","R")
#'
#' ## Trim ----
#' ## Show numbers of long RTs; Should be around a few hundreds
#' ## These RTs are the cause to make Silverman's method not suitable for 
#' ## choice-RT data. 
#' sum(dat1$RT>5); sum(dat2$RT>5); sum(dat3$RT>5)
#' 
#' dat1 <- dat1[dat1$RT < 5, ]
#' dat2 <- dat2[dat2$RT < 5, ]
#' dat3 <- dat3[dat3$RT < 5, ]
#' 
#' dat1c <- dat1[dat1[,2]==1, 1]
#' dat1e <- dat1[dat1[,2]==2, 1]
#' dat2c <- dat2[dat2[,2]==1, 1]
#' dat2e <- dat2[dat2[,2]==2, 1]
#' dat3c <- dat3[dat3[,2]==1, 1]
#' dat3e <- dat3[dat3[,2]==2, 1]
#' 
#' den1c <- density(dat1c)
#' den2c <- density(dat2c)
#' den3c <- density(dat3c)
#' den1e <- density(dat1e)
#' den2e <- density(dat2e)
#' den3e <- density(dat3e)
#' 
#' ## Identical PDFs
#' par(mfrow=c(1,3))
#' hist(dat1c, breaks="fd",  col="grey", freq=FALSE, xlab="RT (s)", 
#'   main="GPU-Choice 1", xlim=c(0, 3)) ## gpu float
#' lines(den2c, col="red",  lty="dashed",  lwd=1.5) ## cpu
#' lines(den3c, col="blue", lty="dashed",  lwd=3.0) ## rtdists
#' 
#' hist(dat2c, breaks="fd",  col="grey", freq=FALSE, xlab="RT (s)", 
#'   main="CPU-Choice 1", xlim=c(0, 3)) ## cpu 
#' lines(den1c, col="red",  lty="dashed",  lwd=1.5) ## gpu float
#' lines(den3c, col="blue", lty="dashed",  lwd=3.0) ## rtdists
#' 
#' hist(dat3c, breaks="fd",  col="grey", freq=FALSE, xlab="RT (s)", 
#'   main="R-Choice 1", xlim=c(0, 3)) ## rtdists
#' lines(den1c, col="red",  lty="dashed",  lwd=1.5) ## gpu float
#' lines(den2c, col="blue", lty="dashed",  lwd=3.0) ## cpu
#' par(mfrow=c(1,1))
#'
#' plot(den1c$x, den1c$y, type="l")
#' lines(den1e$x, den1e$y)
#' 
#' lines(den2c$x, den2c$y, col="red", lwd=2, lty="dotted")
#' lines(den2e$x, den2e$y, col="red", lwd=2, lty="dotted")
#' 
#' lines(den3c$x, den3c$y, col="blue", lwd=2, lty="dashed")
#' lines(den3e$x, den3e$y, col="blue", lwd=2, lty="dashed")
#' }
#' 
#'
#' ## Because R script takes a while to run, so I repeated 10 times only
#' ## microbenchmark can still give reliable and precise estimation.
#' \dontrun{
#' library(microbenchmark)
#' res <- microbenchmark(ppda::rlba(n, dp=FALSE),
#'                       ppda::rlba(n, dp=TRUE),
#'                       rtdists::rLBA(n, b=1, A=.5, mean_v=c(2.4, 1.6),
#' sd_v=c(1, 1), t0=.5, silent=TRUE), times=10L)
#' }
#'
#' ## Unit: milliseconds
#' ##                  expr     min       lq     mean   median       uq      
#' ## ppda::rlba(n, dp=F)      8.31     8.47     9.17     8.53     9.21    
#' ## ppda::rlba(n, dp=T)     11.86    11.96    12.31    12.06    12.17    
#' ## rtdists::rLBA(n, .)  13521.67 13614.74 13799.59 13770.78 13919.77 
#' ##      max neval cld
#' ##    11.59    10   a
#' ##    14.86    10   a
#' ##   225.72    10   b
#' ## 14177.51    10   c
#'
#' rm(list=ls())
#' n <- 2^20; n
#' dat1 <- ppda::rlba_n1(n, nthread = 64, dp=TRUE);  str(dat1)
#' dat2 <- ppda::rlba_n1(n, nthread = 64, dp=FALSE); str(dat2)
#'
#' \dontrun{
#' res <- microbenchmark::microbenchmark(
#' ppda::rlba_n1(n, dp = F),
#' ppda::rlba_n1(n, dp = T), times = 10L)
#' res
#' }
#' 
#' ## Unit: milliseconds
#' ##                     expr       min        lq     mean   median       uq
#' ## ppda::rlba_n1(n, dp = F)  9.572601  9.949197 17.33809 10.82227 11.41039
#' ## ppda::rlba_n1(n, dp = T) 13.774382 14.742762 21.77835 15.07504 15.45775
#' ##      max neval cld
#' ## 44.93433    10   a
#' ## 49.63786    10   a
#' 
rlba <- function(n, b = 1, A = 0.5, mean_v = c(2.4, 1.6), sd_v = c(1, 1), 
  t0 = 0.5, nthread = 32, dp = FALSE) {
  if (any(sd_v < 0)) stop("Standard deviation must be positive.\n")
  nmean_v <- length(mean_v)
  nsd_v   <- length(sd_v)
  if (nsd_v == 1)  {
    sd_v  <- rep(sd_v, nmean_v)
    nsd_v <- length(sd_v)
  }
  if (nmean_v != nsd_v) stop("sd_v length must match that of mean_v!\n")

  if (dp) {
      result <- .C("rlbad_entry", as.integer(n), as.double(b), 
        as.double(A), as.double(mean_v), as.integer(nmean_v), as.double(sd_v),
        as.integer(length(sd_v)), as.double(t0), as.integer(nthread),
        numeric(n), integer(n), PACKAGE = "ppda")
  } else {
      result <- .C("rlbaf_entry", as.integer(n), as.double(b), as.double(A),
               as.double(mean_v), as.integer(nmean_v), as.double(sd_v),
               as.integer(length(sd_v)), as.double(t0), as.integer(nthread),
               numeric(n), integer(n), PACKAGE = "ppda")
  }
  
  return(data.frame(RT = result[[10]], R = result[[11]]))
}


#' @rdname rlba
#' @export
rlba_n1 <- function(n, b = 1, A = 0.5, mean_v=c(2.4, 1.6), sd_v=c(1, 1), t0=0.5,
  nthread=32, dp=FALSE) {
  if (any(sd_v < 0)) stop("Standard deviation must be positive.\n")
  nmean_v <- length(mean_v)
  nsd_v   <- length(sd_v)
  if (nsd_v == 1) {
    sd_v  <- rep(sd_v, nmean_v)
    nsd_v <- length(sd_v)
  }
  if (nmean_v != nsd_v) stop("sd_v length must match that of mean_v!\n")

  if (dp) {
      result <- .C("rlbad_n1", as.integer(n), as.double(b), as.double(A),
               as.double(mean_v), as.integer(nmean_v), as.double(sd_v),
               as.integer(length(sd_v)), as.double(t0), as.integer(nthread),
               numeric(n), integer(n), PACKAGE = "ppda")
  } else {
      result <- .C("rlbaf_n1", as.integer(n), as.double(b), as.double(A),
               as.double(mean_v), as.integer(nmean_v), as.double(sd_v),
               as.integer(length(sd_v)), as.double(t0), as.integer(nthread),
               numeric(n), integer(n), PACKAGE = "ppda")
  }
  return(data.frame(RT1 = result[[10]], R = result[[11]]))
}

#' The Random Number Generator of the pLBA Model
#'
#' This function generates two-accumulator pLBA random numbers using GPU.
#' 
#' @param n number of simulations. This must be a power of two.
#' @param b threshold. Must be a scalar for plba1. Must be a two-element vector
#' for plba2.
#' @param B travelling distance stage 1. The distance between starting point (
#' drawn randomly from an uniform distribution) to the threshold.  This applies
#' for plba3 only. Please note B differs from b. Must be a two-element vector.
#' @param A starting point upper bound. Must be a scalar for plba1. Must be a 
#' two-element vector for plba2 and plba3.
#' @param C travelling distance stage 2. The distance between updated threshold 
#' and original threshold This applies for plba3 only. Must be a two-element 
#' vector. Note this is uppercase.
#' @param mean_v mean drift rate stage 1. This must be a two-element vector. 
#' @param mean_w mean drift rate stage 2. This must be a two-element vector. 
#' @param sd_v standard deviation of drift rate stage 1. This must be a 
#' two-element vector.
#' @param sd_w standard deviation of drift rate stage 2. This must be a 
#' two-element vector.
#' @param rD an internal psychological delay time for drift rate.   
#' @param tD an internal psychological delay time for threshold. This applies
#' for plba3 only.   
#' @param swt an external switch time when task information changes.   
#' @param t0 non-decision time.  
#' @param gpuid select which GPU to conduct model simulation, if running on 
#' multiple GPU machines.
#' @param nthread numbers of launched GPU threads. Default is a wrap.
#' @return a 2-column data frame [RT R]. 
#' @references Holmes, W., Trueblood, J. S., & Heathcote, A. (2016). A new 
#' framework for modeling decisions about changing information: The Piecewise 
#' Linear Ballistic Accumulator model \emph{Cognitive Psychology}, \bold{85},
#' 1--29, \cr doi: \url{http://dx.doi.org/10.1016/j.cogpsych.2015.11.002}.
#' @examples
#' n <- 2^20
#' dat1 <- ppda::rplba1(n)
#' dat2 <- ppda::rplba2(n)
#' dat3 <- ppda::rplba3(n)
#' 
#' crt1 <- dat1[dat1$R==1,"RT"]
#' ert1 <- dat1[dat1$R==2,"RT"]
#' crt2 <- dat2[dat2$R==1,"RT"]
#' ert2 <- dat2[dat2$R==2,"RT"]
#' crt3 <- dat3[dat3$R==1,"RT"]
#' ert3 <- dat3[dat3$R==2,"RT"]
#' 
#' par(mfrow=c(3,2))
#' hist(crt1, breaks="fd")
#' hist(ert1, breaks="fd")
#' hist(crt2, breaks="fd")
#' hist(ert2, breaks="fd")
#' hist(crt3, breaks="fd")
#' hist(ert3, breaks="fd")
#' par(mfrow=c(1,1))
#'
#' ## It takes about 10 ms to simulate 2^20 rplba random numbers.
#' \dontrun{
#' require(microbenchmark)
#' res <- microbenchmark(ppda::rplba1(n),
#'                       ppda::rplba2(n),
#'                       ppda::rplba3(n), times=10L)
#' }
#' 
#' ## Unit: milliseconds
#' ##             expr      min       lq     mean   median       uq      max 
#' ##  ppda::rplba1(n) 9.046328 10.00658 10.68783 10.72616 11.37464 12.02669 
#' ##  ppda::rplba2(n) 9.349161 11.00560 14.71400 11.19560 13.47059 41.00774 
#' ##  ppda::rplba3(n) 9.870809 10.06734 11.36654 11.19728 11.79733 14.41500 
#' 
#' @export
rplba0 <- function(n, A = 1.5, b = 2.7, t0 = .5, mean_v = c(3.3, 2.2), 
mean_w = c(1.5, 1.2), sd_v = c(1, 1), rD = .3, swt = .5, nthread=32,
gpuid = 0) {
  T0 <- swt + rD
  result <- .C("rplba0_entry",
    as.integer(n),
    as.double(b), as.double(A),
    as.double(mean_v), as.integer(length(mean_v)),
    as.double(mean_w), as.double(sd_v), as.double(t0),
    as.double(T0), as.integer(nthread), as.integer(gpuid),
    integer(n), numeric(n), PACKAGE = "ppda")
  return(data.frame(RT = result[[13]], R = result[[12]]))
}

#' @rdname rplba0
#' @export
rplba1 <- function(n, A = 1.5, b = 2.7, t0 = .5, mean_v = c(3.3, 2.2), 
  mean_w = c(1.5, 1.2), sd_v = c(1, 1), rD = .3, swt = .5, nthread=32,
  gpuid = 0) {
    T0 <- swt + rD
    result <- .C("rplba1_entry",
                 as.integer(n),
                 as.double(b), as.double(A),
                 as.double(mean_v), as.integer(length(mean_v)),
                 as.double(mean_w), as.double(sd_v), as.double(t0),
                 as.double(T0), as.integer(nthread), as.integer(gpuid),
                 integer(n), numeric(n), PACKAGE = "ppda")
    return(data.frame(RT = result[[13]], R = result[[12]]))
}

#' @rdname rplba0
#' @export
rplba2 <- function(n, A = c(1.5, 1.5),  b = c(2.7, 2.7), t0 = .08, 
  mean_v = c(3.3, 2.2), mean_w = c(1.5, 3.7), sd_v = c(1, 1), 
  sd_w = c(1, 1), rD=.3, swt=.5, nthread = 32, gpuid = 0) {
  
    T0 <- swt + rD
    result <- .C("rplba2_entry",
                 as.integer(n),
                 as.double(b), as.double(A),
                 as.double(mean_v), as.integer(length(mean_v)),
                 as.double(mean_w), as.double(sd_v), as.double(sd_w),
                 as.double(t0), as.double(T0), as.integer(nthread), 
                 as.integer(gpuid), integer(n), numeric(n),  PACKAGE = "ppda")
    return(data.frame(RT = result[[14]], R = result[[13]]))
}

#' @rdname rplba0
#' @export
rplba3 <- function(n, A=c(1.5, 1.5), B=c(1.2, 1.2), C=c(.3, .3), 
  mean_v=c(3.3, 2.2), mean_w=c(1.5, 3.7), sd_v=c(1, 1), sd_w=c(1, 1), 
  rD=.3, tD=.3, swt=.5, t0=.08, nthread=32, gpuid = 0) {
    b <- c(A[1] + B[1], A[2] + B[2])
    c <- c(b[1] + C[1], b[2] + C[2])
    swt_r <- rD + swt
    swt_b <- tD + swt
    a0 <- FALSE; a1 <- FALSE; a2 <- FALSE
    if (swt_r == swt_b) {
        a0 <- TRUE
        swt1 <- swt_r
        swt2 <- swt_r
    } else if ( swt_b < swt_r) {
        a1 <- TRUE
        swt1 <- swt_b
        swt2 <- swt_r
    } else {
        a2 <- TRUE
        swt1 <- swt_r
        swt2 <- swt_b
    }
    a <- c(a0, a1, a2)
    swtD <- swt2 - swt1
    result <- .C("rplba3_entry",
                 as.integer(n),
                 as.double(b), as.double(A), as.double(c),
                 as.double(mean_v), as.integer(length(mean_v)),
                 as.double(mean_w), as.double(sd_v), as.double(sd_w),
                 as.double(t0), as.double(swt1), as.double(swt2), as.double(swtD),
                 as.logical(a), as.integer(nthread), as.integer(gpuid),
                 integer(n), numeric(n), PACKAGE = "ppda")
    return(data.frame(RT = result[[18]], R = result[[17]]))
}


rplba <- function(n, A=c(1.5, 1.5), B=c(1.2, 1.2), C=c(.3, .3), 
  mean_v=c(3.3, 2.2), mean_w=c(1.5, 3.7), sd_v=c(1, 1), sd_w=c(1, 1), 
  rD=.3, tD=.3, swt=.5, t0=.08, gpuid = 0, nthread=32) {
  b <- c(A[1] + B[1], A[2] + B[2])
  c <- c(b[1] + C[1], b[2] + C[2])
  swt_r <- rD + swt
  swt_b <- tD + swt
  a0 <- FALSE; a1 <- FALSE; a2 <- FALSE
  if (swt_r == swt_b) {
    a0 <- TRUE
    swt1 <- swt_r
    swt2 <- swt_r
  } else if ( swt_b < swt_r) {
    a1 <- TRUE
    swt1 <- swt_b
    swt2 <- swt_r
  } else {
    a2 <- TRUE
    swt1 <- swt_r
    swt2 <- swt_b
  }
  a <- c(a0, a1, a2)
  swtD <- swt2 - swt1
  result <- .C("rplba3_entry",
    as.integer(n),
    as.double(b), as.double(A), as.double(c),
    as.double(mean_v), as.integer(length(mean_v)),
    as.double(mean_w), as.double(sd_v), as.double(sd_w),
    as.double(t0), as.double(swt1), as.double(swt2), as.double(swtD),
    as.logical(a), as.integer(nthread), as.integer(gpuid),
    integer(n), numeric(n), PACKAGE = "ppda")
  return(cbind(result[[18]], result[[17]]))
  ## return(data.frame(RT = result[[17]], R = result[[16]]))
}