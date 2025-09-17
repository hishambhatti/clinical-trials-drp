library(survival)
library(tidyverse)



### What do we need to make fake data under the null.
n_treatment = 50
n_control = 50
n = n_treatment+n_control
fake_data_null <- data.frame(matrix(NA, nrow=n, ncol=3))
names(fake_data_null) <- c("treatment", "status", "time")
fake_data_null$treatment <- 
  c(rep("treatment", n_treatment), rep("control", n_control))
overall_p_death <- 0.2
### Because its the null, both treatment and control have p(status=1)=0.2
fake_data_null$status <- rbinom(n, size=1, prob=overall_p_death)

### For now, there is no dropout. This means that everyone
### who is NOT dead was observed not dead at the end of the study.
### Let's call the end of the study day=end_day
end_day = 60
### Initialize everyone's observation day to be end-day
### IF they died, assign them an end day uniformly distribted on (0, end_day)
fake_data_null$time <- 60
n_deaths <- sum(fake_data_null$status==1)
fake_data_null$time[fake_data_null$status==1] <- runif(n_deaths, min=0, max=end_day)
  

logrank.test <- survdiff(Surv(time, status) ~ treatment, data=fake_data_null)
pval <- 1-pchisq(logrank.test$chisq,1)
  

## Alternative Hypothesis

fake_data_alt <- data.frame(matrix(NA, nrow=n, ncol=3))
names(fake_data_alt) <- c("treatment", "status", "time")
fake_data_alt$treatment <- 
  c(rep("treatment", n_treatment), rep("control", n_control))
treatment_p_death <- 0.1
control_p_death <- 0.3
fake_data_alt$status[1:n_treatment] <- rbinom(n_treatment, size=1, prob=treatment_p_death)
fake_data_alt$status[(n_treatment+1):(n)] <- rbinom(n_control, size=1, prob=control_p_death)

### For now, there is no dropout. This means that everyone
### who is NOT dead was observed not dead at the end of the study.
### Let's call the end of the study day=end_day
end_day = 60
### Initialize everyone's observation day to be end-day
### IF they died, assign them an end day uniformly distribted on (0, end_day)
fake_data_alt$time <- 60
n_deaths <- sum(fake_data_alt$status==1)
fake_data_alt$time[fake_data_alt$status==1] <- runif(n_deaths, min=0, max=end_day)

logrank.test <- survdiff(Surv(time, status) ~ treatment, data=fake_data_alt)
