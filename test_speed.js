var speedTestDone=!1;window.onload=function(){var n=($("head"),$(".links-of-blogroll-list li a")),a=0,e=[];n.each(function(){$(this).parent().attr("id","li_id_"+a),function(n,a){var o=$.ajax({url:n+"/me"+a+".js",jsonpCallback:"callback"+a,dataType:"jsonp",success:function(n){if(!speedTestDone){speedTestDone=!0;var o=$("#li_id_"+a);o.html(o.html()+"<span>【响应最快】</span>"),o.css({color:"green","font-weight":"bold"});for(var t in e)e[t].abort()}},error:function(){}});e.push(o)}($(this).attr("href"),a),a++})};