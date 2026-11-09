#Generate necessary mask files 

nc_2d_file <- "~/Desktop/Manucripts/phanero_cgenie/muffin.CB.L23z_201_z32.BASES-1.config/biogem/fields_biogem_2d.nc"
cgenie_file <- "~/Desktop/Manucripts/phanero_cgenie/muffin.CB.L23z_201_z32.BASES-1.config"


library(ncdf4)
library(sf)
library(RNetCDF)

#===== Ocean-Land mask ======#
nc <- nc_open(nc_2d_file)
topo <- ncvar_get(nc, "grid_topo")
area <- ncvar_get(nc, "grid_area")
lon <- ncvar_get(nc, "lon")
lat <- ncvar_get(nc, "lat")

#flip right way up and around...
rownames(topo) <- lon
colnames(topo) <- lat
topo <- t(topo)
topo <- topo[as.character(sort(as.numeric(rownames(topo)), decreasing=TRUE)),]


grid_search <- function(topo, row_no, col_no){
  if(row_no==1 & col_no > 1 & col_no < 36){ #cannot search north
    E_cell <- topo[row_no,min(36,col_no+1)]
    SE_cell <- topo[min(36,row_no+1),min(36,col_no+1)]
    S_cell <- topo[min(36,row_no+1),col_no]
    SW_cell <- topo[min(36,row_no+1),max(1,col_no-1)]
    W_cell <- topo[row_no,max(1,col_no-1)]
    surrounding_cells <- c(E_cell, SE_cell, S_cell, SW_cell, W_cell)
  }
  else if(row_no==36 & col_no > 1 & col_no < 36){ #cannot search south
    N_cell <- topo[max(1,row_no-1),col_no]
    NE_cell <- topo[max(1,row_no-1),min(36,col_no+1)]
    E_cell <- topo[row_no,min(36,col_no+1)]
    W_cell <- topo[row_no,max(1,col_no-1)]
    NW_cell <- topo[max(1,row_no-1),max(1,col_no-1)]
    surrounding_cells <- c(N_cell, NE_cell, E_cell, W_cell, NW_cell)
  }
  else if(col_no==1 & row_no > 1 & row_no < 36){ #cannot search west
    N_cell <- topo[max(1,row_no-1),col_no]
    NE_cell <- topo[max(1,row_no-1),min(36,col_no+1)]
    E_cell <- topo[row_no,min(36,col_no+1)]
    SE_cell <- topo[min(36,row_no+1),min(36,col_no+1)]
    S_cell <- topo[min(36,row_no+1),col_no]
    surrounding_cells <- c(N_cell, NE_cell, E_cell, SE_cell, S_cell)
  }
  else if(col_no==36 & row_no > 1 & row_no < 36){ #cannot search east 
    N_cell <- topo[max(1,row_no-1),col_no]
    S_cell <- topo[min(36,row_no+1),col_no]
    SW_cell <- topo[min(36,row_no+1),max(1,col_no-1)]
    W_cell <- topo[row_no,max(1,col_no-1)]
    NW_cell <- topo[max(1,row_no-1),max(1,col_no-1)]
    surrounding_cells <- c(N_cell, S_cell, SW_cell, W_cell, NW_cell)
  }
  else if(row_no==1 & col_no==1){ #cannot search N or W
    E_cell <- topo[row_no,min(36,col_no+1)]
    SE_cell <- topo[min(36,row_no+1),min(36,col_no+1)]
    S_cell <- topo[min(36,row_no+1),col_no]
    surrounding_cells <- c(E_cell, SE_cell, S_cell)
  }
  else if(row_no==1 & col_no==36){ #annot search N or E
    S_cell <- topo[min(36,row_no+1),col_no]
    SW_cell <- topo[min(36,row_no+1),max(1,col_no-1)]
    W_cell <- topo[row_no,max(1,col_no-1)]
    surrounding_cells <- c(S_cell, SW_cell, W_cell)
  }
  else if(row_no==36 & col_no==36){ #cannot search S or E
    N_cell <- topo[max(1,row_no-1),col_no]
    W_cell <- topo[row_no,max(1,col_no-1)]
    NW_cell <- topo[max(1,row_no-1),max(1,col_no-1)]
    surrounding_cells <- c(N_cell, W_cell, NW_cell)
  }
  else if(row_no==36 & col_no==1){ #cannot search S or W
    N_cell <- topo[max(1,row_no-1),col_no]
    NE_cell <- topo[max(1,row_no-1),min(36,col_no+1)]
    E_cell <- topo[row_no,min(36,col_no+1)]
    surround_cells <- c(N_cell, NE_cell, E_cell)
  }
  else{
    #get surrounding cells 
    N_cell <- topo[max(1,row_no-1),col_no]
    NE_cell <- topo[max(1,row_no-1),min(36,col_no+1)]
    E_cell <- topo[row_no,min(36,col_no+1)]
    SE_cell <- topo[min(36,row_no+1),min(36,col_no+1)]
    S_cell <- topo[min(36,row_no+1),col_no]
    SW_cell <- topo[min(36,row_no+1),max(1,col_no-1)]
    W_cell <- topo[row_no,max(1,col_no-1)]
    NW_cell <- topo[max(1,row_no-1),max(1,col_no-1)]
    surrounding_cells <- c(N_cell, NE_cell, E_cell, SE_cell, S_cell, SW_cell, W_cell, NW_cell)
  }
  
  return(surrounding_cells)

}

ocean_land_coast_mask <- topo
for(row_no in 1:nrow(topo)){ #lats
  for(col_no in 1:ncol(topo)){ #lngs
    
    this_cell <- topo[row_no, col_no]
    if(is.na(this_cell)){
      ocean_land_coast_mask[row_no, col_no] <- 'land'
    }
    else{
      
      surrounding_cells <- grid_search(topo, row_no, col_no)
      
      if(any(is.na(surrounding_cells))){
      ocean_land_coast_mask[row_no, col_no] <- 'coast'
      }
      else{
      ocean_land_coast_mask[row_no, col_no] <- 'open'
      }
    } 

  }
}

save(ocean_land_coast_mask, file='data/masks/ocean_land_coast.RData')





