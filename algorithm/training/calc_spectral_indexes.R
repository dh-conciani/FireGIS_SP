## Calc spectral indexes in a Reflectance array
## Dhemerson Conciani (dh.conciani@gmail.com)
## Equations in (https://landsat.usgs.gov/sites/default/files/documents/si_product_guide.pdf)

## Library
library (RStoolbox)

## NDVI - Normalized Difference Vegetation Index
assis_reflectance$NDVI = (assis_reflectance$NIR - assis_reflectance$Red)/(assis_reflectance$NIR + assis_reflectance$Red)

## GNDVI - Green Normalised Difference Vegetation Index
assis_reflectance$GNDVI = (assis_reflectance$NIR - assis_reflectance$Green)/(assis_reflectance$NIR + assis_reflectance$Green)

## MSAVI - Modified Soil Adjusted Vegetation Index
assis_reflectance$MSAVI = assis_reflectance$NIR + 0.5 - (0.5 * sqrt((2 * assis_reflectance$NIR + 1)^2 - 8 * (assis_reflectance$NIR - (2 * assis_reflectance$Red))))

## NDWI - Normalised Difference Water Index
assis_reflectance$NDWI = (assis_reflectance$Green - assis_reflectance$NIR)/(assis_reflectance$Green + assis_reflectance$NIR)

## SLAVI - Specific Leaf Area Vegetation Index
assis_reflectance$SLAVI = assis_reflectance$NIR/(assis_reflectance$Red + assis_reflectance$SWIR2)

## NBR - Normalized Burn Ratio
assis_reflectance$NBR = ((assis_reflectance$NIR - assis_reflectance$SWIR1) / (assis_reflectance$NIR + assis_reflectance$SWIR1))

## BAIM - Burned Area Index
assis_reflectance$BAIM = 1 / ((0.05 - assis_reflectance$NIR)^2 + (0.2 - assis_reflectance$SWIR1)^2)

## CSI - Char Soil Index
assis_reflectance$CSI = assis_reflectance$NIR / assis_reflectance$SWIR1

## MIRBI - Mid Infrared Burn Index
assis_reflectance$MIRBI = 10 * assis_reflectance$SWIR1 - 9.8 * assis_reflectance$NIR + 2

## SMI - Salt Mineral Index 
assis_reflectance$SMI = sqrt ((assis_reflectance$Blue^2 + assis_reflectance$Green^2 + assis_reflectance$Red^2) / assis_reflectance$SWIR2)

## MI - Mineral Index
assis_reflectance$MI = ((assis_reflectance$Blue * assis_reflectance$Green * assis_reflectance$Red) / assis_reflectance$NIR)

## S2 - Salinity Index 2 (sand higly)
assis_reflectance$S2 = (assis_reflectance$Blue - assis_reflectance$Red) / (assis_reflectance$Blue + assis_reflectance$Red)

## IRI - Infrared Index (quatz)
assis_reflectance$IRI = sqrt ((assis_reflectance$NIR^2 + assis_reflectance$SWIR2^2) / assis_reflectance$SWIR1)

boxplot (NDVI ~ Class, assis_reflectance)
