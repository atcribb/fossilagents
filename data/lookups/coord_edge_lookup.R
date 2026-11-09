nc_2d_file <- "~/Desktop/Manucripts/phanero_cgenie/muffin.CB.L23z_201_z32.BASES-1.config/biogem/fields_biogem_2d.nc"
library(ncdf4)
library(sf)
library(RNetCDF)

#===== Ocean-Land mask ======#
nc <- nc_open(nc_2d_file)
topo <- ncvar_get(nc, "grid_topo")
lon <- ncvar_get(nc, "lon")
lat <- ncvar_get(nc, "lat")
lat_edges <- sort(ncvar_get(nc, "lat_edges"), decreasing=TRUE)
lon_edges <- ncvar_get(nc, "lon_edges")
rownames(topo) <- lon
colnames(topo) <- lat
topo <- t(topo)
topo <- topo[as.character(sort(as.numeric(rownames(topo)), decreasing=TRUE)),]

lat_edge_lookup <- as.data.frame(matrix(NA, nrow=36, ncol=3))
colnames(lat_edge_lookup) <- c('cgenie_lat', 'north_edge', 'south_edge')
lat_edge_lookup$cgenie_lat <- sort(lat, decreasing=TRUE)
lat_edge_lookup$north_edge <- lat_edges[1:36]
lat_edge_lookup$south_edge <- lat_edges[2:37]
save(lat_edge_lookup, file='data/lookups/cell_lat_edges.RData')

lng_edge_lookup <- as.data.frame(matrix(NA, nrow=36, ncol=3))
colnames(lng_edge_lookup) <- c('cgenie_lon', 'west_edge', 'east_edge')
lng_edge_lookup$cgenie_lon <- lon
lng_edge_lookup$west_edge <- lon_edges[1:36]
lng_edge_lookup$east_edge <- lon_edges[2:37]
save(lng_edge_lookup, file='data/lookups/cell_lng_edges.RData')

