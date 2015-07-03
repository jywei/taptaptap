$(function() {
    var updateInterval = 1000 * 5;

    setInterval(function() {
        $.getJSON('/', function(response) {
            if (!response['this_month'])
                return;

            var contractsCount = response['this_month']['contracts_count'],
                customerPayment = response['this_month']['customer_payment'],
                senderRevenue = response['this_month']['sender_revenue'];

            $('.this-month .contracts_count').html(contractsCount);
            $('.this-month .customer-payment').html(customerPayment);
            $('.this-month .sender-revenue').html(senderRevenue);
        });
    }, updateInterval);

    $('.show-contracts').on('click', function(e) {
        e.preventDefault();

        var period = $(this).attr('data-period');

        $('.contract-list.' + period).toggle();
    });

    $('.contract-list').hide();
});