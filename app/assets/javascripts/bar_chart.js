/*global d3, startDate, endDate, startTime, endTime, formatWeek, formatHour, numberToHumanSize, formatFixed, formatDate, formatTime, numberWithDelimiter */

var width = 250,
    height = 100,
    margin = { top: 7, right: 10, bottom: 5, left: 5 },
    colors = ["#1abc9c","#2ecc71","#3498db","#9b59b6","#34495e","#95a6a6"],
    l = 250, // left margin
    r = 150, // right margin
    w = 400, // width of drawing area
    h = 24,  // bar height
    s = 2;   // spacing between bars

// bar chart
function barViz(data, div, count, format) {
  var domain = (format === "days") ? [startDate, endDate] : [startTime, endTime];

  var x = d3.time.scale.utc()
    .domain(domain)
    .rangeRound([0, width]);

  var y = d3.scale.linear()
    .domain([0, d3.max(data, function(d) { return d.values[count]; })])
    .rangeRound([height, 0]);

  var xAxis = d3.svg.axis()
    .scale(x)
    .tickSize(0)
    .ticks(0);

  var chart = d3.select(div).append("svg")
    .data([data])
    .attr("width", margin.left + width + margin.right)
    .attr("height", margin.top + height + margin.bottom)
    .attr("class", "chart barchart")
    .append("svg:g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  var timeStamp = null;

  var bar = chart.selectAll(".bar")
    .data(data)
    .enter().append("rect")
    .attr("class", function(d) {
      if (format === "days") {
        timeStamp = Date.parse(d.key + 'T12:00:00Z');
        var weekNumber = formatWeek(new Date(timeStamp));
        return (weekNumber % 2 === 0) ? "bar viewed" : "bar viewed-alt";
      } else {
        timeStamp = Date.parse(d.key + ':00:01Z');
        var hour = formatHour(new Date(timeStamp));
        return (hour >= 11 && hour <= 22) ? "bar viewed-alt" : "bar viewed";
      }})
    .attr("x", function(d) {
      if (format === "days") {
        return x(new Date(Date.parse(d.key + 'T12:00:00Z')));
      } else {
        return x(new Date(Date.parse(d.key + ':00:00Z')));
      }})
    .attr("width", width/30 - 1)
    .attr("y", function(d) { return y(d.values[count]); })
    .attr("height", function(d) { return height - y(d.values[count]); });

  chart.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + height + ")")
    .call(xAxis);

  chart.selectAll("rect").each(
    function(d) {
      var title = null,
          dateStamp = null,
          dateString = null;

      if (count === "db_size") {
        title = numberToHumanSize(d.values[count]);
      } else if (count === "requests_average") {
        title = formatFixed(d.values[count]) + " ms";
      } else {
        title = formatFixed(d.values[count]);
      }

      if (format === "days") {
        dateStamp = Date.parse(d.key + 'T12:00:00Z');
        dateString = " on " + formatDate(new Date(dateStamp));
      } else {
        dateStamp = Date.parse(d.key + ':00:00Z');
        dateString = " at " + formatTime(new Date(dateStamp));
      }

      $(this).tooltip({ title: title + dateString, container: "body"});
    }
  );

  d3.select(div + "-loading").remove();

  // return chart object
  return chart;
}

// horizontal bar chart
function hBarViz(data, name) {
  // make sure we have data for the chart
  if (typeof data === "undefined") {
    d3.select("#" + name + "-loading").remove();
    return;
  }

  // Works tab
  var chart = d3.select("div#" + name + "-body").append("svg")
    .attr("width", w + l + r)
    .attr("height", data.length * (h + 2 * s) + 30)
    .attr("class", "chart")
    .append("g")
    .attr("transform", "translate(" + l + "," + h + ")");

  var x = null;

  if (name === "work") {
    x = d3.scale.linear()
      .domain([0, d3.max(data, function(d) { return d[name + "_count"]; })])
      .range([0, w]);
  } else {
    x = d3.scale.log()
      .domain([0.1, d3.max(data, function(d) { return d[name + "_count"]; })])
      .range([1, w]);
  }
  var y = d3.scale.ordinal()
    .domain(data.map(function(d) { return d.title; }))
    .rangeBands([0, (h + 2 * s) * data.length]);
  var z = d3.scale.ordinal()
    .domain(data.map(function(d) { return d.group_id; }))
    .range(colors);

  chart.selectAll("text.labels")
    .data(data)
    .enter().append("a").attr("xlink:href", function(d) { return "/sources/" + d.id; }).append("text")
    .attr("x", 0)
    .attr("y", function(d) { return y(d.title) + y.rangeBand() / 2; })
    .attr("dx", 0 - l) // padding-right
    .attr("dy", ".18em") // vertical-align: middle
    .text(function(d) { return d.title; });

  chart.selectAll("rect")
    .data(data)
    .enter().append("rect")
    .attr("fill", function(d) { return z(d.group_id); })
    .attr("y", function(d) { return y(d.title); })
    .attr("height", h)
    .attr("width", function(d) { return x(d[name + "_count"]); });

  chart.selectAll("text.values")
    .data(data)
    .enter().append("text")
    .attr("x", function(d) { return x(d[name + "_count"]); })
    .attr("y", function(d) { return y(d.title) + y.rangeBand() / 2; })
    .attr("dx", 5) // padding-right
    .attr("dy", ".18em") // vertical-align: middle
    .text(function(d) { return numberWithDelimiter(d[name + "_count"]); });

  d3.select("#" + name + "-loading").remove();
}
