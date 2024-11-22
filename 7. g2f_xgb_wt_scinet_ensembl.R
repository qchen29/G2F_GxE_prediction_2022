#!/usr/bin/env Rscript
#g2f xgboost final predictions for scinet cluster runs 
args = commandArgs(TRUE) #ntrees eta SubsampleRate ColsampleRate given as command line arguments, in that order
ntrees = as.numeric(args[1])
eta.n = as.numeric(args[2])
SubsampleRate = as.numeric(args[3])
ColsampleRate = as.numeric(args[4])
print("parameters ntree, eta, SubsampleRate, ColsampleRate:")
print(ntrees)
print(eta.n)
print(SubsampleRate)
print(ColsampleRate)

library(data.table)
library(xgboost, lib.loc = c("/home/jim.holland/R/x86_64-pc-linux-gnu-library/4.2"))

g2f = fread(file = "G2F_EC477_geno500_ge1k_wt.csv")
metaCols = names(g2f)[1:8]
#make boolean vectors of train and test observations
tr = g2f$Year < 2022
valid = g2f$Year == 2022
x = copy(g2f) #need to make deep copies because otherwise data.table assignments are by reference and you will be in a world of hurt

weights = copy(x)[, weight.c] # weight.c is the combined weighting based on BLUE precision + similarity to test set
weights = weights[tr] #weights only needed for training set

x = x[,c(metaCols):=NULL]
y = copy(g2f)
y = y[, yield]


xtrain = copy(x)[tr,]
xtest = copy(x)[valid,]
ytrain = copy(y)[tr]

train.dm = xgb.DMatrix(data = as.matrix(xtrain), label = ytrain, weight = weights)
test.dm = xgb.DMatrix(data = as.matrix(xtest))

xgb.prediction = function(dm = train.dm, ntrees, eta.n, SubsampleRate, ColsampleRate){
  xgb.fit = xgboost(data = dm, nrounds = ntrees,  verbose = 0, "eval_metric" = "rmse", "objective" = "reg:squarederror", "eta" = eta.n, "subsample" = SubsampleRate, "colsample_bytree" = ColsampleRate)
 xgb.pred = predict(xgb.fit, newdata = test.dm) 
 return(xgb.pred)
}

n.reps = 100
df.pred.reps = data.frame(matrix(NA, nrow = nrow(xtest), ncol = n.reps))
for (i in 1:n.reps) {
print(i)
df.pred.reps[,i] = xgb.prediction(ntrees = ntrees, eta.n = eta.n, SubsampleRate = SubsampleRate, ColsampleRate = ColsampleRate)
}

write.table(df.pred.reps, file = paste0("xgb_wt_pred_", ntrees, "_", eta.n, "_", SubsampleRate, "_", ColsampleRate))
