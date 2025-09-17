#### Statistical POWER simulation
#### Want to simulate data where the NULL is false
#### Keep a record of how often we reject vs. don't reject the null hypothesis

#### Make 2 plots
## First plot fixes the mu_treatment-mu_control but changes the sample size.
## Make a plot where the X axis is sample size and the Y axis is power

# Null is FALSE since they are NOT the same
difference <- 2
mu_control <- 50
mu_treatment <- 50 + difference

# Assume sigma_control = sigma_treatment
sigma <- 10

#### Plot 1: Fixed difference in means but varying sample sizes

# n_treatment = n_control
n = seq(10, 500, by=10)
power = rep(NA, length(n))

for (j in 1:length(n)) {
  
  current_n = n[j];
  type2errors = 0
  
  for (i in 1:number_of_trials) {
    # Generate fake data
    
    
    # Gets a sample mean for both the treatment and control group (varying 
    # sample sizes)
    treatment <- rnorm(current_n, mean = mu_treatment, sd = sigma)
    control <- rnorm(current_n, mean = mu_control, sd = sigma)
    
    # Gets the P-Value associated with seeing the sample difference assuming
    # that the null is true
    pval = t.test(treatment, control)$p.value
    
    # We make a Type II Error when we fail to reject H0 (even though we know
    # that H0 is false)
    if (pval > alpha) {
      type2errors = type2errors + 1
    }
    
  }
  
  power[j] = (number_of_trials - type2errors) / number_of_trials
}
plot(n, power)

#### Plot 2: Fixed sample size but varying differences in means
n_treatment <- 100
n_control <- 100

mu_control = 50;

difference = seq(0, 5, by=0.05)
power = rep(NA, length(difference))

for (j in 1:length(difference)) {
  
  current_difference = difference[j]
  type2errors = 0
  
  for (i in 1:number_of_trials) {
    # Generate fake data
    
    
    # Gets a sample mean for both the treatment and control group (varying 
    # sample sizes)
    
    mu_treatment = mu_control + current_difference 
    
    treatment <- rnorm(n_treatment, mean = mu_treatment, sd = sigma)
    control <- rnorm(n_control, mean = mu_control, sd = sigma)
    
    # Gets the P-Value associated with seeing the sample difference assuming
    # that the null is true
    pval = t.test(treatment, control)$p.value
    
    # We make a Type II Error when we fail to reject H0 (even though we know
    # that H0 is false)
    if (pval > alpha) {
      type2errors = type2errors + 1
    }
    
  }
  
  power[j] = (number_of_trials - type2errors) / number_of_trials
}
plot(difference, power)

#### Challenge #1 - Make ONE plot where X axis is sample size, Y axis is power,
####                and different colored lines show different values of 
####                mu_treatment - mu_control

# n_treatment = n_control

number_of_trials = 500
alpha = 0.05
n = seq(10, 500, by=10)
difference = seq(1, 5, by=2)
my_data_full <- matrix(NA, nrow=length(n)*length(difference), ncol=3)
my_data_full <- data.frame(my_data_full)
names(my_data_full) <- c("difference", "n", "power")
mu_control = 50


library(ggplot2)

counter <- 1
for (k in 1:length(difference)) {
  
  current_difference = difference[k]
  
  current_color = current_difference
  
  for (i in 1:length(n)) {
    
    current_n = n[i]
    type2errors = 0
    
    for (j in 1:number_of_trials) {
      
      mu_treatment = mu_control + current_difference
      
      treatment <- rnorm(current_n, mean = mu_treatment, sd = sigma)
      control <- rnorm(current_n, mean = mu_control, sd = sigma)
      
      pval = t.test(treatment, control)$p.value
      
      if (pval > alpha) {
        type2errors = type2errors + 1
      }
      
    }
    my_data_full[counter,] <- c(current_difference, current_n, (number_of_trials - type2errors) / number_of_trials)
    counter <- counter+1
  }
}


ggplot() + 
  geom_line(data=my_data_full, aes(x=n, y=power, group=difference, col=as.factor(difference)))

