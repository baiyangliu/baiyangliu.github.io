onmessage = function(evt) {
    var data = evt.data;
    var len = data.len;
    var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwxyz";
    if (data.specal) {
        chars += "~`!@#$%^&*()_+";
    }
    var s = "";
    for (var i = 0; i < len; i++) {
        s += chars[parseInt(Math.random() * chars.length)];
    }
    postMessage(s);
};