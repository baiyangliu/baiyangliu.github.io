var speedTestDone=false;window.onload=function(){var a=$("head");var e=$(".links-of-blogroll-list li a");var s=0;e.each(function(){var a=$(this).attr("href");var e="li_id_"+s++;$(this).parent().attr("id",e);$.ajax({url:a+"/me.js",jsonp:"callback",dataType:"jsonp",success:function(a){console.log(e);if(speedTestDone){return}speedTestDone=true;var s=$("#"+e);s.html(s.html()+"<span>【响应最快】</span>")}})})};