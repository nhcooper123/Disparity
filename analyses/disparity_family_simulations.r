#12/05/2014
#General script for simulating shape evolution across phylogenies and calculating disparity
    #Based on the previous script (30_04_14) but tidier because I'm using my new general functions

#Steps
  #1) Read in phylogenies, shape data and taxonomy
  #2) Choose which family (tenrecs or golden moles) 
  #3) Prune phylogenies
  #4) Shape simulation across phylogenies
  #5) PCA analysis of each simulation
  #6) Calculate disparity for each simulation and observed data
  #7) Compare observed and simulated disparity
  #8) Create output files
  
#########################################################
library(ape)
library(geiger)
library(geomorph)

#-------------------------------------------------------------------------------------
#First option: working directories

#Run on my computer
	source("C:/Users/sfinlay/Desktop/Thesis/Disparity/functions/DisparityFunctions_Variance_Range.r")
	source("C:/Users/sfinlay/Desktop/Thesis/Disparity/functions/PValueFunction_FromDistribution.r")
  source("C:/Users/sfinlay/Desktop/Thesis/Disparity/functions/Disparity_general_functions.r" )

#On the alien: save everything onto the USB
#  setwd("E:/Disparity")
#  source("E:/Disparity/DisparityFunctions_Variance_Range.r")
#  source("E:/Disparity/PValueFunction_FromDistribution.r")

######################################################
#1) READ IN DATA
######################################################

#SkDors
#1) Phylogenies
   setwd("C:/Users/sfinlay/Desktop/Thesis/Disparity/output/phylogenies")
  mytrees <- read.tree("SkDors_tenrec+gmole_101trees.phy")

#2) Data
  setwd("C:/Users/sfinlay/Desktop/Thesis/Disparity/output/shape_data/skdors")
  #2a) All tenrecs and golden moles
      #shape coordinates
      sps.mean <- dget(file="SkDors_tenrec+gmole_sps.mean.txt")
      #taxonomic information
      tax <- read.table("SkDors_tenrec+gmole_sps.mean_taxonomy.txt")
  
  #2b) Non-microgale tenrecs and all golden moles
      #shape coordinates
#      sps.mean <- dget(file="SkDors_nonmictenrec+gmole_sps.mean.txt")
      #taxonomic information
#      tax <- read.table("SkDors_nonmictenrec+gmole_taxonomy.txt")
#------------------------------------------------------
#SkLat

#1) Phylogenies
#setwd("C:/Users/sfinlay/Desktop/Thesis/Disparity/output/phylogenies")
#     mytrees <- read.tree("SkLat_tenrec+gmole_101trees.phy")
     
#2) Data
#setwd("C:/Users/sfinlay/Desktop/Thesis/Disparity/output/shape_data/sklat")
  #2a) All tenrecs and golden moles
      #shape coordinates
#      sps.mean <- dget(file="SkLat_tenrec+gmole_sps.mean.txt")
      #taxonomic information
#      tax <- read.table("SkLat_tenrec+gmole_sps.mean_taxonomy.txt")
  
  #2b) Non-microgale tenrecs and all golden moles
    #shape coordinates
#    sps.mean <- dget(file="SkLat_nonmictenrec+gmole_sps.mean.txt")
    #taxonomic information
#    tax <- read.table("SkLat_nonmictenrec+gmole_sps.mean_taxonomy.txt")
#------------------------------------------------------
#SkVent
#1) Phylogenies
#setwd("C:/Users/sfinlay/Desktop/Thesis/Disparity/output/phylogenies")
#    mytrees <- read.tree("SkVent_tenrec+gmole_101trees.phy")

#2) Data
#setwd("C:/Users/sfinlay/Desktop/Thesis/Disparity/output/shape_data/skvent")
  #2a) All tenrecs and golden moles
      #shape coordinates
#      sps.mean <- dget(file="SkVent_tenrec+gmole_sps.mean.txt")
      #taxonomic information
#     tax <- read.table("SkVent_tenrec+gmole_sps.mean_taxonomy.txt")
  
  #2b) Non-microgale tenrecs and all golden moles
    #shape coordinates
    #sps.mean <- dget("SkVent_nonmictenrec+gmole_sps.mean.txt")
    #taxonomic information
    #tax <- read.table("SkVent_nonmictenrec+gmole_sps.mean_taxonomy.txt")
#------------------------------------------------------
#Mandibles
#1) Phylogenies
#setwd("C:/Users/sfinlay/Desktop/Thesis/Disparity/output/phylogenies")
#    mytrees <- read.tree("Mands_tenrec+gmole_101trees.phy")

