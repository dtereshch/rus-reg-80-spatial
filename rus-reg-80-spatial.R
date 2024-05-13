library(dplyr)
library(sf)
library(geodata)

rus_reg_gpkg <- geodata::gadm(country = 'RUS', level = 1, path = tempdir(), version = 3.6)

rus_reg_sf <- st_as_sf(rus_reg_gpkg) %>% 
  st_transform(crs = '+proj=longlat +lon_wrap=180')

plot(rus_reg_sf$geometry)

rus_reg_sf$NAME_1

arkh_units <- c("Arkhangel'sk", "Nenets")
tyum_units <- c("Tyumen'", "Khanty-Mansiy", "Yamal-Nenets")
auto_units <- c("Nenets", "Khanty-Mansiy", "Yamal-Nenets")

arkh_sf <- rus_reg_sf %>% dplyr::filter(NAME_1 %in% arkh_units)
tyum_sf <- rus_reg_sf %>% dplyr::filter(NAME_1 %in% tyum_units)

arkh_polyg <- arkh_sf %>% sf::st_union()
tyum_polyg <- tyum_sf %>% sf::st_union()

rus_reg_sf_80 <- rus_reg_sf %>% 
  dplyr::filter(!NAME_1 %in% auto_units) %>%
  dplyr::mutate(geometry = case_when(NAME_1 == "Arkhangel'sk" ~ arkh_polyg,
                                     NAME_1 == "Tyumen'" ~ tyum_polyg,
                                     .default = geometry))

plot(rus_reg_sf_80$geometry)

dir.create("rus_reg_80")
rus_reg_sf_80 %>% sf::st_write("rus_reg_80/rus_reg_80.shp", append = FALSE)
