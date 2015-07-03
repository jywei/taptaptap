$(document).ready(function(){
    var last_tab = window.localStorage.getItem('last_tab');
        
    if (last_tab) {
        $('[data-target="' + last_tab + '"]').tab('show');
        $(window).trigger('resize');
    }

    $('a[data-toggle="tab"]').on('shown.bs.tab', function() {
        window.localStorage.setItem('last_tab', $(this).attr('data-target'));
        $(window).trigger('resize');
    });
      
      $("#latency_offset").slider({min: 10, max: 1000, step: 10, value: parseInt(window.config.latency_offset)});
    
      $('#latency_offset').slider()
        .on('slideStop', function(ev){
          value = $('#latency_offset').data('slider').getValue();  
          $.ajax({
              type: "POST",
              url: window.config.update_latency_path,
              data: {"latency_offset": value},
              success: function(){
                  $(".alert").fadeIn(300);
                  window.setTimeout( function(){
                      $(".alert").fadeOut(300);
                  }, 2500);
              }
          });  
      });

      
      $('#datepicker_hourly').datepicker({
          format: "yyyy-mm-dd",
          autoclose: true,
          startDate: window.config.min_day,
          endDate: window.config.max_day
      });

      $("#datepicker_daily").datepicker(
          { 
              format: "yyyy-mm-dd",
              autoclose: true,
              startDate: window.config.min_day,
              endDate: window.config.max_day
          }
      );

      $("#datepicker_monthly").datepicker( {
          format: "yyyy-mm",
          viewMode: "months", 
          minViewMode: "months",
          autoclose: true,
          startDate: window.config.min_month,
          endDate: window.config.max_month
      });

      $("#datepicker_day_hourly").datepicker(
          { 
              format: "yyyy-mm-dd",
              autoclose: true,
              startDate: window.config.min_day,
              endDate: window.config.max_day
          }
      );

      $(window.config.periods).each(function(_,period){
          $("#apply_" + period).bind("click", function(){
              update_chart(period);
          });  
      });

      reload_line_charts();

      $("#apply_day_hourly").click(function(){
          $("#total, #by_sources").empty();

          reload_line_charts();
      });
      
            
  });

function update_chart(type) {  
    var date = {"date" : $("#date_" + type).val()}
    
    if (type == "hourly"){
      date["date"] += " " + $("#hour").val();
    }
    
    $.ajax({
        type: 'get',
        contentType: "application/json; charset=utf-8",
        url: window.config.urls[type],
        data: date,
        dataType: 'json'
    }).done(function(new_data) {
        var chart = $("." + type + " div[id*=chart-]").highcharts();

        $(chart.series).each(function(index, el) {
            el.update({
                name: new_data[index]["name"],
                data: new_data[index]["data"]
            });
        });
    });         
}
function reload_line_charts(){
    var date = { "date" : $("#date_day_hourly").val() } 

    $.ajax({
        type: 'get',
        contentType: "application/json; charset=utf-8",
        url: window.config.urls["day_hourly"],
        data: date,
        dataType: 'json'
    }).done(function(new_data) {

        if (new_data){
            for (source in new_data){
                if (source == "total"){
                    new_line_chart(new_data[source], "total", "Total");            
                } else {
                    $("#by_sources").append('<div class="span5 pull-left" style="height: 400px;" id="'+ source +'"></div>')
                    new_line_chart(new_data[source], source, source);
                }   
            }

        }         
    
    });

}

function new_line_chart(data, container, title) {     
    
    categories = []

    $(data[0]["data"]).each(function(_,el){
      categories.push(el[0]); 
    });

    var chart = new Highcharts.Chart({  

        chart: {  

            renderTo: container,  

            type: 'line'  
        },  

        title: {  

            text: '<strong>' + title + '</strong>',  

            useHTML: true

        },  
 
        xAxis: {  
            type: 'category',
  
            categories: categories,

            labels: {           
                rotation: 60
            }
        },
  
         yAxis: {
            min: 0,

            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }]
        },

        tooltip: {  

            formatter: function() {  

                    return '<b>'+ this.x +'</b><br/>'+  

                    this.series.name +': '+ '<b>' + this.y + '</br>' ;  

            }  

        },  

        legend: {  

            layout: 'vertical',  
            
            alAlign: 'top',    

            align: 'center',    

            type: 'datetime',     

            borderWidth: 0  

        },  

        credits: {

            enabled: false
        },

        series: data

    });   
} 