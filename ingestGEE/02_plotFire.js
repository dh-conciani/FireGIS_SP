// Load burned area for são paulo state cerrado
// Conciani et al., 20XX

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

// build image (one year per band)
var recipe = ee.Image([]);
// for each year
ee.List.sequence({'start': 1985, 'end': 2018}).getInfo()
  .forEach(function(year_i) {
    var file_i = files.filterMetadata('year', 'equals', String(year_i)).min();
    // insert into recipe
    recipe = recipe.addBands(file_i.rename('fire_' + String(year_i)));
  }
);

// compute fire frequency 
var freq = recipe.reduce(ee.Reducer.countDistinctNonNull());

// get image for the year (from 1985 to 2018)
var fire = recipe.select(['fire_2010']);

// plot
Map.addLayer(fire, {palette:['darkgreen', 'green', 'yellow', 'orange', 'red', 'yellow', 'green'], 
                      min:1, max:365 }, 'Fire 2010', false);

// plot frequency 
Map.addLayer(freq, {palette:['yellow', 'orange', 'red', 'purple'], min:1, max:7}, 'Frequency 1985-2018');
