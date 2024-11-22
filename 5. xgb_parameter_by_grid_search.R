# author: "Jim Holland"
#!/usr/bin/env Rscript
#g2f xgboost grid search 
#code for scinet cluster runs 
args = commandArgs(TRUE)
eta.n = as.numeric(args[1]) #eta.n given as command line argument
print(eta.n)


library(data.table)
#library(tidyverse)
library(xgboost, lib.loc = c("/home/jim.holland/R/x86_64-pc-linux-gnu-library/4.2"))

g2f = fread(file = "G2F_EC477_geno500_ge1k.csv")
metaCols = names(g2f)[1:8]
#make boolean vectors of train and test observations
train = g2f$Year < 2021
test = g2f$Year == 2021
valid = g2f$Year == 2022
x = copy(g2f) #need to make deep copies because otherwise data.table assignments are by reference and you will be in a world of hurt
x = x[,c(metaCols):=NULL]
y = copy(g2f)
y = y[, yield]

param_grid = expand.grid(
  year = 2014:2021,
  ntrees = c(10, 100, 1000),
  SubsampleRate = c(0.1, 0.25, 0.5, 0.75, 1), 
  ColsampleRate = c(0.1, 0.25, 0.5, 0.75, 1), 
  eta.n = eta.n)

#Make a function to perform Leave-one-year-out cross validation
loyo.cv = function(df.all, x.all, y.all, year,  ntrees, SubsampleRate, ColsampleRate, eta.n){ 
    train = df.all$Year != year & g2f$Year != 2022
    test = df.all$Year == year
    xtest = copy(x.all)[test,]
    xtrain = copy(x.all)[train,]
    ytest = copy(y.all)[test]
    ytrain = copy(y.all)[train]
    
    train.dm = xgb.DMatrix(data = as.matrix(xtrain), label = ytrain)
    test.dm = xgb.DMatrix(data = as.matrix(xtest))
    
    ptm <- proc.time()
    
    xgb.fit = xgboost(data = train.dm, nrounds = ntrees, verbose = 0, "eval_metric" = "rmse", "objective" = "reg:squarederror", "eta" = eta.n, "subsample" = SubsampleRate, "colsample_bytree" = ColsampleRate)
    
    xgb.pred = predict(xgb.fit, newdata = test.dm) 
    
    stopwatch = proc.time() - ptm
    RMSE = sqrt(mean(xgb.pred - ytest)^2)
    r = cor.test(xgb.pred,ytest)
    curr.result = data.frame(ntrees = ntrees, SubsampleRate = SubsampleRate, Year = year,  ColsampleRate = ColsampleRate, eta.n = eta.n, RMSE = RMSE, r = r$estimate, time = stopwatch["elapsed"])
    
    write.table(curr.result, file = paste0("xgb_grid_results2_eta", eta.n, ".csv"), row.names = F, sep = ",", append = T, col.names = !file.exists(paste0("xgb_grid_results2_eta", eta.n, ".csv")))
              
    return(curr.result)} #end function

#Run the loyo.cv function on each parameter combination
results = apply(param_grid, 1, function(z) loyo.cv(
  df.all = g2f,
  x.all = x,
  y.all = y,
  year = z['year'],
  ntrees = z['ntrees'], 
  SubsampleRate = z['SubsampleRate'],
  ColsampleRate = z['ColsampleRate'], 
  eta.n = z['eta.n']))

#save the resulting data.frame
results.df = do.call(rbind, results)
write.csv(results.df, file = paste0("xgb_grid_results2_all_eta", eta.n, ".csv"), row.names = F)

