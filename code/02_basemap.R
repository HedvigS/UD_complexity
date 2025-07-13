library(ggplot2, lib.loc = "../utility/packages/")
library(dplyr, lib.loc = "../utility/packages/")
library(magrittr, lib.loc = "../utility/packages/")

world <- ggplot2::map_data('world2', 
                           wrap=c(-25,335), #rewrapping the worldmap, i.e. shifting the center. I prefer this to world2 because I like to adjust the wrapping a bit differently, and world2 results in polygons leaking
                           )

lakes <- ggplot2:: map_data("lakes", 
                            wrap=c(-25,335), 
                            col="white", border="gray")

#Basemap
basemap <- ggplot2::ggplot() +
  ggplot2::geom_polygon(data=world, ggplot2::aes(x=long, #plotting the landmasses
                               y=lat,group=group),
               colour="gray90",
               fill="gray90", linewidth = 0.5) +
  ggplot2::geom_polygon(data=lakes, ggplot2::aes(x=long,#plotting lakes
                               y=lat,group=group),
               colour="gray90",
               fill="white", linewidth = 0.3)  +
  ggplot2::theme(#all of theme options are set such that it makes the most minimal plot, no legend, not grid lines etc
    panel.grid.major = ggplot2::element_blank(), 
    panel.grid.minor = ggplot2::element_blank(),
    axis.title.x=ggplot2::element_blank(),
    axis.title.y=ggplot2::element_blank(),
    axis.line = ggplot2::element_blank(),
    panel.border = ggplot2::element_blank(),
    panel.background = ggplot2::element_rect(fill = "white"),
    axis.text.x = ggplot2::element_blank(),
    axis.text.y = ggplot2::element_blank(),
    axis.ticks = ggplot2::element_blank())   +
  ggplot2::coord_quickmap(xlim=c(-24, 180), ylim=c(-40, 75), expand = FALSE)

