function vote(id,direction,obj){
		var oReq = new XMLHttpRequest();
		oReq.open("get","/vote?id="+id+
							"&dir="+(direction ? '1' : '0'),false);
		oReq.send(null);
		if (oReq.status == 200){
				res = JSON.parse(oReq.responseText);
				if (res.status == "error"){
						switch(res.error){
						case 0:
								alert("You need to login");
								break;
						default:
								alert("There seems to be an error with the code;" +
											(res.error));
						}
				}else if(res.status == "success"){
						//obj.classList.add('votedImage');
						var childs = $("#ppara"+res.id).children();
						//console.log('childs',childs)
						var footer = childs[childs.length-1];
						childs = footer.children;
						upvote = $(childs[0].children[0]);
						downvote = $(childs[0].children[1]);
						voteCount = $(childs[1]);
						//console.log('upvote',upvote);
						//console.log('downvote',downvote);
						//console.log('voteCount',voteCount);
						if(res.vote){
								upvote.addClass('votedImage');
								downvote.removeClass('votedImage');
						}else{
								upvote.removeClass('votedImage');
								downvote.addClass('votedImage');
						}
						voteCount.text(res.votes.toString());
						if(res.votes > 0){
								voteCount.removeClass('voteNegative');
								voteCount.addClass(   'votePositive');
						}else{
								voteCount.addClass(   'voteNegative');
								voteCount.removeClass('votePositive');
						}
				}
		}else{
				alert("Ah, there's been an error\nError "+oReq.status+" actually\nPlease use the contact form to tell me of this so that I may fix it");
		}
}
