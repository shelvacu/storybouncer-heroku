function get(id){return document.getElementById(id);}
var oldReady = jQuery.ready;
jQuery.ready = function(){
  try{
    return oldReady.apply(this, arguments);
  }catch(e){
    // handle e ....
		console.log(e);
  }
};
$(document).ready(function(){
		try{
				setInterval(function(){
						//bar = get('bottombar');
						//barheight = bar.scrollHeight + bar.offsetTop; 
						//console.log( $("#bottombar").height() < $(window).height() );
						if( $("#bottombar")[0].offsetTop > $("#mainContainer").height()+$("#mainContainer")[0].offsetTop){
								$("#bottombar")[0].style.position = 'absolute';
								//bar.style.bottom   = '0px';
						}else{
								$("#bottombar")[0].style.position = 'static';
						}
				},50);
				//alert("got to the end!");
		}catch(e){
				console.log(e);
		}
})
