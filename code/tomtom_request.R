# Request
request_tomtom <- function(lat,lon){
  url_part_1 <- 'https://api.tomtom.com/traffic/services/4/flowSegmentData/absolute/15/json?point='
  coords <- paste(lat,"%2C",lon,sep="")
  url_part_2 <-paste("&unit=KMPH&openLr=false&key=",key,sep="")
  url <- paste(url_part_1,coords,url_part_2,sep="")
   #---  Request en la API
  response <- GET(url)
  resp_json <- fromJSON(content(response, as = "text"))
  df = data.frame ( frc = resp_json[["flowSegmentData"]][["frc"]],
                    currentSpeed = resp_json[["flowSegmentData"]][["currentSpeed"]],
                    currentTravelTime = resp_json[["flowSegmentData"]][["currentTravelTime"]],
                    freeFlowTravelTime = resp_json[["flowSegmentData"]][["freeFlowTravelTime"]],
                    confidence = resp_json[["flowSegmentData"]][["confidence"]])
  return (df)
}

#################################################################
rbind_recorridos <- data.frame()
for (x in 1:nrow(recorrido)){
  if (x%%5 == 0){
    df <- data.frame(recorrido[x,])
    rbind_recorridos <- rbind(rbind_recorridos,df)
  }
    
}
#write.csv(rbind_recorridos,"rbind_prueba.csv")
df_rbind_request<- data.frame()
for (i in 1:nrow(rbind_recorridos)){
  request<-request_tomtom(lat=rbind_recorridos$lat[i],lon=rbind_recorridos$long[i])
  x <- rbind_recorridos$long[i]
  y <- rbind_recorridos$lat[i]
  df_request <- data.frame(long=x, lat=y, 
                           frc = request$frc,
                           currentSpeed = request$currentSpeed,
                           currentTravelTime = request$currentTravelTime,
                           freeFlowTravelTime = request$freeFlowTravelTime,
                           confidence = request$confidence)
  df_rbind_request <- rbind(df_rbind_request,df_request)
}
names(df_rbind_request) <- c("long","lat","frc","currentSpeed",
                             "currentTravelTime" , "freeFlowTravelTime",
                             "confidence")
merge_vars <- merge(rbind_recorridos,df_rbind_request,by = c("long","lat"))


for(j in 1:(nrow(merge_vars))-1){
  data <- data.frame(x = c(merge_vars$long[j],merge_vars$long[j+1]),
                     y = c(merge_vars$lat[j],merge_vars$lat[j+1]))
  point <-points_to_line (data=data, "x", "y", id_field = NULL, sort_field = NULL)
  if (j==1){
    
       point_rbind <- point
  }else{
    point_rbind <- rbind(point_rbind,point)

  }
}

  df_spatial <- data.frame(merge_vars[1:length(point_rbind),])
  df2<-SpatialLinesDataFrame(point_rbind, df_spatial  , match.ID = F)

  proj4string(df2) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
  #crs(df2) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

  
}


point <-points_to_line (data=data, "x", "y", id_field = NULL, sort_field = NULL)


#df_spatial <- data.frame(merge_prueba[1,])
rbind
df2<-SpatialLinesDataFrame(point, merge_vars  , match.ID = F)
proj4string(df2) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
crs(df2) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
crs()
# ------------                  ELECCION DE RUTA         ----------------
#Guardamos la informacion en un .shp temporal
writeOGR(df2,"./temp","temp6", driver="ESRI Shapefile")


#################################################################
# punto 
lat= -32.87139808939708
lon =-68.8383071895737

df_grid = data.frame(x,y)
coordinates(df_grid) <- ~x+y
proj4string(df_grid) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

df_transform = spTransform(df_grid,CRS("+proj=utm +zone=19 +south +ellps=WGS72 +towgs84=0,0,1.9,0,0,0.814,-0.38 +units=m +no_defs +type=crs"))
df_st = st_as_sfc(df_transform)
buffer<- st_buffer(df_st , 200)
df_x <- c(514626.5,515626.5)
df_y <- c(6362459,6363459)
df_coords <- data.frame(df_x,df_y)
#Creo puntos a 100 mts
grid <- pred_grid(df_coords, by = 300)
names(grid)<-c("x","y")
coordinates(grid) <- ~x+y
proj4string(grid) <- CRS("+proj=utm +zone=19 +south +ellps=WGS72 +towgs84=0,0,1.9,0,0,0.814,-0.38 +units=m +no_defs +type=crs")

grid_transform = spTransform(grid,CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))


names(grid)<- c("y","x")
df_transform_grid <- data.frame(grid_transform@coords)
class(grid)
df_rbind_request<- data.frame()
for (i in 1:nrow(df_transform_grid)){
    request<-request_tomtom(lat=df_transform_grid[i,2],lon=df_transform_grid[i,1])
    x <- df_transform_grid$x[i]
    y <- df_transform_grid$y[i]
    df_request <- data.frame(lon=x, lat=y, 
                   frc = request$frc,
                   currentSpeed = request$currentSpeed,
                   currentTravelTime = request$currentTravelTime,
                   freeFlowTravelTime = request$freeFlowTravelTime,
                   confidence = request$confidence)
    df_rbind_request <- rbind(df_rbind_request,df_request)
  
}
