var speedTestDone=false;window.onload=function(){var e=$("head");var a=$(".links-of-blogroll-list li a");var t=0;a.each(function(){var e=$(this).attr("href");var a="li_id_"+t++;$(this).parent().attr("id",a);$.ajax({url:e+"/me.js",jsonp:"callback",dataType:"jsonp",success:function(e){if(speedTestDone){return}speedTestDone=true;var t=$("#"+a);t.html(t.html()+"<span style="font-weight:bold;color:green;">【响应最快】</span>")}})})};