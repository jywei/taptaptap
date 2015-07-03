var AUTH_TOKEN = '93418186281e8a964d707433b43a1485';

function updateRequestText() {
    $('.results').removeClass('error');

    window.query = {};

    $('input, select, textarea').each(function(idx, elt) {
        var name = $(elt).attr('name'),
            value = $(elt).val();

        if ($(elt).hasClass('exclude') || !value || value.toString().trim().length < 1) {
            return;
        }

        if ($(elt).hasClass('alternate')) {
            // this block sets category_groups
            var category_groups = ["AAAA", "CCCC", "DISP", "SSSS", "JJJJ", "MMMM", "PPPP", "RRRR", "SVCS", "ZZZZ", "VVVV"],
                groups = [],
                categories = [];

            for(var i = 0; i< value.length; i++) {
                if ($.inArray(value[i], category_groups) != -1 ) {
                    groups.push(value[i]);
                } else {
                    categories.push(value[i]);
                }
            }

            if (groups.length > 0) {
                window.query['category_group'] = groups.join("|");
            }

            value = categories.join('|');
        }

        if (value.length > 0) {
            window.query[name] = value;
        }

        //remove prevent location level
        var locations = ['country', 'state', 'metro', 'region', 'county', 'city', 'locality', 'zipcode'];

        if ($.inArray(name, locations) >= 0 ) {
            for (var i = 0; i < locations.length; i++) {
                if (locations[i] == name) {
                    break;
                } else {
                    delete window.query[locations[i]];
                }
            }
        }

    });

    $('[name=query]').html(JSON.stringify(window.query, null, 4));
}

function filterLocations(elt) {
    if ($(elt).hasClass('no_filter')) {
        return;
    }

    var currentOrder = parseInt($(elt).attr('data-location-order')),
        currentLevel = $(elt).attr('data-location-level'),
        filterElements = $('[data-location-order=' + (currentOrder - 1) + ']'),
        filters = {
            auth_token: AUTH_TOKEN
        };

    if (!currentLevel)
        return;

    filterElements.each(function(_, elt) {
        var filterName = $(elt).attr('data-location-level'),
            filterValue = $(elt).val();

        filters[filterName] = filterValue;
    });

    var locationsUrlParts = [];

    filters['level'] = currentLevel;

    for (var key in filters) {
        locationsUrlParts.push(key + '=' + filters[key]);
    }

    $.getJSON('/request_builders/reference_api_request', filters, function(data) {
        var emptyOption = $(elt).find('select').children()[0];

        $(elt).find('select').html('').append(emptyOption);

        if (!data['locations']) {
            console.error('Wrong response');
            return;
        }

        var locations = data['locations'];

        if(currentLevel == 'country') {
            $(elt).find('select').append('<option value="USA">United States</option><option value="CAN">Canada</option>');
            for(var i = 0; i < locations.length; i++) {
                if (locations[i]['code'] == 'USA' || locations[i]['code'] == 'CAN') delete locations[i];
            }
        }


        locations.forEach(function(location) {
            $(elt).find('select').append('<option value="' + location.code + '">' + location['full_name'] + '</option>');
        });

        if (currentOrder > 0) {
            $("#level").val(currentLevel).change();
        }
    });
}

function hideFilters(currentOrder) {
    var elements = $('[data-location-order]');

    elements.hide();

    if (typeof currentOrder == 'undefined') {
        $('[data-location-order=0]').show();
    } else {
        elements.each(function (_, elt) {
            if (parseInt($(elt).attr('data-location-order')) <= currentOrder) {
                $(elt).show();
            } else {
                $(elt).val('');
            }
        });
    }

    updateRequestText();
}

function setAnchor() {
    var beginningOfDay = new Date();
    beginningOfDay = beginningOfDay.setHours(0, 0, 0, 0);

    $.get('http://polling.3taps.com/poll?auth_token=' + AUTH_TOKEN /* + '&timestamp=' + beginningOfDay*/, function(data) {
        $('[name=anchor]').val(data['anchor']);
        updateRequestText();
    });
}

$(function() {
    $('input, select, textarea').change(function() {
        updateRequestText();
    });

    $('.send').on('click', function(evt) {
        evt.preventDefault();

        $('.results').removeClass('error');

        $.ajax({
            url: window.test_url,
            data: window.query
        }).done(function(data) {
            $('.results').html(JSON.stringify(data, null, 4));
        }).fail(function(_, text, response) {
            console.error("Oops:", text, response);
            $('.results').addClass('error').html("something went wrong");
        });

        return false;
    });

    $('[data-location-order] select').change(function() {
        var currentOrder = parseInt($(this).attr('data-location-order')),
            elt = $('[data-location-order=' + (currentOrder + 1) + ']');

        if (!elt)
            return;

        var evt_params = {
            name: $(this).attr('name'),
            value: $(this).val()
        };

        hideFilters(currentOrder);

        if ($(this).val() == '') {
            $("#level").val('');
            return;
        }

        elt.val('').show().trigger('filter-selected', evt_params);

        if (!elt.hasClass('skip-filter'))
            filterLocations(elt);
    });

    setAnchor();
    hideFilters();
    updateRequestText();

    filterLocations($('[data-location-order=0]'));
});
