function SimpleDash() {}

SimpleDash.prototype.initialize = function () {
    this.canvas     = $('<canvas></canvas>').appendTo(this.rootElement).addClass('canvas');

    this.fuelDiv    = $('<div></div>').appendTo(this.rootElement).addClass('nonclickable').addClass('nonclickable-left');
    this.absDiv     = $('<div></div>').appendTo(this.rootElement).addClass('nonclickable').addClass('nonclickable-right');
    this.leftBlink  = $('<div></div>').appendTo(this.rootElement).addClass('clickable').addClass('clickable-left');
    this.rightBlink = $('<div></div>').appendTo(this.rootElement).addClass('clickable').addClass('clickable-right');
    this.lightsDiv  = $('<div></div>').appendTo(this.rootElement).addClass('clickable').addClass('clickable-right');
    this.hBrake     = $('<div></div>').appendTo(this.rootElement).addClass('clickable').addClass('clickable-left');

    var self = this;
    this.hBrake.click(function(){self.inputhandlerthing("!");});
    this.leftBlink.click(function(){self.inputhandlerthing("<");});
    this.rightBlink.click(function(){self.inputhandlerthing(">");});
    this.lightsDiv.click(function(){self.inputhandlerthing("li");});

    this.fuelDiv.html('<svg><path d="m 11.599682,3.99991 c -0.81258,0 -1.4668,0.65976 -1.4668,1.4793 v 21.302 H 9.5003424 c -0.209,0 -0.375,0.168 -0.375,0.379 v 1.4608 c 0,0.21121 0.16643,0.37908 0.37586,0.37908 H 23.288202 c 0.20943,0 0.37586,-0.16787 0.37586,-0.37908 v -1.4608 c 0,-0.21121 -0.16643,-0.37905 -0.37586,-0.37905 h -0.63254 v -11.918 c 0.18658,0.0074 0.45592,0.02843 0.75171,0.12944 0.22354,0.07632 0.39653,0.18786 0.5042,0.31435 0.10767,0.12649 0.18296,0.26899 0.17418,0.6102 -0.05394,2.0943 0.06417,6.703 0.06417,6.703 v 0.04615 c 0,0 0.05889,0.82642 0.55003,1.6457 0.49114,0.81929 1.5523,1.6715 3.126,1.5902 1.1613,-0.05994 2.2656,-0.49455 2.9977,-1.3591 0.73205,-0.86452 1.004,-2.1342 0.6417,-3.5503 -0.31598,-1.2349 -0.64292,-2.4561 -0.88922,-3.4301 -0.12315,-0.48698 -0.23285,-0.90867 -0.30252,-1.2389 -0.06967,-0.33024 -0.09145,-0.59958 -0.09167,-0.60095 -0.14062,-0.85825 -0.24212,-1.2011 -0.48984,-3.6469 -0.05622,-0.32513 0.62325,-0.31752 0.88941,-0.5302 0.268,-0.2115 0.371,-0.6078 0.244,-0.9252 -0.521,-1.3256 -1.21,-2.8088 -1.962,-3.689 -1.489,-1.7425 -2.095,-2.3451 -2.723,-2.6442 -0.157,-0.0748 -0.343,-0.1546 -0.614,-0.1202 -0.27,0.0345 -0.571,0.2662 -0.678,0.4715 -0.21375,0.41067 -0.09167,0.63794 -0.09167,0.63794 l 0.13372,0.26298 0.17797,0.23628 c 0.33761,0.25099 1.2085,1.5036 1.8334,2.7737 0.62499,1.27 1.103,2.714 1.1367,3.0603 0.25898,2.6607 0.35607,3.1983 0.4342,3.7549 0.04203,0.29946 0.17568,0.92503 0.25334,1.2932 0.07766,0.36814 0.18601,0.80662 0.31168,1.3036 0.25135,0.99399 0.57659,2.2083 0.88922,3.4301 0.26626,1.0406 0.07886,1.6668 -0.30252,2.1172 -0.38138,0.45038 -1.0418,0.75234 -1.8701,0.79512 -1.0465,0.05402 -1.4169,-0.34819 -1.6959,-0.81361 -0.279,-0.46541 -0.33002,-0.96154 -0.33002,-0.96154 -0.0018,-0.07669 -0.10541,-4.6163 -0.055,-6.5736 0.0174,-0.67577 -0.20523,-1.2761 -0.5592,-1.6919 -0.35397,-0.41586 -0.79583,-0.64757 -1.2009,-0.78587 -0.50094,-0.17104 -0.96187,-0.2064 -1.2559,-0.21265 V 5.4801 c 0,-0.81952 -0.65417,-1.4793 -1.4668,-1.4793 z m 1.0084,1.8861 7.5721,0 c 0.37959,0 0.67837,0.31058 0.67837,0.69342 v 5.4179 c 0,0.38283 -0.29878,0.69342 -0.67837,0.69342 h -7.5721 c -0.37959,0 -0.67837,-0.31058 -0.67837,-0.69342 v -5.4179 c 0,-0.38283 0.29878,-0.69342 0.67837,-0.69342 z" id="fuel" style="text-indent:0;text-align:start;text-transform:none;direction:ltr;block-progression:tb;baseline-shift:baseline;color:#000000;fill-opacity:0.5;enable-background:accumulate" /> <rect width="5" height="25" x="1.8751144" y="4" id="fuelbar" style="fill:none;stroke:#000000;stroke-width:1;stroke-miterlimit:4;stroke-opacity:0.5;stroke-dasharray:none" /></svg>');

    this.hBrake.html('<svg><path d="m 6.5845,26.4155 c -5.4762,-5.4762 -5.4762,-14.355 0,-19.831 m 19.831,-4e-7 C 31.8917,12.0607 31.8917,20.9395 26.4155,26.4155 M 27.7181,16.5 a 11.218,11.218 0 0 1 -22.436,0 11.218,11.218 0 1 1 22.436,0 z" id="hbrake_outer" style="fill:none;stroke:#000000;stroke-width:1.95470738;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:0.5;stroke-dasharray:none" /> <path d="m 17.091605,20.80508 -1.1832,0 -0.84555,-10.88 c -0.05373,-0.47456 -0.08059,-0.82826 -0.08059,-1.0611 -3e-6,-0.5641 0.14998,-1.0163 0.44995,-1.3566 0.29997,-0.34025 0.66038,-0.51038 1.0812,-0.5104 0.42085,1.85e-5 0.77678,0.17015 1.0678,0.5104 0.29101,0.34028 0.43652,0.8462 0.43652,1.5178 -7e-6,0.21492 -0.01788,0.51489 -0.05371,0.89991 z m -0.60505,2.2296 c 0.41189,2e-6 0.76335,0.14551 1.0544,0.43652 0.29101,0.29102 0.43652,0.638 0.43652,1.0409 -7e-6,0.4119 -0.14552,0.76336 -0.43652,1.0544 -0.29102,0.29102 -0.64248,0.43652 -1.0544,0.43652 -0.4119,0 -0.76336,-0.14551 -1.0544,-0.43652 -0.29102,-0.29102 -0.43653,-0.64247 -0.43652,-1.0544 -4e-6,-0.40294 0.1455,-0.74992 0.43652,-1.0409 0.29101,-0.29101 0.64247,-0.43652 1.0544,-0.43652 z" id="hbrake_inner" style="fill-opacity:0.5" /></svg>');

    this.leftBlink.html('<svg><path d="m 1.5,16.5 16.416,15 0,-7.053 13.584,0 0,-15.894 -13.584,0 0,-7.053 -16.416,15 z" id="blink_left" style="fill-opacity:0.5" /></svg>');

    this.rightBlink.html('<svg><path d="m 31.498,16.5 -16.416,15 0,-7.053 -13.584,0 0,-15.894 13.584,0 0,-7.053 16.42,15 z" id="blink_right" style="fill-opacity:0.5"/></svg>');

    this.absDiv.html('<svg><path d="m 6.5845,26.416 c -5.4762,-5.4762 -5.4762,-14.355 0,-19.831 m 19.831,-4e-7 C 31.8917,12.0612 31.8917,20.94 26.4155,26.416 m 1.31,-9.916 a 11.218,11.218 0 0 1 -22.436,0 11.218,11.218 0 1 1 22.436,0 z" id="abs_outer" style="fill:none;stroke:#000000;stroke-width:1.95470738;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:0.5;stroke-dasharray:none" /> <path d="m 20.220955,17.53219 1.1636,-0.11312 c 0.07,0.39055 0.21211,0.6774 0.42624,0.86055 0.21412,0.18316 0.50299,0.27473 0.86661,0.27473 0.38516,1e-6 0.67537,-0.08148 0.87065,-0.24443 0.19527,-0.16295 0.29291,-0.35351 0.29291,-0.57168 0,-0.14006 -0.0411,-0.25924 -0.12322,-0.35755 -0.0822,-0.09831 -0.22558,-0.18382 -0.43028,-0.25655 -0.14006,-0.04848 -0.45923,-0.13467 -0.95751,-0.25857 -0.64104,-0.15891 -1.0908,-0.35418 -1.3494,-0.58582 -0.36362,-0.3259 -0.54542,-0.72318 -0.54542,-1.1918 0,-0.30166 0.0855,-0.5838 0.25654,-0.84641 0.17104,-0.2626 0.41749,-0.46259 0.73935,-0.59996 0.32187,-0.13736 0.71039,-0.20604 1.1656,-0.20605 0.74338,7e-6 1.3029,0.16296 1.6787,0.48886 0.37573,0.32591 0.57302,0.7609 0.59188,1.305 l -1.1959,0.05252 c -0.0512,-0.30435 -0.16093,-0.5232 -0.32927,-0.65652 -0.16834,-0.13332 -0.42085,-0.19998 -0.75753,-0.19999 -0.34745,5e-6 -0.61949,0.07138 -0.81611,0.21413 -0.12659,0.09158 -0.18988,0.21413 -0.18988,0.36765 0,0.14006 0.0593,0.25992 0.17776,0.35957 0.15083,0.1266 0.51714,0.25857 1.0989,0.39593 0.58178,0.13737 1.0121,0.27945 1.2908,0.42624 0.27877,0.1468 0.49694,0.34746 0.65451,0.60198 0.15756,0.25453 0.23634,0.56899 0.23635,0.94338 -10e-6,0.33937 -0.0943,0.6572 -0.28282,0.95348 -0.18854,0.29628 -0.45519,0.51647 -0.79994,0.66056 -0.34477,0.1441 -0.77437,0.21615 -1.2888,0.21615 -0.74878,-1e-6 -1.3238,-0.17305 -1.7252,-0.51916 -0.40132,-0.3461 -0.64103,-0.85045 -0.71914,-1.513 z m -5.6724,-3.9957 2.3675,0 c 0.46865,6e-6 0.81812,0.01953 1.0484,0.05858 0.23029,0.03906 0.43634,0.12054 0.61815,0.24443 0.1818,0.1239 0.3333,0.28888 0.45451,0.49492 0.1212,0.20605 0.18181,0.43701 0.18181,0.69288 0,0.27743 -0.0747,0.53196 -0.22423,0.76359 -0.14949,0.23164 -0.35217,0.40536 -0.60804,0.52118 0.36092,0.10505 0.63834,0.28416 0.83227,0.53734 0.19392,0.25318 0.29089,0.55081 0.29089,0.89287 0,0.26934 -0.0626,0.53128 -0.18787,0.78581 -0.12525,0.25453 -0.29628,0.45788 -0.51309,0.61006 -0.21683,0.15218 -0.48415,0.24578 -0.80197,0.28079 -0.19932,0.02155 -0.6801,0.03501 -1.4423,0.0404 h -2.016 z m 1.1959,0.9858 0,1.3696 0.78379,0 c 0.46596,4e-6 0.75551,-0.0067 0.86863,-0.0202 0.2047,-0.02424 0.36563,-0.09494 0.4828,-0.21211 0.11716,-0.11716 0.17574,-0.27136 0.17575,-0.4626 -10e-6,-0.18315 -0.0505,-0.33196 -0.15151,-0.44644 -0.10101,-0.11447 -0.25116,-0.18382 -0.45047,-0.20807 -0.11852,-0.01346 -0.45924,-0.02019 -1.0222,-0.0202 z m 0,2.3554 0,1.5837 1.107,0 c 0.43095,10e-7 0.70433,-0.01212 0.82015,-0.03636 0.17777,-0.03232 0.32254,-0.1111 0.43432,-0.23635 0.11177,-0.12524 0.16766,-0.29291 0.16767,-0.503 -10e-6,-0.17776 -0.0431,-0.3286 -0.12929,-0.4525 -0.0862,-0.1239 -0.21076,-0.21413 -0.37371,-0.27069 -0.16296,-0.05656 -0.51647,-0.08484 -1.0605,-0.08484 z m -1.8383,2.5817 -1.3009,0 -0.51713,-1.3454 -2.3675,0 -0.48886,1.3454 -1.2686,0 2.3069,-5.9229 1.2646,0 z m -2.2019,-2.3433 -0.81611,-2.1978 -0.79995,2.1978 z" id="abs_inner"style="fill-opacity:0.5" /></svg>');

    this.lightsDiv.html('<svg><path d="m 1.4999998,7.1896556 0,2.0689658 11.2823302,0 c 0.16971,-0.7605906 0.41179,-1.4416821 0.7112,-2.0689658 l -11.9935302,0 z m 0,4.1379304 0,2.068965 10.8297402,0 c 0.028,-0.710575 0.0616,-1.411741 0.12931,-2.068965 l -10.9590502,0 z m 0,4.137931 0,2.068965 10.7650902,0 c -0.003,-0.348002 0,-0.679101 0,-1.034482 0,-0.355381 -0.003,-0.686481 0,-1.034483 l -10.7650902,0 z m 0,4.137931 0,2.068965 10.9590502,0 c -0.0678,-0.657224 -0.10127,-1.358389 -0.12931,-2.068965 l -10.8297402,0 z m 0,4.137931 0,2.068965 11.9935302,0 c -0.29941,-0.627283 -0.54149,-1.308375 -0.7112,-2.068965 l -11.2823302,0 z M 20.12069,5.1206901 c -3.13618,0 -5.16973,1.4881044 -6.07759,3.6530173 C 13.13525,10.93862 13.1056,13.626243 13.1056,16.5 c 0,2.873758 0.0297,5.56138 0.9375,7.726293 0.90786,2.164913 2.94141,3.653017 6.07759,3.653017 C 26.39306,27.87931 31.5,22.772368 31.5,16.5 31.5,10.227633 26.39306,5.1206901 20.12069,5.1206901 z m 0,2.0689655 c 5.15422,0 9.31034,4.1561314 9.31034,9.3103444 0,5.154214 -4.15612,9.310344 -9.31034,9.310344 -2.5771,0 -3.50803,-0.813063 -4.17026,-2.392241 -0.66222,-1.579178 -0.77586,-4.07857 -0.77586,-6.918103 0,-2.839533 0.11364,-5.338925 0.77586,-6.9181031 0.66223,-1.5791783 1.59316,-2.3922413 4.17026,-2.3922413 z" id="lights" style="fill-opacity:0.5"/></svg>');

    this.svg = {};
    var svgIdList = ["fuel","hbrake_outer","hbrake_inner","blink_left","blink_right","abs_inner","abs_outer","lights"];
    for (var i = svgIdList.length - 1; i >= 0; i--) {
    	this.svg[svgIdList[i]] = this.rootElement.find("#"+svgIdList[i])[0];
    }
};