#2) Data
#setwd("C:/Users/sfinlay/Desktop/Thesis/Disparity/output/shape_data/mands")
  #2a) All tenrecs and golden moles
      #shape coordinates
#      sps.mean <- dget(file="Mands_tenrec+gmole_sps.mean.txt")
      #taxonomic information
#     tax <- read.table("Mands_tenrec+gmole_sps.mean_taxonomy.txt")
  
  #2b) Non-microgale tenrecs and all golden moles
    #shape coordinates
#    sps.mean <- dget(file="Mands_nonmictenrec+gmole_sps.mean.txt")
    #taxonomic information
#    tax <- read.table("Mands_nonmictenrec+gmole_sps.mean_taxonomy.txt")

#################################################
#2) CHOOSE WHICH FAMILY 
#################################################
#Golden moles
# sps.tax <- tax$Binomial[which(tax$Family == "Chrysochloridae")]

#Tenrecs
  sps.tax <- tax$Binomial[which(tax$Family == "Tenrecidae")]

#find the ID numbers for the species of interest
  ID.sps <- matching.id(sps.tax, sps.mean$Binom)

#select those species from the overall data
  mysps.mean <- select.from.list(sps.mean, ID.sps)
#drop unused levels
  mysps.mean <- droplevels.from.list(mysps.mean)

##################################################
#3) PRUNE THE PHYLOGENIES
##################################################
#Prune the trees to include that family's taxa only

  TreeOnly <- tree.only(mytrees, sps.tax)

#prune the trees so that they only include the species which are in the species data
  sps.trees <- remove.missing.species.tree(mytrees, TreeOnly)

###################################################
#4) SHAPE SIMULATION
###################################################

#Convert the shape coordinates into a 2D array
  twoDshape <- two.d.array(mysps.mean$meanshape)

#Add the species as rownames
  rownames(twoDshape) <- mysps.mean$Binom

#Separate variance covariance matrix of the shape data for each of the phylogenies
  varcov <- as.list(rep(NA,length(sps.trees)))
    for(i in 1:length(sps.trees)){
      varcov[[i]] <- vcv(phy=sps.trees[[i]],twoDshape)
    }   

#simulate shape evolution on each phylogeny
  shape.sim <- as.list(rep(NA,length(sps.trees)))
    for (i in 1: length(sps.trees)){
      shape.sim[[i]] <- sim.char(sps.trees[[i]], varcov[[i]],nsim=1000,model="BM")
    }
    
#Combine simulations into one list
simlist <- list.matrix.to.array(shape.sim)  
######################################################
#5) PCA ANALYSIS
######################################################

#a) Simulated data
  shape.simPC <- calc.each.list(mylist=simlist, calculation=prcomp)

#Select the PC axes that account for approsimately 95% of the variation
  shape.simPC95 <- NULL
    for (i in 1:length(shape.simPC)){
      shape.simPC95[[i]] <- selectPCaxes.prcomp(shape.simPC[[i]], 0.956)
    }
  
#b) Observed data
  #Do a principal components analysis on the family's (tenrec or golden mole)shape values only
    #i.e. don't use the PC axes from the global principal components analysis of all the species together
    #Makes sense because simulations are based on the shape coordinates for one family only

#PCA of mean shape values for each species
  obsPC <- prcomp(twoDshape)

#select the PC axes which correspond to 95% of the variation
  obsPC95 <- selectPCaxes.prcomp(obsPC, 0.956)

##########################################################
#6) CALCULATE DISPARITY FOR SIMULATIONS AND OBSERVED DATA
##########################################################
#Simulated data
#a) Disparity based on PC axes
  #Variance measures
    sumvar <- calc.each.list(mylist=shape.simPC95, calculation=PCsumvar)
    prodvar <- calc.each.list(mylist=shape.simPC95, calculation=PCprodvar)
    
      #Matrix of the sum and product of variance for each simulation
      simPC.var <- as.data.frame(matrix(NA,nrow=length(sumvar),ncol=2))
        colnames(simPC.var) <- c("SumVar","ProdVar")
        simPC.var[,1] <- unlist(sumvar)
        simPC.var[,2] <- unlist(prodvar)
  

  #Range measures
    sumrange <- calc.each.list(mylist=shape.simPC95, calculation=PCsumrange)
    prodrange <- calc.each.list(mylist=shape.simPC95, calculation=PCprodrange)
      
      #Matrix of the sum and product of range for each simulation
      simPC.range <- as.data.frame(matrix(NA,nrow=length(sumrange),ncol=2))
        colnames(simPC.range) <- c("SumRange","ProdRange")
        simPC.range[,1] <- unlist(sumrange)
        simPC.range[,2] <- unlist(prodrange)

