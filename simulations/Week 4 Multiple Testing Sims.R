### Lets imagine that we have a trial that runs for 30 days.
### Each day, we measure some numerical response for all patients (in treatment group
### and control group).
### We want to know if treatment and control group have different means. We are simulating a scenario
### where they do not (null hypothesis is true).
#### Two options of how to run trial:
  ### Do a t-test for difference in means every single day, "declare success" and stop as soon as we see p < alpha
   ### Wait until the end (day 30) and do a single test for difference in means. "Declare success" if p < alpha
## Any time we "declare success", we made a mistake. 


### single realization.
mu_treatment <- 10
mu_control <- 10
sigma = 5
n_treatment <- 50
n_control <- 50
n_days <- 30
n_trials <- 1000

doc1tests <- rep(NA, n_trials)
doc2tests <- matrix(NA, nrow=n_trials, ncol=n_days)
doc2decisions <- rep(FALSE, n_trials)
doc1decisions <- rep(FALSE, n_trials)
alpha <- 0.05
for (i in 1:n_trials) {
  control_data <- matrix(rnorm(n_control*n_days, mean=mu_control, sd=sigma), nrow=n_control, ncol=n_days)
  treatment_data <- matrix(rnorm(n_treatment*n_days, mean=mu_treatment, sd=sigma), nrow=n_treatment, ncol=n_days)
  
  ### Doctor number 1 decides to do a test based on ONLY day 30. 
  doc1tests[i] <- t.test(control_data[,n_days], treatment_data[,n_days])$p.value
  doc1decisions[i] =  doc1tests[i] < alpha
  
  for (day in 1:n_days) {
    doc2tests[i,day] <- t.test(control_data[,day], treatment_data[,day])$p.value
    if (doc2tests[i,day] < alpha/n_days) {
      doc2decisions[i] <- TRUE
      break
    }
  }
}

hist(doc1tests)
mean(doc1tests < 0.05)
mean(doc1decisions)

stoppingDays <- rep(n_days, n_trials)
for (i in 1:n_trials) {
  j = 1
  while (j < n_days) {
    if (doc2tests[i,j] < alpha) {
      stoppingDays[i] = j
      break
    }
    j=j+1
  }
}

hist(as.numeric(doc2tests))
mean(doc2tests < 0.05, na.rm=TRUE)
mean(doc2decisions)

#### Doctor number 2 decides to do a separate test on each of the 30 days.
doc2tests <- rep(NA, n_days)



n <- 1:100
alpha=0.05
plot(n, 1-((1-alpha)/n)^n)

