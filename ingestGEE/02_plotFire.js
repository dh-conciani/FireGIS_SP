// Load burned area for são paulo state cerrado
// Conciani et al., 2022

// load cerrado biome
var biomes = ee.Image('projects/mapbiomas-workspace/AUXILIAR/biomas-estados-2016-raster');

// load data and retrieve metadata from basenames
var files = ee.ImageCollection('users/dh-conciani/fire_sp')
            // get basenames and retrieve metadata 
            .map(function(image) {
              return image.set(
                {
                  'path_row': ee.String(image.get('system:index')).split('_').get(0)
                }
              )
              .set(
                {
                  'year':  ee.String(image.get('system:index')).split('_').get(1)
                }
              )
              // update for são paulo's cerrado
              .updateMask(biomes.eq(435));
            }
          );


// get image for the year (from 1985 to 2018)
var fire = files.filterMetadata('year', 'equals', '2018').min().aside(print);

// plot
Map.addLayer(fire, {palette:['darkgreen', 'green', 'yellow', 'orange', 'red', 'yellow', 'green'], 
                      min:1, max:365 }, 'fire');
