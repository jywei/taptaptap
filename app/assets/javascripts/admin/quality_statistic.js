function update_total_chart(type, new_data) {
    var chart = $("#" + type + "_quality .total div[id*=chart-]").highcharts(),
        categories = [],
        data = [];

    $(new_data[0]["data"]).each(function(_, el) {
        categories.push(el[0]);
        data.push(el[1]);
    });

    chart.series[0].setData(data);
    chart.xAxis[0].setCategories(categories, false);

    chart.redraw();
}

function update_chart(quality_type, chart_type, new_data) {
    var chart = $("#" + quality_type + "_quality ." + chart_type+ " div[id*=chart-]").highcharts();

    $(chart.series).each(function(index, el) {
        el.update({
            name: new_data[index]["name"],
            data: new_data[index]["data"]
        });
    });
}

function update_charts(quality_type, parts) {
  if (parts.length == 1)
    return false;

  var start_date = $(".input-daterange input[name=start_date]").val(),
    end_date = $(".input-daterange input[name=end_date]").val(),
    data = { "start_date": start_date, "end_date": end_date };

  if (parts[0] && parts[1]) {
    data["start_quality"] = parts[0];
    data["end_quality"] = parts[1];
  }

  var data_url = (quality_type == "fields") ?  window.stats_config.fields_path : window.stats_config.annotations_path;

  $.ajax({
      type: 'get',
      contentType: "application/json; charset=utf-8",
      url: data_url,
      data: data,
      dataType: 'json'
  }).done(function(res) {
      var list_str = window.localStorage.getItem("last" + quality_type + "_parts"),
          list = list_str ? list_str.split(",") : [];

      list.push(parts);

      window.localStorage.setItem("last" + quality_type + "_parts", list);

      update_total_chart(quality_type, res["total"]);
      update_chart(quality_type, "by_sources", res["by_sources"]);
      update_chart(quality_type, "by_ips", res["by_ips"]);
  });
}

function add_link_to_tooltip(quality_type, chart, by) {
  var path = (quality_type == "fields") ?  window.stats_config.fields_quality_postings_path : window.stats_config.annotations_quality_postings_path;

  chart.tooltip.options.formatter = function()
  {
      var text = '<strong>' + this.x +'</strong><br/>' + this.series.name + ': <strong>' + this.y + '</strong><br/>',
          parts = ( by == "" ) ? this.x.match(/(\d{1,3})/g) : this.series.name.match(/(\d{1,3})/g),
          params = '?lower='+ parts[0] + '&upper=';

      params +=  (parts[0] && parts[1]) ? parts[1] : parts[0];

      if (by)
          params += '&'+ by + '=' + this.x;

      return  text + '<a style="text-decoration:underline; color:blue" href="' + path + params + '">Postings</a>';
  }
}

$(document).ready(function() {
    var last_tab = window.localStorage.getItem('last_tab');

    if (last_tab) {
        $('[data-target="' + last_tab + '"]').tab('show');
        $(window).trigger('resize');
        if (last_tab.match(/combined/)){
          $("#zoom_buttons").hide();
        }
    }

    $('a[data-toggle="tab"]').on('shown.bs.tab', function() {
        window.localStorage.setItem('last_tab', $(this).attr('data-target'));
        $(window).trigger('resize');
    });

    $('.input-daterange').datepicker({
        format: "yyyy-mm-dd",
        startDate: window.stats_config.min_date,
        endDate: window.stats_config.max_date,
        autoclose: true
    });

    var qualities = ["fields", "annotations"];

    $(qualities).each(function(index, value){
        var chart = $("#" + value + "_quality .total div[id*=chart-]").highcharts();

        chart.series[0].update({
            events: {
                click: function (event) {
                    var parts = event.point.category.match(/(\d{1,3})/g);
                    update_charts(value, parts);
                }
            },
            cursor: 'pointer'
        });

        window.localStorage.setItem("last" + value + "_parts", [ null, null ]);

        add_link_to_tooltip(value, chart, '');
        add_link_to_tooltip(value, $("#" + value + "_quality .by_sources div[id*=chart-]").highcharts(), 'source');
        add_link_to_tooltip(value, $("#" + value + "_quality .by_ips div[id*=chart-]").highcharts(), 'ip');
    });

    $(".reset").click(function(){
        last_tab = window.localStorage.getItem('last_tab');

        var quality_type = last_tab.match(/fields/) ? "fields" : "annotations";

        window.localStorage.setItem("last" + quality_type + "_parts", [ null, null ]);

        update_charts(quality_type, [ null, null ]);
    });

    $(".back").click(function() {
        last_tab = window.localStorage.getItem('last_tab');

        var quality_type = last_tab.match(/fields/) ? "fields" : "annotations",
            last_quality_type = window.localStorage.getItem("last" + quality_type + "_parts");

        if (last_quality_type) {
          var list = last_quality_type.split(",");

          list.pop();
          list.pop();

          var end_quality = list.pop(),
              start_quality = list.pop();

          window.localStorage.setItem("last" + quality_type + "_parts", list);

          update_charts(quality_type, [ start_quality, end_quality ]);
        }
    });

    $(".nav-tabs li").click(function(){
      if ($(this).text().match(/Combined/)) {
        $("#zoom_buttons").hide();
      } else {
        $("#zoom_buttons").show();
      }
    });
});
