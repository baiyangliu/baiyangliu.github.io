var speedTestDone=false;var speedTest=function(e){if(speedTestDone){return}speedTestDone=true;var t=$("#"+e);t.innerHTML+="<span>【响应最快】</span>"};window.onload=function(){var e=$("head");var t=$(".links-of-blogroll-list li a");t.each(function(){var t=$(this).attr("href");$(this).parent().attr("id",t);setTimeout(function(){if(speedTestDone){return}$("<script></script>").attr({src:t+"/me.js",type:"text/javascript",onload:"speedTest("+t+")"}).appendTo(e)},0)})};