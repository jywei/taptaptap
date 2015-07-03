$(document).ready(function() {
    for (var category in window.stats_config.qualities) {
        var config = window.stats_config.qualities[category];

        $('#' + category + '-qualities-chart-container').highcharts({
            title: {
                text: config.title
            },
            xAxis: [{
                categories: config.categories
            }],
            yAxis: [{
                title: {
                    text: 'Amount',
                    style: {
                        color: Highcharts.getOptions().colors[1]
                    }
                }
            }, {
                title: {
                    text: 'Quality, %',
                    style: {
                        color: Highcharts.getOptions().colors[1]
                    }
                },
                opposite: true
            }],
            tooltip: {
                formatter: function() {
                    return '<b>' + this.series.name + '</b><br />' + this.y;
                }
            },
            series: [
                {
                    name: 'Postings',
                    type: 'column',
                    data: config.postings_data
                },
                {
                    name: 'Median fields quality',
                    type: 'spline',
                    yAxis: 1,
                    data: config.fields_quality_data
                },
                {
                    name: 'Median annotations quality',
                    type: 'spline',
                    yAxis: 1,
                    data: config.annotations_quality_data
                }
            ]
        });
    }
});
