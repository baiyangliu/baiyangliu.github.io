_g = function() {
    var specal = $("#_specal_").is(":checked");
    $("#_result").html("");
    var work = function(len) {
        var worker = new Worker("/js/random_worker.js");
        worker.onmessage = function(evt) {
            $("#_result").append(evt.data).show();
        };
        worker.postMessage({
            specal: specal,
            len: len
        });
    };
    var len = $("#_i_p_t").val();
    if(len < 1024){
        work(len);
        return;
    }
    var total = 16;
    var _len = parseInt(len / total);
    var last = len % total;
    for (var i = 0; i < total; i++) {
        var _l = i == total ? _len + last : _len;
        if(_l!==0){
            work(_l);
        }
    }
};