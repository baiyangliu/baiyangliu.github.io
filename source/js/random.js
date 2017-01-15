_g = function() {
    var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwxyz";
    var specal = false;
    if ($("#_specal_").is(":checked")) {
        chars += "~`!@#$%^&*()_+";
        specal = true;
    }
    var work = function(len) {
        var worker = new Worker("/js/random_worker.js");
        worker.onmessage = function(evt) {
            str += evt.data;
            $("#_result").html(str).show();
        };
        worker.postMessage({
            specal: specal,
            len: len
        });
    };
    var str = "";
    var len = $("#_i_p_t").val();
    var total = 8;
    var _len = len / total;
    var last = len % total;
    for (var i = 0; i < total; i++) {
        work(i == total ? _len : _len + last);
    }
};