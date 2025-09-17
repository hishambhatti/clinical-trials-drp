mu_control <- 10
difference <- 2
mu_treatment <- mu_control + difference
sigma <- 5
n <- 50
n_trials <- 10000
alpha <- 0.05

days <- 5
pvals <- matrix(NA, nrow=n_trials, ncol=days)
pvals <- data.frame(my_data_full)

for (j in 1:n_trials) {
  ### We have all these people, but we imagine that only
  ### first 20 are present on day 1, first 40 are present on day 2, etc
  treatment <- rnorm(n, mean = mu_treatment, sd = sigma)
  control <- rnorm(n, mean = mu_control, sd = sigma)
  for (day in 1:days) {
    patients <- day/days*n
    pvals[j, day] <- t.test(treatment[1:patients], control[1:patients])$p.value
  }
}

methods = c(0, 0, 0, 0);

rejections <- apply(pvals, 1, function(u) mean(u < alpha) > 0)
methods[1] <- mean(rejections)
rejections_bonferoni <- apply(pvals, 1, function(u) mean(u < alpha/days) > 0)
methods[2] <- mean(rejections_bonferoni)
rejections_pocock <- apply(pvals, 1, function(u) mean(u < 0.0158) > 0)
methods[3] <- mean(rejections_pocock)
of_significance <- c(0.000005, 0.0013, 0.0085, 0.0228, 0.0417)
rejections_of <- apply(pvals, 1, function(u) mean(u < of_significance) > 0)
methods[4] <- mean(rejections_of)
print(methods)


stopping_days <- c(0,0,0,0)
rejections <- apply(pvals, 1, function(u) which(u < alpha)[1])
stopping_days[1] <- mean(rejections, na.rm=TRUE)
rejections_bonferoni <- apply(pvals, 1, function(u) which(u < alpha/days)[1])
stopping_days[2] <- mean(rejections_bonferoni, na.rm=TRUE)
rejections_pocock <- apply(pvals, 1, function(u) which(u < 0.0158)[1])
stopping_days[3] <- mean(rejections_pocock, na.rm=TRUE)
of_significance <- c(0.000005, 0.0013, 0.0085, 0.0228, 0.0417)
rejections_of <- apply(pvals, 1, function(u) which(u < of_significance)[1])
stopping_days[4] <- mean(rejections_of, na.rm=TRUE)
print(stopping_days)

