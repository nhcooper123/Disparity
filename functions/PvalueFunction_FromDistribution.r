#29/01/14
#Function to calculate a p value from a distribution
#Copied this code from the DisparityPractice_16_01_14_using_SkLat_08_11_13 script

###NB; I need to check this code with Natalie

#############################################################
#write this into a function to find a pvalue from a distribution
#compare a test statistic to a distribution
#distribution is the set of re-sampled measurements
#obs.val is the observed value of the test statistic

pvalue.dist<-function(distribution,obs.val){
  #find the number of values fromt the distribution that are less than or equal to the observed value
  low.diff<-distribution[which(distribution<=obs.val)]
    #count the number of values
    length(low.diff)
    #call this the lower p value
  lowerp<-(length(low.diff))/(length(distribution))
  #higher p will always be equal to 1-lowerp
  higherp<-(1-lowerp)
    #the actual p value will be whichever one is lower
  if (lowerp<higherp){
    p<-lowerp
  }
  else {p<-higherp}
    #print both the lower and higher p values
    cat("lowerp",lowerp,"\n")
    cat("higherp",higherp,"\n")
    #but return the actual p value
  return(p)
}
#--------------------------------------------------------
#test the function
#make a random normal distribution to test out a function
#  rand.dist<-(rnorm(1:100, mean=5, sd=1))
#  range(rand.dist)
#test with an observed value at the lower end of the range
#  pvalue.dist(distribution=rand.dist,obs.val=3)
#test with an observed value at the higher end of the range
#  pvalue.dist(distribution=rand.dist,obs.val=6.5)
#each time the function selects the correct option of lowerp vs higherp as the right output value