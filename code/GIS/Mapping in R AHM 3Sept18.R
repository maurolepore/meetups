## Make sure packages installed & updated!

#Mapping in R tutorial 
#AHM 3 September 2018

library(rgdal)
library(raster)
library(ggmap)
library(sp)
library(raster)
library(ggplot2)
      
#Let's make some maps! First, let's grab the data. level= controls the political level (e.g. country, province, county, etc.)
#read in country shapefile, here we're mapping Myanmar
myanmar1 <- getData('GADM' , country="MMR", level=1)

#fortify for mapping with ggplot 
mya.proj <- spTransform(myanmar1, CRS("+proj=longlat +datum=WGS84 +no_defs")) 
my <- fortify(mya.proj)

#create a dummy data frame with some localities
lon <- c(95.8, 98, 96.7, 96.3,94.9)
lat <- c(18.8, 17.4, 18.4, 22.8, 19.2)
my.c <- data.frame(lon, lat)

#plot with fill and points
ggplot() + 
  geom_polygon(data = mya.proj, 
                        aes(long, lat, group = group), 
                        fill = "#f1f4c7", 
                        color = "#afb38a") + 
  geom_point(data = my.c, 
             aes(lon, lat), 
             pch  = 21, 
             color = "black", 
             bg = "blue", cex=3.5) + 
  coord_equal()

#add theme_map() to clean it up!
library(ggthemes)
ggplot() + 
  geom_polygon(data = mya.proj, 
                        aes(long, lat, group = group), 
                        fill = "#f1f4c7", 
                        color = "#afb38a") + 
  geom_point(data = my.c, 
             aes(lon, lat), 
             pch  = 21, 
             color = "black", 
             bg = "blue", cex=3.5) + 
  coord_equal() + 
  theme_map()


#Plot Myanmar Plain
plot(myanmar1, main="Adm. Boundaries myanmar Level 1")

#Plotting elevation, slope, aspect etc.

library(sp)  # classes for spatial data
library(raster)  # grids, rasters
library(rasterVis)  # raster visualisation
library(maptools)
library(rgeos)
# and their dependencies

elevation <- getData("alt", country = "CHN") #China using ISO Alpha-3 country codes
x <- terrain(elevation, opt = c("slope", "aspect"), unit = "degrees")
plot(x)
slope <- terrain(elevation, opt = "slope")
aspect <- terrain(elevation, opt = "aspect")
hill <- hillShade(slope, aspect, 40, 270)
plot(hill, col = grey(0:100/100), legend = FALSE, main = "China")
plot(elevation, col = rainbow(25, alpha = 0.35), add = TRUE)
China01 <- getData('GADM', country='CHN', level=1) #add province borders
plot(China01, add=TRUE) 
#add in other Indochinese countries, level=0 because we only want country borders and not provincial too
myanmar0 <- getData('GADM', country='MMR', level=0)
plot(myanmar0, add=TRUE)
vietnam0 <- getData('GADM', country='VNM', level=0)
plot(vietnam0, add=TRUE)
cambodia0 <- getData('GADM', country='KHM', level=0)
plot(cambodia0, add=TRUE)
laos0 <- getData('GADM', country='LAO', level=0)
plot(laos0, add=TRUE)
thailand0 <- getData('GADM', country='THA', level=0)
plot(thailand0, add=TRUE)
Some_record <- points(100, 40, pch=18, col="red", cex=3) #plot a point
scalebar(500, xy=c(80, 19), type='bar', divs=2, below="km") #add a scalebar


#bathmetry, Sunda Block!
library(devtools)
library(lattice)
library(marmap)
library(marmap) ; library(ggplot2)
dat <- getNOAA.bathy(94.5,130,-15,10,res=4, keep=TRUE) #grab data from NOAA, plotting Western Indochina and adjacent Andaman Sea
# Plot bathy object using custom ggplot2 functions
autoplot(dat, geom=c("r", "c"), colour="white", size=0.1) + scale_fill_etopo()

blues <- colorRampPalette(c("darkblue", "cyan"))
greys <- colorRampPalette(c(grey(0.4),grey(0.99)))

