#### Bonferroni Power Curves
### Three variables: 
  # Colors = number of days
  # X = Family-Wise Error Rate
  # Y = Power

## Might also try to incorporate
  # 1. Differences in Means
  # 2. Sample Size

mu_control <- 10
difference <- 2
mu_treatment <- mu_control + difference
sigma <- 5
n_treatment <- 50
n_control <- 50
n_trials <- 1000

n_days <- seq(0, 200, by=50)
alphas <- seq(0.01, 0.2, by=0.01)

my_data_full <- matrix(NA, nrow=length(alphas) * length(n_days), ncol=3)
my_data_full <- data.frame(my_data_full)
names(my_data_full) <- c("Days", "FWER", "Power")

library(ggplot2)

counter <- 1
for (k in 1:length(n_days)) {
  
  current_days <- n_days[k]
  
  for (j in 1:length(alphas)) {
    
    current_alpha <- alphas[j]
    current_fwer <- current_alpha/current_days
  
    type2errors <- 0
    
    for (i in 1:n_trials) {
      
      treatment <- rnorm(n_treatment, mean = mu_treatment, sd = sigma)
      control <- rnorm(n_control, mean = mu_control, sd = sigma)
      
      pval = t.test(treatment, control)$p.value
      
      if (pval > current_fwer) {
        type2errors <- type2errors + 1
      } 
      
    }
    my_data_full[counter,] <- c(current_days, current_fwer, (n_trials - type2errors) / n_trials)
    counter <- counter+1
  }
}

fwer = my_data_full[, 2]
power = my_data_full[, 3]
days = my_data_full[, 1]

ggplot() + geom_line(data=my_data_full, aes(x=fwer, y=power, group=days, col=as.factor(days)))




