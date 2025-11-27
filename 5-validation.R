# The purpose of this file is to validate the relative exposure index

# Packages needed ----
library(terra)
library(tidyverse)
library(ggExtra)

# Load data ----
REI<-REI <- rast("Ireland_REI.tif")
SWAN_max<-rast('irish_shelf_overall_max_hs.tif')

# Check data ----
plot(REI)
plot(SWAN_max)

# Same projection and extent ----
SWAN_max_proj <- project(SWAN_max, crs(REI))
SWAN_max_crop <- crop(SWAN_max_proj, ext(REI)) ### Crop SWAN

## Resample REI to SWAN resolution
REI_resampled <- resample(REI, SWAN_max_crop, method = "bilinear")

## Check extent and dimensions
ext(REI_resampled)
ext(SWAN_max_crop)
dim(REI_resampled)
dim(SWAN_max_crop)

stacked <- c(REI_resampled, SWAN_max_crop)

# Correlation testing ----
Exposure_max_df <- as.data.frame(stacked, xy = TRUE, na.rm = TRUE)
colnames(Exposure_max_df) <- c("x", "y", "REI", "SWAN_Hs")

head(Exposure_max_df)
summary(Exposure_max_df)
cor(Exposure_max_df$REI, Exposure_max_df$SWAN_Hs, method = "pearson", use = "complete.obs")
cor.test(Exposure_max_df$REI, Exposure_max_df$SWAN_Hs, method = "pearson") ### Same correlation 

# Plot ----
p_max<-ggplot(Exposure_max_df, aes(x = REI, y = SWAN_Hs))+
  geom_point(color = "steelblue4", size = 1) +
  geom_smooth(method = "lm", color = "red3", se = FALSE, size = 2) +
  labs(
    x = "Relative exposure index",
    y = expression("Maximum "~italic(H)[s]~" (m)")) +
  scale_y_continuous(breaks = seq(0,7,1),limits=c(0,7))+
  theme_bw()+ theme(panel.grid.major = element_line(linetype = "blank"),
                    panel.grid.minor = element_line(linetype = "blank"))+
  annotate("text", x = 1, y=6.5, label = "italic(r) == 0.89",parse = TRUE)


## add marginal plots
p_max2<-ggMarginal(
  p_max,
  type = 'boxplot',
  margins = 'both',
  size = 7,
  colour = '#000000',
  fill = 'steelblue4'
)

p_max2


# Now for mean Hs ----
# Load data ----
SWAN_mean<-rast('irish_shelf_overall_mean_hs.tif')
plot(SWAN_mean)

# Same projection and extent ----
SWAN_mean_proj <- project(SWAN_mean, crs(REI))

SWAN_mean_crop <- crop(SWAN_mean_proj, ext(REI)) ### Crop SWAN

## Resample REI to SWAN resolution
REI_resampled <- resample(REI, SWAN_mean_crop, method = "bilinear")

## Check extent and dimensions
ext(REI_resampled)
ext(SWAN_mean_crop)
dim(REI_resampled)
dim(SWAN_mean_crop)

stacked <- c(REI_resampled, SWAN_mean_crop)

# Correlation testing ----
Exposure_mean_df <- as.data.frame(stacked, xy = TRUE, na.rm = TRUE)
colnames(Exposure_mean_df) <- c("x", "y", "REI", "SWAN_Hs")

head(Exposure_mean_df)
summary(Exposure_mean_df)
cor(Exposure_mean_df$REI, Exposure_mean_df$SWAN_Hs, method = "pearson", use = "complete.obs")
cor.test(Exposure_mean_df$REI, Exposure_mean_df$SWAN_Hs, method = "pearson") ### Same correlation 

# Plot ----
p_mean<-ggplot(Exposure_mean_df, aes(x = REI, y = SWAN_Hs))+
  geom_point(color = "steelblue4", size = 1) +
  geom_smooth(method = "lm", color = "red3", se = FALSE, size = 2) +
  labs(
    x = "Relative exposure index",
    y = expression("Mean "~italic(H)[s]~" (m)")) +
  scale_y_continuous(breaks = seq(0,3,.5),limits=c(0,3))+
  theme_bw()+ theme(panel.grid.major = element_line(linetype = "blank"),
                    panel.grid.minor = element_line(linetype = "blank"))+
  annotate("text", x = 1, y=2.75, label = "italic(r) == 0.85",parse = TRUE)


## add marginal plots
p_mean2<-ggMarginal(
  p_mean,
  type = 'boxplot',
  margins = 'both',
  size = 7,
  colour = '#000000',
  fill = 'steelblue4'
)

p_mean2

# Combine plots ----
tiff(filename = 'validation_plot_combined.tif',res=300,width =20, height=10, unit='cm')

ggarrange(p_mean2,p_max2,ncol=2,labels = c("(a)","(b)"))

dev.off()

