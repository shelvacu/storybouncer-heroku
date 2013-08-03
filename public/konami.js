function kon(){
		soundManager.play('nyan');
		window.optss = [];
		for(var i=0; i<100; i++){
				var thing = $('<img src="http://www.nyan.cat/icons/nyan.gif" id="img'+i+'">');
				thing.css({
						position:'absolute',
						"z-index":'-1'
				});
				$('body').append(thing);
				var opts = {
						start: Math.random()*$('body').height(),
						farAlong: 0,
						speed: Math.random()*2,
						el: thing};
				opts.farAlong = Math.random()*($('body').width()/opts.speed);
				window.optss.push(opts);
		}
		setInterval(function(){
				window.optss.forEach(function(opts){
						opts.el.css({
								top: opts.start+(Math.sin(opts.farAlong/10)*10)-21+'px',
								left: (opts.farAlong*opts.speed)-53+'px'
						});
						opts.farAlong++;
						if(opts.el.position().left > $('body').width()){
								opts.farAlong = 0;
						}
						//console.log(opts);
				});
		},10);
}

soundManager.setup({
		url:"/soundmanager/swf/",
		preferFlash: false,
		onready: function() {
				soundManager.createSound({
						id:'nyan',
						url:"http://www.nyan.cat/music/gb.mp3",
						loops:60
				});
				konami = new Konami();
				konami.load("javascript:kon()");
		}
});
