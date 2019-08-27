LeafletWidget.methods.addGlifyPoints = function(lat, lng, layerId, color, group) {

  if(!($.isEmptyObject(lat) || $.isEmptyObject(lng)) ||
      ($.isNumeric(lat) && $.isNumeric(lng))) {

    const df = new LeafletWidget.DataFrame()
      .col("lat", lat)
      .col("lng", lng)
      .col("layerId", layerId)
      .col("group", group);

    const points = df.col("lat").map((lat, i) => [lat, df.get(i, "lng")]);

    const pointsLayer = L.glify.points({
      map: this,
      click: (e, [lat, lng], {x, y}) => {
        console.log("click", e, lat, lng, x, y);
      },
      data: points,
      size: 10,
      color: color
    });

    this.layerManager.addLayer(pointsLayer.glLayer, null, null, group);
  }
};
