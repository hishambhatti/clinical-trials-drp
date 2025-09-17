#### Updated Bonferroni Power Curves

mu_control <- 10
difference <- 2
mu_treatment <- mu_control + difference
sigma <- 5
n_treatment <- 50
n_control <- 50
n_trials <- 1000
alpha <- 0.05

### Graph 1: Days vs. Power

n_days <- seq(5, 200, by=5)
power <- rep(NA, length(n_days))

my_data_full <- matrix(NA, nrow=length(n_days), ncol=2)
my_data_full <- data.frame(my_data_full)
names(my_data_full) <- c("Days", "Power")

library(ggplot2)

counter <- 1
for (k in 1:length(n_days)) {
  
  current_days <- n_days[k]
  type2errors <- 0
  
  current_fwer <- alpha/current_days
  
  for (j in 1:n_trials) {
    
    treatment <- rnorm(n_treatment, mean = mu_treatment, sd = sigma)
    control <- rnorm(n_control, mean = mu_control, sd = sigma)
    pval = t.test(treatment, control)$p.value
    
    if (pval > current_fwer) {
      type2errors <- type2errors + 1
    } 
    
  }
  
  power[k] = (n_trials - type2errors) / n_trials
  my_data_full[counter,] <- c(current_days, power[k])
  counter <- counter+1
}

ggplot() + geom_line(data=my_data_full, aes(x=n_days, y=power))

### Graph 2: Sample Size vs. Power (Colors as Number of Days)

mu_control <- 10
difference <- 2
mu_treatment <- mu_control + difference
sigma <- 5
n_trials <- 1000
alpha <- 0.05

n = seq(10, 500, by=10)
n_days = seq(10, 1010, by=200)

my_data_full <- matrix(NA, nrow=length(n) * length(n_days), ncol=3)
my_data_full <- data.frame(my_data_full)
names(my_data_full) <- c("n", "Days", "Power")

counter <- 1
for (k in 1:length(n_days)) {
  
  current_days <- n_days[k]
  current_fwer = alpha/current_days
  
  for (j in 1:length(n)) {
    
    current_n <- n[j]
    
    type2errors <- 0
    
    for (i in 1:n_trials) {
      
      treatment <- rnorm(current_n, mean = mu_treatment, sd = sigma)
      control <- rnorm(current_n, mean = mu_control, sd = sigma)
      
      pval = t.test(treatment, control)$p.value
      
      if (pval > current_fwer) {
        type2errors <- type2errors + 1
      } 
    }
    
    my_data_full[counter,] <- c(current_days, current_n, (n_trials - type2errors) / n_trials)
    counter <- counter+1
  }
}

days = my_data_full[, 1]
graph_n = my_data_full[, 2]
power = my_data_full[, 3]

ggplot() + geom_line(data=my_data_full, aes(x=graph_n, y=power, group=days, col=as.factor(days)))


