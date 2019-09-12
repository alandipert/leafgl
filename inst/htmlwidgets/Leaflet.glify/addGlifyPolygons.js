(function() {

  function toGeoJSON(pgons) {
    return {
      "type": "FeatureCollection",
      "features": pgons.map(([simple, ...more]) => {
        // Glify doesn't seem to support Multipolygons in GeoJSON
        if (more.length)
          throw new Error('Multipolygons are currently unsupported');
        return {
          "type": "Feature",
          "properties": {},
          "geometry": {
            "type": "Polygon",
            "coordinates": simple.map(({lng, lat}) => lng.map((lng, i) => [lng, lat[i]]))
          }
        };
      })
    };
  }

  LeafletWidget.methods.addGlifyPolygons = function(data, cols, popup, opacity, group) {
    // popup argument should be the same length as data
    // popup = null, same # elements, some other length
    // shorter = recycle (helper functions in JS)
    var map = this;
      var shapeslayer = L.glify.shapes({
        map: map,
        data: toGeoJSON(data),
        className: group,
        click: function(e) {
          // Instead of indexing into geojson feature properties, just indexes into data
          // can use modular arith to cycle instead of using DataFrame stuff from leaflet maybe
        }
      });

    map.layerManager.addLayer(shapeslayer.glLayer, null, null, group);

  };
})();