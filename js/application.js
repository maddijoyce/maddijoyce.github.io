(function(){var t,e,n,i,a;t=function(){var t;return t=$(".banner-main"),t.length?($(".navbar").removeData("bs.affix").removeClass("affix affix-top affix-bottom"),$(".navbar").affix({offset:{top:t.outerHeight()}})):($(".navbar").addClass("affix affix-top"),$("body").css("padding-top",$(".navbar").outerHeight(!0)))},e=function(){return $(".navbar").on("affixed.bs.affix",function(){return $("body").css("padding-top",$(".navbar").outerHeight(!0))}).on("affixed-top.bs.affix",function(){return $("body").css("padding-top",0)}),t(),$(window).resize(function(){return t()})},n=function(){var t;return $(".title").css("opacity",0).animate({opacity:1},2e3),t=500,$(".subtitle ul").children().css("opacity",0).each(function(e,n){return $(n).delay(t).animate({opacity:1},2e3),t+=500})},a=function(){var t,e;return window.UserVoice=window.UserVoice||[],e=document.createElement("script"),e.type="text/javascript",e.async=!0,e.src="//widget.uservoice.com/5ZIjAw7O0QxQ2Eszc3IJFw.js",t=document.getElementsByTagName("script")[0],t.parentNode.insertBefore(e,t),window.UserVoice.push(["set",{contact_title:"Send me a message",screenshot_enabled:!1}]),window.UserVoice.push(["addTrigger","#contact",{position:"top-right",target:!1}]),window.UserVoice.push(["addTrigger","#talk-software",{}]),window.UserVoice.push(["addTrigger","#talk-consulting",{}]),window.UserVoice.push(["addTrigger","#talk-training",{position:"top"}])},i=function(){return $(".tipped").tooltip()},$(document).ready(function(){return e(),a(),i()})}).call(this);