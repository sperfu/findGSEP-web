#source("prepare_findGSE.R")
#source("prepare_findGSE_server_1205.R")
#source("prepare_findGSE_server_0106.R")
#source("prepare_findGSE_server_0115.R")
#source("prepare_findGSE_server_0202.R")
source("prepare_findGSE_server_0521.R")

options(warn = -1)
# 读取命令行参数
args <- commandArgs(trailingOnly = TRUE)

# 解析参数值
path <- args[1]
samples <- args[2]
sizek <- as.numeric(args[3])
exp_hom <- as.numeric(args[4])
ploidy <- as.numeric(args[5])
range_left <- as.numeric(args[6])
range_right <- as.numeric(args[7])
xlimit <- as.numeric(args[8])
ylimit <- as.numeric(args[9])
output_dir <- args[10]

findGSEX(path, samples, sizek, exp_hom, ploidy, range_left, range_right, xlimit, ylimit,output_dir)


