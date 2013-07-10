function divmod(a,b){
		var mod = (a % b);
		return [((a-mod)/b),mod]
}

var demoDay = new Date(2013,7,23,12,0,0,0);
var now;
var secondsBox = document.getElementById("secondshower");
var timeBox = document.getElementById("timeshower");
var s=1000,m=(s*60),h=(m*60),d=(h*24),w=(d*7);

function doStuff(){
		//now = new Date();
		secondsLeft = (demoDay.getTime() - Date.now());
		secondsBox.innerText = divmod(secondsLeft,1000)[0];
		//w,d,h,m
		weeksLeft= divmod(secondsLeft,w);
		daysLeft = divmod(weeksLeft[1],d);
		hoursLeft= divmod(daysLeft[1],h);
		minLeft  = divmod(hoursLeft[1],m);
		secLeft  = divmod(minLeft[1],s);
		//secLeft  = secLeft[0] + secLeft[1]/1000
		timeBox.innerText = weeksLeft[0] + " weeks " + daysLeft[0] + " days\n" + hoursLeft[0] + ":" + minLeft[0] + ":" + ('00'+secLeft[0]).slice(-2) + '.' + (secLeft[1]+"000").slice(0,3);
		setTimeout(function(){doStuff()},10);
}
doStuff();
