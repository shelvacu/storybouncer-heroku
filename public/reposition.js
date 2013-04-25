function get(id){document.getElementById(id)}
document.body.onload = function(){
		bar = get('bottombar');
		if(bar.scrollHeight + bar.offsetTop < document.body.scrollHeight){
				bar.style.position = 'absolute';
				bar.style.bottom   = '0px';
		}
}
