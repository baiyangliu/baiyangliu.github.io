_g = function() {
    var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwxyz";
    var specal = false;
    if ($("#_specal_").is(":checked")) {
        chars += "~`!@#$%^&*()_+";
        specal = true;
    }

    var done = 0;
    var str = "";
    var len = $("#_i_p_t").val();
    var total = parseInt(len >> 13);
    var last = len % 8192;
    total += last==0 ? 0 : 1;

    var work = function(len) {
        var worker = new Worker("/js/random_worker.js");
        worker.onmessage = function(evt) {
            str += evt.data;
            done++;
            if (done == total) {
                $("#_result").html(str).show();
            }
        };
        work.postMessage({
            specal: specal,
            len: len
        });
    };
    for (var i = 0; i < total; i++) {
        worker(i == total ? 8192 : last);
    }
};