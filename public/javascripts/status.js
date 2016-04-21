/*global d3, barViz, donutViz */

var endDate = new Date(),
    startDate = d3.time.day.offset(endDate, -29),
    endTime = endDate.setHours(23),
    startTime = d3.time.hour.offset(endTime, -23),
    colors = d3.scale.ordinal().range(["#1abc9c","#ecf0f1","#f1c40f"]),
    query = encodeURI("/api/status");

// load the data from the Spinone API
d3.json(query)
  .header("Accept", "application/json")
  .get(function(error, json) {
    if (error) { return console.warn(error); }
    var data = json.data;

    // aggregate status by day
    var day_data = data.filter(function(status) {
      return Date.parse(status.attributes.timestamp) >= startDate;
    });
    var by_day = d3.nest()
      .key(function(d) { return d.attributes.timestamp.substr(0,10); })
      .rollup(function(leaves) {
        return { "datacite_crossref": d3.max(leaves, function(d) { return d.attributes.datacite_crossref;}),
                 "orcid": d3.max(leaves, function(d) { return d.attributes.orcid;}),
                 "orcid_update": d3.max(leaves, function(d) { return d.attributes.orcid_update;}),
                 "related_identifier": d3.max(leaves, function(d) { return d.attributes.related_identifier;})
                };})
      .entries(day_data);

    barViz(by_day, "#chart_datacite_crossref", "datacite_crossref", "days");
    barViz(by_day, "#chart_orcid", "orcid", "days");
    barViz(by_day, "#chart_orcid_update", "orcid_update", "days");
    barViz(by_day, "#chart_related_identifier", "related_identifier", "days");
});
