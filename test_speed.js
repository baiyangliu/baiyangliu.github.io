var speedTestDone=false;window.onload=function(){var e=$("head");var a=$(".links-of-blogroll-list li a");var s=0;a.each(function(){var e=$(this).attr("href");var a="li_id_"+s++;$(this).parent().attr("id",a);$.ajax({url:e+"/me.js",dataType:"jsonp",success:function(e){if(speedTestDone){return}console.log(a+"响应最快");speedTestDone=true;var s=$("#"+a);s.html(s.html()+"<span>【响应最快】</span>")}})})};