#b) Disparity based on interlandmark distances

#convert the simulated shape matrices into three dimensional arrays
   test <- arrayspecs(A=simlist[[1]], p=((dim(simlist[[1]])[2])/2), k=2)
      #gives an error message, the example in the geomorph package has the same error message -> need to email aithore

     #interlandmark distance: compare each species to the overall mean shape of all species
        ild.distance <- lapply(simlist, dist.to.ref(simlist))

  
    
#Observed data
  #Variance
    obs.sumvar <- PCsumvar(obsPC95)
    obs.prodvar <- PCprodvar(obsPC95)
  
  #Range
    obs.sumrange <- PCsumrange(obsPC95)
    obs.prodrange <- PCprodrange(obsPC95)

######################################################### 
#7)COMPARE OBSERVED AND SIMULATED DISPARITY
#########################################################

#Compare observed disparity to the distribution of simulated values
  # (histograms in the output section below)
  sumvar.p <- pvalue.dist(distribution=simPC.var[,1], obs.val=obs.sumvar)
  prodvar.p <- pvalue.dist(distribution=simPC.var[,2], obs.val=obs.prodvar)
  sumrange.p <- pvalue.dist(distribution=simPC.range[,1], obs.val=obs.sumrange)
  prodrange.p <- pvalue.dist(distribution=simPC.range[,2], obs.val=obs.prodrange)



#Create a table to compare the disparity measures
  disp <- as.data.frame(matrix(NA, nrow=4, ncol=5))
  rownames(disp) <- c("SumVar","ProdVar","SumRange","ProdRange")
  colnames(disp) <- c("Observed","Sim.min","Sim.max", "Sdev.sim","p.value")

    disp[1,1] <- obssumvar
    disp[1,2] <- range(simPC.var[,1])[1]
    disp[1,3] <- range(simPC.var[,1])[2]
    disp[1,4] <- sd(simPC.var[,1])
    disp[1,5] <- sumvar.p

    disp[2,1] <- obsprodvar
    disp[2,2] <- range(simPC.var[,2])[1]
    disp[2,3] <- range(simPC.var[,2])[2]
    disp[2,4] <- sd(simPC.var[,2])
    disp[2,5] <- prodvar.p

    disp[3,1] <- obssumrange
    disp[3,2] <- range(simPC.range[,1])[1]
    disp[3,3] <- range(simPC.range[,1])[2]
    disp[3,4] <- sd(simPC.range[,1])
    disp[3,5] <- sumrange.p

    disp[4,1] <- obsprodrange
    disp[4,2] <- range(simPC.range[,2])[1]
    disp[4,3] <- range(simPC.range[,2])[2]
    disp[4,4] <- sd(simPC.range[,2])
    disp[4,5] <- prodrange.p

#######################################
#8) CREATE THE OUTPUT FILES
#######################################

#Histogram plots of the simulated disparity values
  #arrows point to the observed disparity values for comparison
dev.new()
par(mfrow=c(2,2))

sumvar.hist <- hist(simPC.var$SumVar, xlab="Sum of Variance", main=NULL)
arrow.to.x.point(sumvar.hist, obs.sumvar, fraction.of.yaxis=50, line.fraction.of.yaxis=4,
                    height.above.xaxis=5, head.length=0.15, colour="blue", line.width=2.5)
                    
prodvar.hist <- hist(simPC.var$ProdVar, xlab="Product of Variance", main=NULL)
arrow.to.x.point(prodvar.hist, obs.prodvar, fraction.of.yaxis=50, line.fraction.of.yaxis=4, 
                    height.above.xaxis=5, head.length=0.15, colour="blue", line.width=2.5)

sumrange.hist <- hist(simPC.range$SumRange, xlab="Sum of Ranges", main=NULL)
arrow.to.x.point(sumrange.hist, obs.sumrange, fraction.of.yaxis=50, line.fraction.of.yaxis=4,
                    height.above.xaxis=5, head.length=0.15, colour="blue", line.width=2.5)
                    
prodrange.hist <- hist(simPC.range$ProdRange, xlab="Product of Ranges", main=NULL)
arrow.to.x.point(prodrange.hist, obs.prodrange, fraction.of.yaxis=50, line.fraction.of.yaxis=4,
                    height.above.xaxis=5, head.length=0.15, colour="blue", line.width=2.5)

par(mfrow=c(1,1))

MD.hist <- hist(


