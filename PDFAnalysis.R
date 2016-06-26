require(ggplot2)
a2tbl <- read.delim("AnnArborTrialBalanceListing.csv")
a2tbl <- a2tbl[!is.na(a2tbl$NumberScale2),c(2,4)]
a2tbl <- data.frame(a2tbl, colClust=cut(a2tbl$RightPoints, breaks = 5))

# append cluster assignment

p <- ggplot(data=a2tbl, aes(x=LeftPoints, y=RightPoints)) +
  geom_point(aes(color=colClust),alpha=.04, size=4)
p + scale_colour_brewer(palette = "Set1")

require(dplyr)
midPointDataFrame <- a2tbl %>% group_by(colClust) %>% summarise(MinRangeMidpoint = (max(LeftPoints) + min(RightPoints))/2)
colMinRangeMidpoints <- min(round(midPointDataFrame$MinRangeMidpoint,-3)) + mean(diff(round(midPointDataFrame$MinRangeMidpoint,-3))) * seq(0,(nrow(midPointDataFrame)-1))