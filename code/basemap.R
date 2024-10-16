source("01_requirements.R")

Glottolog <- read_tsv("../data/glottolog_language_table_wide_df_3.0.tsv", show_col_types = F) %>% 
  dplyr::select(glottocode = Glottocode, Longitude, Latitude, Family_ID, Language_level_ID, Name) %>% 
  dplyr::mutate(Longitude = if_else(Longitude <= -25, Longitude + 360, Longitude)) 

#fetching datasets
world <- ggplot2::map_data('world2', 
                           wrap=c(-25,335), #rewrapping the worldmap, i.e. shifting the center. I prefer this to world2 because I like to adjust the wrapping a bit differently, and world2 results in polygons leaking
                           ylim=c(-55,90)) #cutting out antarctica (not obligatory) and the northermost part where there are no language points in glottolog

lakes <- ggplot2::map_data("lakes", 
                           wrap=c(-25,335), 
                           col="white", border="gray",  
                           ylim=c(-55,90))


#Basemap
basemap <- ggplot(Glottolog) +
  geom_polygon(data=world, aes(x=long, #plotting the landmasses
                               y=lat,group=group),
               colour="gray90",
               fill="gray90", linewidth = 0.5) +
  geom_polygon(data=lakes, aes(x=long,#plotting lakes
                               y=lat,group=group),
               colour="gray90",
               fill="white", size = 0.3)  +
  theme(#all of theme options are set such that it makes the most minimal plot, no legend, not grid lines etc
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(),
    axis.title.x=element_blank(),
    axis.title.y=element_blank(),
    axis.line = element_blank(),
    panel.border = element_blank(),
    legend.position = "none",
    panel.background = element_rect(fill = "white"),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank())   +
  coord_map(projection = "vandergrinten") 



