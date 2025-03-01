function SimpleSpeedo(){}

SimpleSpeedo.prototype.initialize = function(){
    this.canvas = $('<canvas height="53px"></canvas>').appendTo(this.rootElement).addClass('canvas');

    this.labelDiv = $('<div></div>').appendTo(this.rootElement).addClass('labelDiv');

    this.canvas.width = 200;
    this.canvas.height = 53;

    this.loaded = false;

    var self = this;
    this.labelDiv.click(function(){self.toggleUnit();});

    //If no unit was previously selected, default to km/h
    if ((this.persistance.Unit != "MPH") && (this.persistance.Unit != "km/h")) this.persistance.Unit = "km/h";
};

SimpleSpeedo.prototype.toggleUnit = function(){
    //Toggle between MPH and km/h, save the option to persistance system
    this.persistance.Unit = this.persistance.Unit === 'MPH' ? 'km/h' : 'MPH';
    this.save();
};


SimpleSpeedo.prototype.update = function(streams){

    //Get the values to work with, do rounding and stuff as needed
    var speedMs = streams.electrics.wheelspeed;
    if (isNaN(speedMs)) speedMs = streams.electrics.airspeed;    //If no wheelspeedo present use airspeed

    var speedUnits;
    //Modify with selected units
    if(this.persistance.Unit == "MPH"){
        speedUnits = toInt(2.236*speedMs);
    } else {
        speedUnits = toInt(3.6*speedMs);
    }

    var speedStart;
    //for resetting scale >160
    if (speedUnits > 160) {
        speedStart = 160;
    } else {
        speedStart = 0;
    }

    //start canvas stuff
    var c = this.canvas[0];
    var ctx = c.getContext('2d');

    //clear before drawing stuff on canvas
    ctx.clearRect(0,0,200,53);

    //Make the bar
    if (speedStart === 0){
        ctx.fillStyle = "RGBA(0,0,255,0.5)";
    } else {
        ctx.fillStyle = "RGBA(255,0,255,0.5)";
    }

    ctx.fillRect(20,10,Math.min(speedUnits-speedStart, 160),25);

    //text
    ctx.font='20px Arial';
    ctx.textAlign="center";

    ctx.fillStyle = "black";
    ctx.fillText(rSet(speedUnits, 3, "0"),100,30);

    //add border
    ctx.strokeRect(20,10,160,25);

    //Add labels
    //-Units
    this.labelDiv.html("Speed (" + this.persistance.Unit + ")");

    //-Numbers
    ctx.font='7px Arial';
    var interval = 20;
    for (var x=0; x<=160; x+=interval) {
        ctx.fillText(speedStart+x,x+20,48);
    }

    //Add Graduations
    //20px/20unit intervals
    for (var x1=20; x1<=180; x1+=interval) {
        ctx.beginPath();
        ctx.moveTo(x1, 35);
        ctx.lineTo(x1, 40);
        ctx.stroke();
    }
    //and 10px/10unit intervals
    for (var x2=30; x2<=180; x2+=interval) {
        ctx.beginPath();
        ctx.moveTo(x2, 35);
        ctx.lineTo(x2, 38);
        ctx.stroke();
    }
};
