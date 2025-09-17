library(survival)
library(tidyverse)

n_treatment <- 1916
n_control <- 1921
n <- n_treatment + n_control
n_iters <- 2000
interim_analyses <- 4
pvals_null <- matrix(NA, nrow=n_iters, ncol=interim_analyses)

alpha <- 0.05
bonferroni_boundary <- alpha/interim_analyses
pocock_boundary <- 0.0182
of_boundary <- c(0.00005, 0.0039, 0.0184, 0.0412)


for (iter in 1:n_iters) {
  print(iter)
  #### Null Hypothesis: P (die | treatment) = P(die) = 326/3837
  fake_data_null <- data.frame(matrix(NA, nrow=n, ncol=3))
  names(fake_data_null) <- c("treatment", "status", "time")
  fake_data_null$treatment <- 
    c(rep("treatment", n_treatment), rep("control", n_control))
  
  overall_p_death <- 326/3837
  # Because it's the null, both treatment and control have p(status=1)=326/3837
  fake_data_null$status <- rbinom(n, size=1, prob=overall_p_death)
  
  # For now, there is no dropout. This means that everyone who is 
  # NOT dead was observed not dead at the end of the study. 
  # Let's call the end of the study month=end_month
  end_month <- 36
  
  # Initialize everyone's observation day to be end_month
  # If they died, assign them an end month uniformly distributed on (0, end_month)
  fake_data_null$time <- 36
  n_deaths <- sum(fake_data_null$status==1)
  
  # No idea what the heck this does, but I think it's just doing the uniform distribution
  fake_data_null$time[fake_data_null$status==1] <- runif(n_deaths, min=0, max=end_month)
  
  logrank.test <- survdiff(Surv(time, status) ~ treatment, data=fake_data_null)
  pval <- 1-pchisq(logrank.test$chisq,1)
  
  ## Now, it's time to do the Sequential Methods stuff
  # Want 4 interim analyses (9, 18, 27, 36 months)
  # At each interim, will generate copy called "tempdata" that stores censored data
  for (interim in 1:interim_analyses) {
    month <- 9*interim
    temp_data_null <- data.frame(matrix(NA, nrow=n, ncol=3))
    names(temp_data_null) <- c("treatment", "status", "time")
    for (row in 1:n) {
      fake_data_null_row <- fake_data_null[row,]
      if (fake_data_null_row[3] > month) {
        temp_data_null[row,] = c(fake_data_null_row[1], 0, month)
      } else {
        temp_data_null[row,] = fake_data_null_row
      }
    }
    
    # At this point, we have all the rows with either 0s and survived past the time,
    # or 1s and died before
    
    ## TODO: Need to implement the idea that we are adding patients during each
    ## interim
    
    logrank.test <- survdiff(Surv(time, status) ~ treatment, data=temp_data_null)
    pvals_null[iter, interim] <- 1-pchisq(logrank.test$chisq,1)
    
  }
}

reject_naive <- t(apply(pvals_null, 1, function(u) u < alpha))
reject_bonferoni <- t(apply(pvals_null, 1, function(u) u < bonferroni_boundary))
reject_pocock <- t(apply(pvals_null, 1, function(u) u < pocock_boundary))
reject_of <- t(apply(pvals_null, 1, function(u) u < of_boundary))

reject_trial_naive <- rowSums(reject_naive)>0
reject_trial_bonferoni <- rowSums(reject_bonferoni)>0
reject_trial_of <- rowSums(reject_of)>0
reject_trial_pocock <- rowSums(reject_pocock)>0

mean(reject_trial_naive)
mean(reject_trial_bonferoni)
mean(reject_trial_of)
mean(reject_trial_pocock)

n_iters <- 2000

#### Alternative Hypothesis: Different p(death) for control and treatment

pvals_alt <- matrix(NA, nrow=n_iters, ncol=interim_analyses)
for (iter in 1:n_iters) {
  print(iter)

  fake_data_alt <- data.frame(matrix(NA, nrow=n, ncol=3))
  names(fake_data_alt) <- c("treatment", "status", "time")
  fake_data_alt$treatment <- 
    c(rep("treatment", n_treatment), rep("control", n_control))
  
  treatment_p_death <- 138/1916
  control_p_death <- 188/1921
  
  fake_data_alt$status[1:n_treatment] <- rbinom(n_treatment, size=1, prob=treatment_p_death)
  fake_data_alt$status[(n_treatment+1):(n)] <- rbinom(n_control, size=1, prob=control_p_death)
  
  # For now, there is no dropout. This means that everyone who is 
  # NOT dead was observed not dead at the end of the study. 
  # Let's call the end of the study month=end_month
  end_month <- 36
  
  # Initialize everyone's observation day to be end_month
  # If they died, assign them an end month uniformly distributed on (0, end_month)
  fake_data_alt$time <- 36
  n_deaths <- sum(fake_data_alt$status==1)
  
  # No idea what the heck this does, but I think it's just doing the uniform distribution
  fake_data_alt$time[fake_data_alt$status==1] <- runif(n_deaths, min=0, max=end_month)
  
  logrank.test <- survdiff(Surv(time, status) ~ treatment, data=fake_data_alt)
  pval <- 1-pchisq(logrank.test$chisq,1)
  
  ## Now, it's time to do the Sequential Methods stuff
  # Want 4 interim analyses (9, 18, 27, 36 months)
  # At each interim, will generate copy called "tempdata" that stores censored data
  
  interim_analyses <- 4
  
  alpha <- 0.05
  bonferroni_boundary <- alpha/interim_analyses
  pocock_boundary <- 0.0182
  of_boundary <- c(0.00005, 0.0039, 0.0184, 0.0412)
  
  for (interim in 1:interim_analyses) {
    month <- 9*interim
    temp_data_alt <- data.frame(matrix(NA, nrow=n, ncol=3))
    names(temp_data_alt) <- c("treatment", "status", "time")
    for (row in 1:n) {
      fake_data_alt_row <- fake_data_alt[row,]
      if (fake_data_alt_row[3] > month) {
        temp_data_alt[row,] = c(fake_data_alt_row[1], 0, month)
      } else {
        temp_data_alt[row,] = fake_data_alt_row
      }
    }
    
    # At this point, we have all the rows with either 0s and survived past the time,
    # or 1s and died before
    
    ## TODO: Need to implement the idea that we are adding patients during each
    ## interim, and figuring out how to get that with the matrix
    
    logrank.test <- survdiff(Surv(time, status) ~ treatment, data=temp_data_alt)
    pvals_alt[iter,interim] <- 1-pchisq(logrank.test$chisq,1)
  }
}


reject_naive_alt <- t(apply(pvals_alt, 1, function(u) u < alpha))
reject_bonferoni_alt <- t(apply(pvals_alt, 1, function(u) u < bonferroni_boundary))
reject_pocock_alt <- t(apply(pvals_alt, 1, function(u) u < pocock_boundary))
reject_of_alt <- t(apply(pvals_alt, 1, function(u) u < of_boundary))


power <- data.frame((1:interim_analyses)*9,
                cbind(colMeans(reject_naive_alt),
               colMeans(reject_bonferoni_alt),
               colMeans(reject_pocock_alt),
               colMeans(reject_of_alt)))
names(power) <- c("time", "naive", "bonf", "pocock", "of")
               

ggplot(data=power) + geom_line(aes(x=time, y=bonf, col="Bonferonni"))+
  geom_line(aes(x=time, y=pocock, col="Pocock"))+
  geom_line(aes(x=time, y=of, col="O'Brien-Fleming"))+ylab("Power")+xlab("Month")+ggtitle("Power over time")+
  labs(col="Method")
