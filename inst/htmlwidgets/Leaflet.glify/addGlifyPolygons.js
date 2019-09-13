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

  function hexToRgb(hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex.toLowerCase());
    return result ? {
      r: parseInt(result[1], 16),
      g: parseInt(result[2], 16),
      b: parseInt(result[3], 16)
    } : null;
  }

  LeafletWidget.methods.addGlifyPolygons = function(data, color, popup, opacity, group) {
    // popup argument should be the same length as data
    // popup = null, same # elements, some other length
    // shorter = recycle (helper functions in JS)
    var map = this;
      var shapeslayer = L.glify.shapes({
        map: map,
        data: toGeoJSON(data),
        className: group,
        color: (idx, feature) => {
          if (color !== null) {
            return hexToRgb(color[feature.properties.index]);
          }
        },
        click: (e, feature) => {
          console.log(e, feature)
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