SimpleDash.prototype.inputhandlerthing = function(switchvar){
    switch(switchvar){
        case "<":
            beamng.sendActiveObjectLua("electrics.toggle_left_signal()");
            break;
        case ">":
            beamng.sendActiveObjectLua("electrics.toggle_right_signal()");
            break;
        case "li":
            beamng.sendActiveObjectLua("electrics.toggle_lights()");
            break;
        case "!":
            beamng.sendActiveObjectLua("input.toggleEvent(\"axisy2\", " + 1 + ", 0)");
            break;
    }
};

SimpleDash.prototype.update = function (streams) {
    var fuelVal     = Math.round(streams.electrics.fuel*100)/100;
    var fuelLow     = Math.round(streams.electrics.lowfuel);
    var parkingVal  = Math.round(streams.electrics.parkingbrake);
    var leftBlink   = Math.round(streams.electrics.signal_L);
    var rightBlink  = Math.round(streams.electrics.signal_R);
    var absOn       = Math.round(streams.electrics.abs);
    var lightsState = Math.round(streams.electrics.lights);

    var c = this.canvas[0];
    var ctx = c.getContext('2d');
    ctx.clearRect(0,0,33,33);

    //fuel stuff
    if (fuelLow) {
        this.svg.fuel.style.fill="#FF8000";
    } else {
        this.svg.fuel.style.fill="#000";
    }
    ctx.fillStyle = "RGBA(0,0,128,0.5)";
    ctx.fillRect(2,29,5,-fuelVal*25);

    //handbrake
    if (parkingVal > 0.5) {
        this.svg.hbrake_outer.style.stroke="#FF8000";
        this.svg.hbrake_inner.style.fill="#FF8000";
    } else {
        this.svg.hbrake_outer.style.stroke="#000";
        this.svg.hbrake_inner.style.fill="#000";
    }

    //indicators
    if (leftBlink > 0.5) {
        this.svg.blink_left.style.fill="#0f0";
    } else {
        this.svg.blink_left.style.fill="#000";
    }
    if (rightBlink > 0.5) {
        this.svg.blink_right.style.fill="#0f0";
    } else {
        this.svg.blink_right.style.fill="#000";
    }

    //abs indicator
    if (absOn > 0.5) {
        this.svg.abs_inner.style.fill="#FF8000";
        this.svg.abs_outer.style.stroke="#FF8000";
    } else {
        this.svg.abs_inner.style.fill="#000";
        this.svg.abs_outer.style.stroke="#000";
    }

    //headlights
    if (lightsState == 1) {
        this.svg.lights.style.fill="#0f0";
    } else if (lightsState == 2) {
        this.svg.lights.style.fill="#00f";
    } else {
        this.svg.lights.style.fill="#000";
    }
};
