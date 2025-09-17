#### Lets make a really basic simulation study which shows that our type 1 error rate
### is equal to alpha. 
#### Type 1 error simulations are boring, but we will then be able to extend them to study power. 

### We are studying difference in means for some numerical response variable. 
alpha <- 0.05
n_treatment <- 100
n_control = 100
### The null is TRUE because these are the same. 
mu_treatment = 50+0
mu_control = 50
### We will assume sigma_treatment=sigma_control throughout. 
sigma = 10

### Type 1 error is the probability of rejecting the null when it is true.
### To estimate a probability, we can do an experiment a bunch of times and compute
### a proportion. 

nTrials <- 500
alphas <- seq(0.1,0.5,by=0.1)

type1errors <- rep(NA, length(alphas))

for (j in 1:length(alphas)) {
  alpha = alphas[j]
  pvals = rep(NA, nTrials)
  for (i in 1:nTrials) {
    ## Generate fake data.
    treatment = rnorm(n_treatment, mean=mu_treatment, sd=sigma)
    control = rnorm(n_control, mean=mu_control, sd=sigma)
    pvals[i] = t.test(treatment,control)$p.value
  }
  type1errors[j] <- mean(pvals < alpha)
}

### TYPE 1 ERROR RATE
plot(alphas, type1errors)
library(ggplot2)
ggplot(data=NULL, aes(x=alphas,y=type1errors))+geom_line()

#### REALLY FUN CHALLENGE.
### Type 1 error is boring to study, but POWER is not boring to study.
#### We need to modify this so that we are simulating data where the null is FALSE.
#### We still want to keep a record of how often we reject vs. don't reject the null
#### (can just use alpha=0.05)

#### It would be cool to make two plots.

#### The first plot can fix mu_treatment-mu_control but change the sample size. Make a plot where the X
### axis is sample size and the Y axis is power.

### The second plot can fix sample size but make the X axis mu_treatment-mu_control and the Y
### axis power. 

### Challenge--- make ONE plot where X axis is sample size, Y axis is power, different
### colored lines show different values of  mu_treatment-mu_control.

### For extra fun, try to make the plots pretty 
### if you have time maybe google ggplots !!!
### Feel free to email me if you get stuck. 

#### If you finish, try an example with a different in proportions!!!! 
#### Or a paired differences test!!!
### (email me if you need a more defined task haha.)

colors = c("pink", "red", "orange", "yellow", "green", "blue", "dark blue", "purple", 
           "brown", "black", "gray")


# n_treatment = n_control
n = seq(10, 500, by=10)
power = rep(NA, length(n))

mu_control = 50;
difference = seq(0, 5, by=0.5)

for (i in length(n)) {
  
  current_n = n[i]
  
  type2errors = 0
  
  for (j in length(difference)) {
    
    current_difference <- difference[j]
    mu_treatment = mu_control + current_difference
    
    for (k in length(difference)) {
      
      type2errors = 0
      
      current_color <- difference[j]
      treatment <- rnorm(current_n, mean = mu_treatment, sd = sigma)
      control <- rnorm(current_n, mean = mu_control, sd = sigma)
      
      plot()
    }
    
    pval = t.test(treatment, control)$p.value
    
    if (pval > alpha) {
      type2errors = type2errors + 1
    }
    
  }
  
  power[j] = (number_of_trials - type2errors) / number_of_trials
}



