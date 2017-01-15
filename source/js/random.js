_g = function() {
    var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwxyz";
    var specal = false;
    if ($("#_specal_").is(":checked")) {
        chars += "~`!@#$%^&*()_+";
        specal = true;
    }

    var done = -1;
    var str = "";
    var len = $("#_i_p_t").val();
    var total = parseInt(len >> 13);
    var last = len % 8192;

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
    for (var i = 0; i <= total; i++) {
        if (i == total){
            worker(8192);
        } else {
            worker(last);
        }
        
    }
};