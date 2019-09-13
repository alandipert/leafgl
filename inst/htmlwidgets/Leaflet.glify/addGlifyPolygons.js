(function() {

  function toGeoJSON(pgons) {
    return {
      "type": "FeatureCollection",
      "features": pgons.map(([simple, ...more], i) => {
        // Glify doesn't seem to support Multipolygons in GeoJSON
        if (more.length)
          throw new Error('Multipolygons are currently unsupported');
        return {
          "type": "Feature",
          "properties": { index: i },
          "geometry": {
            "type": "Polygon",
            "coordinates": simple.map(({lng, lat}) => lng.map((lng, i) => [lng, lat[i]]))
          }
        };
      })
    };
  }

  LeafletWidget.methods.addGlifyPolygons = function(data, cols, popup, opacity, group) {
    console.log(popup)
    // popup argument should be the same length as data
    // popup = null, same # elements, some other length
    // shorter = recycle (helper functions in JS)
    var map = this;
      var shapeslayer = L.glify.shapes({
        map: map,
        data: toGeoJSON(data),
        className: group,
        click: (e, feature) => {
          if (map.hasLayer(shapeslayer.glLayer) && popup !== null) {
            L.popup()
              .setLatLng(e.latlng)
              .setContent(popup[feature.properties.index].toString())
              .openOn(map);
          }
        }
      });

    map.layerManager.addLayer(shapeslayer.glLayer, null, null, group);

  };
})();