var nTrials = 10;
var nGames = 30;
var Trial = 0;
var Game = 1;
var d = new Date();
var subjID = '7' + Math.random().toString().substring(3,8);
var filename = subjID + '_' + d.getTime() + '.csv';
var reward = 0;
var b = 0;
var sd = [0, Math.sqrt(16)];
var L = ["S", "R"];
var sd0 = Math.sqrt(100);
var mu = new Array();
var mode = 0;
var k1 = Math.floor(Math.random()*2);
var k2 = Math.floor(Math.random()*2);

// Initialization
$(document).ready(function() {
 	$('#endExperiment').hide();
	$('#startGame').hide();
 	$('#buttons').hide();
	$('#Instructions').hide();
	$('#feedback').hide();
	$('#submit').text("Submit");
	$('#submit').hide();
                  
	$("#button1").click(function() {
		if (mode == 0) {
			document.getElementById("button1").style.borderColor = "black";
			b = 1;
			$('#submit').text("Next");
			$('#submit').show();
			reward = nrand(mu[0],sd[k1]);
			$("#button1").text(reward);
			var currentTime = new Date().getTime();
			RT = currentTime - startTrialTime;
			mode = 1;
		}
	})
	
	$("#button2").click(function() {
		if (mode == 0) {
			document.getElementById("button2").style.borderColor = "black";
			b = 2;
			$('#submit').text("Next");
			$('#submit').show();
			reward = nrand(mu[1],sd[k2]);
			$("#button2").text(reward);
			var currentTime = new Date().getTime();
			RT = currentTime - startTrialTime;
			mode = 1;
		}
	})
				  
	$("#submit").click(function() {
		$('#submit').hide();
		$("#button1").text(L[k1]);
	        $("#button2").text(L[k2]);
		document.getElementById("button1").style.borderColor = "white";
 	   	document.getElementById("button2").style.borderColor = "white";
		$('#title').text("Choose a slot machine");   
		Trial++;	
		mode = 0;	   

		var result_string = Game + ',' + b + ',' + reward + ',' + RT + ',' + mu[0] + ',' + mu[1] + ',' + k1 + ',' + k2 + '\n';
		$.post("post_results.php",{postresult: result_string, postfile: filename});
		   
		   // start next game
		   if (Trial == nTrials){
			   Trial = 0;
			   Game++;
			   $('#buttons').hide();
			   $('#startGame').show();
			   $('#startGame').text("Start game "+Game);
			   k1 = Math.floor(Math.random()*2);
			   k2 = Math.floor(Math.random()*2);
			   $("#button1").text(L[k1]);
			   $("#button2").text(L[k2]);
		   }
		   
		   // end of experiment
		   if (Game > nGames) {
			   $('#buttons').hide();
			   $('#startGame').hide();
			   $('#Instructions').show();
			   $('#title').hide();
			   $("#Instructions").text("You're done! \nYour code is " + subjID + ". Please return to the Mechanical Turk page to enter this code and get paid.");
		   }
		   
		 startTrialTime = new Date().getTime();
	})

});

function StartGame() {
	$('#startGame').hide();
	$('#Instructions').hide();
	$('#buttons').show();
	$('#title').text("Choose a slot machine");
	mu[0] = nrand(0,sd0);
	mu[1] = nrand(0,sd0);
	document.getElementById("button1").style.background=randomColor({luminosity: 'bright'});
	document.getElementById("button2").style.background=randomColor({luminosity: 'bright'});
	startTrialTime = new Date().getTime();
	k1 = Math.floor(Math.random()*2);
	k2 = Math.floor(Math.random()*2);
	$("#button1").text(L[k1]);
	$("#button2").text(L[k2]);
}

function StartExperiment() {
	$('#consent').hide();
	$('#startExperiment').hide();
	$('#Instructions').show();
	$('#startGame').show();
}

function nrand(m,sd){
	if (sd == 0) {
		return m;
	} else {
	var x1, x2, rad, y1;
	do {
		x1 = 2 * Math.random() - 1;
		x2 = 2 * Math.random() - 1;
		rad = x1 * x1 + x2 * x2;
	} while(rad >= 1 || rad == 0);
	
	var c = Math.sqrt(-2 * Math.log(rad) / rad);
	var y = Math.round((x1 * c * (sd^2))+m);
	return y;
	}
};