plot.bathy(dat,
           image = TRUE,
           land = TRUE,
           n=0,
           bpal = list(c(0, max(dat), greys(100)),
                       c(min(dat), 0, blues(100))))

sundaland<- getNOAA.bathy(94.5,130,-15,10,resolution=4)
plot.bathy(sundaland,
           image = TRUE,
           land = TRUE,
           n=0,
           bpal = list(c(0, max(sundaland), greys(100)),
                       c(min(sundaland), 0, blues(100))))
#wireframe
wireframe(unclass(sundaland), drape = TRUE,
          aspect = c(1, 0.1),
          scales = list(draw=F,arrows=F),
          xlab="",ylab="",zlab="",
          at=c(min(sundaland)/100*(99:0),max(sundaland)/100*(1:99)),
          col.regions = c(blues(100),greys(100)),
          col='transparent')
#final product
wireframe(unclass(sundaland), shade = TRUE,
          aspect = c(1, 0.1), 
          scales = list(draw=F,arrows=F),
          xlab="",ylab="",zlab="")

#transect plot
plot(sundaland, xlim = c(95, 130),
     deep = c(-5000, 0), shallow = c(0, 0), step = c(1000, 0),
     col = c("lightgrey", "black"), lwd = c(0.8, 1),
     lty = c(1, 1), draw = c(FALSE, FALSE))
#draw the transect belt
belt <- get.box(sundaland, x1 =115, x2 = 120, y1 = -.8, y2 = -.8,
                width = 3, col = "red")
#plot the transect
wireframe(belt, shade = TRUE, zoom = 1.1,aspect = c(1/4, 0.1),
                          screen = list(z = 100, x = 65),
                          par.settings = list(axis.line = list(col = "transparent")),
                          par.box = c(col = rgb(0, 0, 0, 0.1)))

#Using BioClim data
# Altitude
## Get SRTM data 
r_alt<-getData('alt',country="MMR")
plot(r_alt,main= 'Altitude')
hist(r_alt,main= 'Altitude distribution' )

#plot surrounding countries
plot(r_alt,main= 'Altitude')
myanmar0 <- getData('GADM', country='MMR', level=0)
plot(myanmar0, add=TRUE)
thailand0 <- getData('GADM', country='THA', level=0)
plot(thailand0, add=TRUE)
china0 <- getData('GADM', country='CHN', level=0)
plot(china0, add=TRUE)
vietnam0 <- getData('GADM', country='VNM', level=0)
plot(vietnam0, add=TRUE)
cambodia0 <- getData('GADM', country='KHM', level=0)
plot(cambodia0, add=TRUE)
thailand0 <- getData('GADM', country='THA', level=0)
bangladesh0 <- getData('GADM', country='BGD', level=0)
plot(bangladesh0, add=TRUE)
India0 <- getData('GADM', country='IND', level=0)
plot(India0, add=TRUE)

#add in localities 
AS245932_Trimeresurus_popeiorum <- points(98.246917, 14.729694, pch=17, col="red", cex=1.5) #southern T. cf. p. clade
CAS247754_Trimeresurus_popeiorum <- points(98.632861, 10.369167, pch=17, col="red", cex=1.5) #two specimens from this exact GPS coords
USNMFS39832_Trimeresurus_popeiorum <- points(98.632861, 10.369167,pch=17, col="red", cex=1.5)#southern T. cf. p. clade
USNMFS245134_Trimeresurus_popeiorum <-  points(98.947030, 10.958560, pch=17, col="red", cex=1.5)#southern T. cf. p. clade
USNMFS245071_Trimeresurus_popeiorum <- points(98.947030, 10.958560, pch=17, col="red", cex=1.5)#southern T. cf. p. clade
Trimeresurus_toba_MZBOPHI5342 <- points(99, 2, pch=18, col="black", cex=2) 
legend1 <- legendlegend1 <- legend("topleft", inset = c(.15,0.8) , cex = .9 , bty = "n", legend = c("T. sp."), text.col = c("black"), col = c("red"),pt.cex=c(1.75),pt.bg=c("red"), pch = c(17))

#scalebar
scalebar(250, xy=c(87, 17), type='bar', divs=2, below="km")

