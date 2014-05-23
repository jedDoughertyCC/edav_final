var regions = { "nodrinkhappy": "No Drinks Woke up Happy" , "smalldrinkhappy": "Had Drinks Woke up happy", "muchdrinkhappy": "Lots of Drinks Woke up happy", "nodrinksad": "No drinks Woke up sad", "smalldrinksad": "Small drinks Woke up sad", "muchdrinksad": "Many Drinks Woke up sad", "sawagirl": "Saw A girl" },
  w = 925,
  h = 600,
  margin = 30,
  startSnap = 0,
  endSnap = 650,
  startAge = 0,
  endAge = 100,
  y = d3.scale.linear().domain([endAge, startAge]).range([0 + margin, h - margin]),
  x = d3.scale.linear().domain([startSnap, endSnap]).range([0 + margin -5, w]),
  increments = d3.range(startSnap, endSnap);

var vis = d3.select("#vis")
    .append("svg:svg")
    .attr("width", w)
    .attr("height", h)
    .append("svg:g")
    // .attr("transform", "translate(0, 600)");

var line = d3.svg.line()
    .x(function(d,i) { return x(d.x); })
    .y(function(d) { return y(d.y); });


// Evenings
var sleeps_regions = {};
d3.text('sleep_days.csv', 'text/csv', function(text) {
    var regions = d3.csv.parseRows(text);
    for (i=1; i < regions.length; i++) {
        sleeps_regions[regions[i][0]] = regions[i][1];
    }
});


var startEnd = {},
    sleepCodes = {};
d3.text('layer_no_stack.csv', 'text/csv', function(text) {
    var sleeps = d3.csv.parseRows(text);

    for (i=1; i < sleeps.length; i++) {
        var values = sleeps[i].slice(2, sleeps[i.length-1]);
        var currData = [];
        sleepCodes[sleeps[i][0]] = sleeps[i][1];

        var started = false;
        for (j=0; j < values.length; j++) {
            if (values[j] != '') {
                currData.push({ x: increments[j], y: values[j] });

                if (!started) {
                    startEnd[sleeps[i][0]] = { 'startSnap':increments[j], 'startVal':values[j] };
                    started = true;
                } else if (j == values.length-1) {
                    startEnd[sleeps[i][0]]['endSnap'] = increments[j];
                    startEnd[sleeps[i][0]]['endVal'] = values[j];
                }

            }
        }
        vis.append("svg:path")
            .data([currData])
            .attr("night", sleeps[i][0])
            .attr("class", sleeps_regions[sleeps[i][0]])
            .attr("d", line)
            .on("mouseover", onmouseover)
            .on("mouseout", onmouseout);
    }
});

vis.append("svg:line")
    .attr("x1", x(1960))
    .attr("y1", y(startAge))
    .attr("x2", x(2009))
    .attr("y2", y(startAge))
    .attr("class", "axis")

vis.append("svg:line")
    .attr("x1", x(startSnap))
    .attr("y1", y(startAge))
    .attr("x2", x(startSnap))
    .attr("y2", y(endAge))
    .attr("class", "axis")

vis.selectAll(".xLabel")
    .data(x.ticks(5))
    .enter().append("svg:text")
    .attr("class", "xLabel")
    .text(String)
    .attr("x", function(d) { return x(d) })
    .attr("y", h-10)
    .attr("text-anchor", "middle")

vis.selectAll(".yLabel")
    .data(y.ticks(4))
    .enter().append("svg:text")
    .attr("class", "yLabel")
    .text(String)
    .attr("x", 0)
    .attr("y", function(d) { return y(d) })
    .attr("text-anchor", "right")
    .attr("dy", 3)

vis.selectAll(".xTicks")
    .data(x.ticks(5))
    .enter().append("svg:line")
    .attr("class", "xTicks")
    .attr("x1", function(d) { return x(d); })
    .attr("y1", y(startAge))
    .attr("x2", function(d) { return x(d); })
    .attr("y2", y(startAge)+7)

vis.selectAll(".yTicks")
    .data(y.ticks(4))
    .enter().append("svg:line")
    .attr("class", "yTicks")
    .attr("y1", function(d) { return y(d); })
    .attr("x1", x(1959.5))
    .attr("y2", function(d) { return y(d); })
    .attr("x2", x(1960))

function onclick(d, i) {
    var currClass = d3.select(this).attr("class");
    if (d3.select(this).classed('selected')) {
        d3.select(this).attr("class", currClass.substring(0, currClass.length-9));
    } else {
        d3.select(this).classed('selected', true);
    }
}

function onmouseover(d, i) {
    var currClass = d3.select(this).attr("class");
    d3.select(this)
        .attr("class", currClass + " current");

    var sleepCode = $(this).attr("night");
    var nightVals = startEnd[sleepCode];
    var percentChange = 100 * (nightVals['endVal'] - nightVals['startVal']) / nightVals['startVal'];

    var blurb = '<h2>' + sleepCodes[sleepCode] + '</h2>';

    $("#default-blurb").hide();
    $("#blurb-content").html(blurb);
}

function onmouseout(d, i) {
    var currClass = d3.select(this).attr("class");
    var prevClass = currClass.substring(0, currClass.length-8);
    d3.select(this)
        .attr("class", prevClass);
    // $("#blurb").text("hi again");
    $("#default-blurb").show();
    $("#blurb-content").html('');
}

function showRegion(regionCode) {
    var sleeps = d3.selectAll("path."+regionCode);
    if (sleeps.classed('highlight')) {
        sleeps.attr("class", regionCode);
    } else {
        sleeps.classed('highlight', true);
    }
}
