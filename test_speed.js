var speedTestDone=false;window.onload=function(){var e=$("head");var t=$(".links-of-blogroll-list li a");var a=0;t.each(function(){var e=$(this).attr("href");var t="li_id_"+a++;$(this).parent().attr("id",t);$.ajax({url:e+"/me.js",dataType:"jsonp",success:function(e){if(speedTestDone){return}console.log(t+"响应最快");speedTestDone=true;var a=$("#"+t);a.html(a.html()+"<span style="font-weight:bold;color:green;">【响应最快】</span>")}})})};