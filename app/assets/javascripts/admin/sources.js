window.updateCurrentTime = function() {
    $('#current_time').html(moment().utc().format('DD/MM/YYYY HH:mm:ss UTC'));
};

var dec2hex = function(i) {
    return (i + 0x10000).toString(16).substr(-2).toUpperCase();
};

var getColorFor = function(val, min_val, max_val) {
    var middle = (max_val - min_val) / 2.0,
        scale = 255.0 / (middle - min_val),
        color;

    if (val >= max_val) {
        color = 'FF0000';
    }
    else if (val <= min_val) {
        color = '00FF00';
    } else if (val < middle) {
        color = dec2hex(Math.round((val - min_val) * scale)) + 'FF00';
    } else {
        color = 'FF' + dec2hex(Math.round(255 - ((val - middle) * scale))) + '00';
    }

    return '#' + color;
};

window.updateColors = function() {
    $('.color-plate').each(function(idx, elt) {
        var timestamp = moment($(elt).attr('data-timestamp'), 'YYYY-MM-DD HH:mm:ss ZZ'),
            limit = $('#hours-slider').slider('getValue'),
            n = moment.duration(moment().diff(timestamp)).asHours();

        var color = getColorFor(n, 0, limit);

        $(elt).css({ 'background-color': color });
    });
};