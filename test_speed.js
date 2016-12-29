var speedTestDone = false;
window.onload = function() {
    var head = $('head');
    var list = $(".links-of-blogroll-list li a");
    var i = 0;
    var requests = [];
    list.each(function() {
        $(this).parent().attr("id", "li_id_" + i); (function(href, i) {
            var r = $.ajax({
                url: href + "/me" + i + ".js",
                jsonpCallback: (function(){
                    var c = "callback" + i;
                    window[c]=function(){};
                    return c;
                })(),
                dataType: "jsonp",
                success: function(response) {
                    if (speedTestDone) {
                        return;
                    }
                    speedTestDone = true;
                    var li = $("#li_id_" + i);
                    li.html(li.html() + "<span>【响应最快】</span>");
                    li.css({
                        "color": "green",
                        "font-weight": "bold"
                    });
                    for (var j in requests) {
                        window["callback" + j]=null;
                        delete window["callback" + j];
                        requests[j].abort();
                    }
                },
                error: function() {}
            });
            requests.push(r);
        })($(this).attr("href"), i);
        i++;
    });
};