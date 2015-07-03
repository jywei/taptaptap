function add_category_group_to_url(cat_group){
    url = location.href;

    if (url.match(/category_group/)) {
        url = url.replace(/category_group=(\w{4})/, 'category_group=' + cat_group);
    } else {
        url += (url.match(/\&/) ? '&' : '?');
        url += 'category_group=' + cat_group;
    }

    return url;
}

$(document).ready(function() {
    $('.input-daterange').datepicker({
        format: "yyyy-mm-dd",
        startDate: window.stats_config.min_date,
        endDate: window.stats_config.max_date,
        autoclose: true
    });

    $('#run-live-stats').click(function() {
        //$(this).toggleClass('btn-warning').toggleClass('btn-primary');
        $(this).find('i').toggleClass('icon-play').toggleClass('icon-pause');

        window.stats_config.live.running = ($(this).find('i').hasClass('icon-pause'));
    });

    $('#run-heartbeats-stats').click(function() {
        //$(this).toggleClass('btn-warning').toggleClass('btn-primary');
        $(this).find('i').toggleClass('icon-play').toggleClass('icon-pause');

        window.stats_config.heartbeats.second.running = ($(this).find('i').hasClass('icon-pause'));
    });

    $('a[data-toggle="tab"]').on('shown.bs.tab', function() {
        window.localStorage.setItem('last_tab', $(this).attr('data-target'));
        $(window).trigger('resize');
    });

    if (!location.href.match(/category_group/)) {
        var last_tab = window.localStorage.getItem('last_tab');

        if (last_tab) {
            $('[data-target="' + last_tab + '"]').tab('show');
        }
    }

    $('.nav-tabs').tabdrop();

    $("#by_category_group div[id*=chart-]").each(function(key, chart){
        $.each($(chart).highcharts().series,
            function(index, el){
                el.update({
                    events:{
                        click: function (event) {
                            location.href = add_category_group_to_url(event.point.category);
                        }
                    },
                    cursor: 'pointer'
                });
            });
    });

    window.live_chart = new Highcharts.Chart({
        chart: {
            renderTo: $('#live-chart-container').get(0),
            type: 'areaspline',
            animation: {
                duration: 10
            },
            marginRight: 10,
            events: {
                load: function() {
                    var that = this;

                    setInterval(function() {
                        if (!window.stats_config.live.running) {
                            return;
                        }

                        $.getJSON(window.stats_config.live.updateUrl, function(response) {
                            for (var i = 0; i < response.length; i++) {
                                var id = response[i].id,
                                    data = response[i].data,
                                    series = that.get(id);

                                if (series) {
                                    var shift = (series.data.length > window.stats_config.series_shift_length),
                                        x = new Date(),
                                        y = data[0];

                                    // series.addPoint(data[data.length - 1][1], true, shift);
                                    series.addPoint([ x, y ], true, shift);
                                }
                            }
                        });
                    }, 1 * 1000);
                }
            }
        },
        title: {
            text: 'Postings (live)'
        },
        xAxis: {
            type: 'datetime',
            labels: {
                formatter: function() {
                    var timestamp = new Date(new Date().getTime() + (this.value * 1000));

                    return timestamp.format('isoTime');
                }
            }
        },
        yAxis: {
            title: {
                text: 'Postings amount'
            },
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }]
        },
        tooltip: {
            formatter: function() {
                return '<b>' + this.series.name + '</b><br />' + this.y + ' postings';
            }
        },
        exporting: {
            enabled: false
        },
        credits: {
            enabled: false
        },
        series: window.stats_config.live.series
    });

    var heartbeatCharts = [ 'second', 'minute', 'hour', 'day' ];

    heartbeatCharts.forEach(function(elt) {
        var xAxisStep = 1;

        if (elt == 'minute')
            xAxisStep = 5; else
        if (elt == 'hour')
            xAxisStep = 3;

        window['heartbeats_' + elt + '_chart'] = new Highcharts.Chart({
            chart: {
                renderTo: $('#heartbeats-by-' + elt + '-chart-container').get(0),
                type: 'area',
                animation: {
                    duration: 10
                },
                marginRight: 10,
                events: {
                    load: function() {
                        var that = this;

                        setInterval(function() {
                            if (!window.stats_config.heartbeats[elt].running) {
                                return;
                            }

                            $.getJSON(window.stats_config.heartbeats[elt].updateUrl, function(response) {
                                for (var i = 0; i < response.length; i++) {
                                    var id = response[i].id,
                                        data = response[i].data,
                                        series = that.get(id);

                                    if (elt == 'second') {
                                        series.addPoint(data[data.length - 1], true, (series.data.length > 20));
                                    } else {
                                        series.setData(data);
                                    }
                                }
                            });
                        }, window.stats_config.heartbeats[elt].timeout);
                    }
                }
            },
            legend: {
                enabled: false
            },
            title: {
                text: 'Heartbeat by ' + elt
            },
            xAxis: {
                type: 'category',
                labels: {
                    step: xAxisStep,
                    rotation: 60,
                    formatter: function() {
                        var timestamp = Date.parse(this.value),
                            date = new Date(timestamp),
                            label = date.format(window.stats_config.heartbeats[elt].dateFormat);

                        if (window.stats_config.heartbeats[elt].lastXLabel != label) {
                            window.stats_config.heartbeats[elt].lastXLabel = label;
                            return label;
                        }

                        return '.';
                    }
                }
            },
            yAxis: {
                title: {
                    text: 'Postings amount'
                },
                plotLines: [{
                    value: 0,
                    width: 1,
                    color: '#808080'
                }]
            },
            tooltip: {
                formatter: function() {
                    var ts = new Date(Date.parse(this.key)).format(window.stats_config.heartbeats[elt].dateFormat);
                    return '<b>' + ts + '</b><br />' + this.y + ' postings';
                }
            },
            plotOptions: {
                area: {
                    marker: {
                        enabled: false,
                        symbol: 'circle',
                        radius: 2
                    }
                }
            },
            exporting: {
                enabled: false
            },
            credits: {
                enabled: false
            },
            series: window.stats_config.heartbeats[elt].series
        });
    });
});
