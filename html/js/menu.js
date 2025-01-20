var videoConfig = [
    // video, title, description, mission name to load, position/rotation
    ["images/mainmenu_3_720p.webm", "", "", ""]
];

var min_w = 300; // minimum video width allowed
var vid_w_orig;  // original video dimensions
var vid_h_orig;

var videoElement = null;

var fadeTime = 2; // in seconds

var randomArray = randomNumbers(videoConfig.length);

var randomPosition = -1;
var currentEntryID = -1;
var currentEntry = null;

function resizeToCover() {
    // set the video viewport to the window size
    $('#video-viewport').width($(window).width());
    $('#video-viewport').height($(window).height());

    // use largest scale factor of horizontal/vertical
    var scale_h = $(window).width() / vid_w_orig;
    var scale_v = $(window).height() / vid_h_orig;
    var scale = scale_h > scale_v ? scale_h : scale_v;

    // don't allow scaled width < minimum video width
    if (scale * vid_w_orig < min_w) { scale = min_w / vid_w_orig; }

    // now scale the video
    $('video').width(scale * vid_w_orig);
    $('video').height(scale * vid_h_orig);
    // and center it by scrolling the video viewport
    $('#video-viewport').scrollLeft(($('video').width() - $(window).width()) / 2);
    $('#video-viewport').scrollTop(($('video').height() - $(window).height()) / 2);
}


function checkTime() {
    if (videoElement.duration - videoElement.currentTime < fadeTime + 0.1) {
        $('#blending').fadeIn(fadeTime * 1000);
        setTimeout(checkTime, 4000);
    } else {
        setTimeout(checkTime, videoElement.duration - videoElement.currentTime - (fadeTime + 0.05) * 1000);
    }
}

function playNewEntry() {
    currentEntryID = 0;
    currentEntry = videoConfig[currentEntryID];

    // play the video
    $('#bgvid').attr("src", currentEntry[0]);
    videoElement.play();

    // update the info text
    $('#infobox').html(currentEntry[1] + '<br/>' + currentEntry[2]);
}

function gotGameVersion(versionStr, buildInfoStr) {
    $('#beamngversion').html('techdemo v2');
    $('#beamngbuildinfo').html(buildInfoStr);
    
    $('#beamngversion').click(function() {
        $('#beamngbuildinfo').slideToggle('fast', function() {
            // Animation complete.
        });
    });

}
function gotSteamData(data) {
    //console.log("steam data:");
    //console.log(data);
    if(data.working && data.loggedin) {
        var t = '<b>' + data.playerName + '</b><br/>';
        if(data.branch != 'public')
            t += i18n.t('steambranches.' + data.branch, {defaultValue: data.branch}) + '<br/>';
        if(data.language != 'english')
            t += data.language + '<br/>';
        $('#steaminfotext').html(t);
        $('#steaminfo').css("display","block");
    }
}
function timeSinceEpochAgo(epoch) {
    var date = new Date(0); // The 0 there is the key, which sets the date to the epoch
    date.setUTCSeconds(epoch);

    var diff = (new Date() - date) / 1000;
    if(diff < 0) {
        // fix for negative time :)
        diff = 0;
        return i18n.t('time.just_now', { t: interval, defaultValue: "Just now" });
    }
    var seconds = Math.floor(diff);

    var interval = Math.floor(seconds / 31536000);

    if (interval > 1) {
        return i18n.t('time.years_ago', { t: interval, defaultValue: interval + " years ago" });
    }
    interval = Math.floor(seconds / 2592000);
    if (interval > 1) {
        return i18n.t('time.months_ago', { t: interval, defaultValue: interval + " months ago" });
    }
    interval = Math.floor(seconds / 86400);
    if (interval > 1) {
        return i18n.t('time.days_ago', { t: interval, defaultValue: interval + " days ago" });
    }
    interval = Math.floor(seconds / 3600);
    if (interval > 1) {
        return i18n.t('time.hours_ago', { t: interval, defaultValue: interval + " hours ago" });
    }
    interval = Math.floor(seconds / 60);
    if (interval > 1) {
        return i18n.t('time.minutes_ago', { t: interval, defaultValue: interval + " minutes ago" });
    }
    interval = Math.floor(seconds);
    return i18n.t('time.seconds_ago', { t: interval, defaultValue: interval + " seconds ago" });
}
function parseBBCode(text) {
    text = text.replace(/\[url=http:\/\/([^\s\]]+)\s*\](.*(?=\[\/url\]))\[\/url\]/g, '<a href="http-external://$1">$2</a>');
    text = text.replace(/\[url\]http:\/\/(.*(?=\[\/url\]))\[\/b\]/g, '<a href="http-external://$1">$1</a>');
    text = text.replace(/\[ico=([^\s\]]+)\s*\](.*(?=\[\/ico\]))\[\/ico\]/g, '<img src="images/icons/$1.png">$2</a>');
    text = text.replace(/\[b\](.*(?=\[\/b\]))\[\/b\]/g, '<span style="font-family:OpenSans-ExtraBold">$1</span>');
    text = text.replace(/\[h1\](.*(?=\[\/h1\]))\[\/h1\]/g, '<h1>$1</h1>');
    text = text.replace(/\[br\]/g, '</br>');
    text = text.replace(/\[list\]/g, '<ul>');
    text = text.replace(/\[\/list\]/g, '</ul>');
    text = text.replace(/\[olist\]/g, '<ol>');
    text = text.replace(/\[\/olist\]/g, '</ol>');
    text = text.replace(/\[\*\](.*(?=\n))\n/g, '<li>$1</li>');
    text = text.replace(/\[u\](.*(?=\[\/u\]))\[\/u\]/g, '<u>$1</u>');
    text = text.replace(/\[s\](.*(?=\[\/s\]))\[\/s\]/g, '<s>$1</s>');
    text = text.replace(/\[strike\](.*(?=\[\/strike\]))\[\/strike\]/g, '<s>$1</s>');
    text = text.replace(/\[i\](.*(?=\[\/i\]))\[\/i\]/g, '<i>$1</i>');
    text = text.replace(/\[ico=([^\s\]]+)\s*\]/g, '<img class="ico" src="images/icons/$1.png"/>');
    text = text.replace(/\[code\](.*(?=\[\/code\]))\[\/code\]/g, '<span class="bbcode-pre">$1</span>');
    text = text.replace(/\n/g, '<br/>');
    return text
}
function updateChangelog() {
    $.getJSON('versioninfo.json', function(data) {
        //console.log(data);

        $('#updates_box').css("display","block");
        if(data.autohide) {
            setTimeout(function () { $('#updates_box').css('left', '-514px'); }, 3000);
        }
        
        var headerhtml = "<table border='0' width='100%'><tr><td>" + i18n.t('newsbox.' + data.title[0], {defaultValue: data.title[0]}) + "</td>";
        if(data.title.length > 1) {
            headerhtml += "<td align='right' valign='bottom' class='updates_header_sub'>" + i18n.t('newsbox.' + data.title[1], {defaultValue: data.title[1]}) + "</td>";
        }
        headerhtml += "</tr></table>";
        $('#updates_header').html(headerhtml);

        var versionhtml = ''
        $.each(data.content, function(k, v) {
            versionhtml += "<div class='updates_versionheader'>";
            versionhtml += "<table border='0' width='100%'><tr><td><img class='ico' src='images/icons/bullet1.png'/> " + v.title;
            if(v.title == data.current) {
                versionhtml += ' (' + i18n.t('steambranches.current', {defaultValue: 'current'}) + ')';
            }
            if(typeof v.type !== 'undefined') {
                versionhtml += " (" + i18n.t('steambranches.' + v.type, {defaultValue: v.type}) + ")";
            }
            versionhtml += "</td>";

            if(typeof v.timestamp !== 'undefined') {
                versionhtml += "<td class='updates_versionheader_sub'> " + timeSinceEpochAgo(v.timestamp) + "</td>";
            }
            versionhtml += "</tr></table></div>";
            versionhtml += "<div class='updates_inner_scrolling'>";
            if(typeof v.content === 'undefined') {
                //console.log("error: content broken");
                //console.log(v.content);
            } else if(typeof v.content === 'string' ) {
                versionhtml += "<div class='updates_content'>" + parseBBCode(v.content) + "</div>";
                //versionhtml += "<div class='updates_spacer'></div>";
            } else if(typeof v.content === "object") {
                $.each(v.content, function(k2, v2) {
                    versionhtml += "<div class='updates_subheader'><table border='0'><tr><td><img class='updates_contenticon' src='images/icons/" + v2.icon + ".png'/></td><td>" + i18n.t('newsbox.' + k2, {defaultValue: k2}) + "</td></tr></table></div>";
                    versionhtml += "<div class='updates_content'>";
                    if(typeof v2.list === "object") {
                        versionhtml += "<ul>";
                        $.each(v2.list, function(k3, v3) {
                            versionhtml += "<li>" + parseBBCode(v3) + "</li>";
                        });
                        versionhtml += "</ul>";
                    } else if(typeof v2.text === "string") {
                        versionhtml += "<div style='padding:10px;'>" + parseBBCode(v2.text) + "</div>";
                    }
                    versionhtml += "</div>";
                });
                //versionhtml += "<div class='updates_spacer'></div>";
            }
            versionhtml += "</div>";
        });
        $('#updates_inner').html(versionhtml);
    }).fail(function(jqxhr, textStatus, error) {
        $('#updates_box').css("display","none");
        console.log("error "+error+" : "+textStatus );
    });
}

function windowResized() {
    $("#menu").height($(window).height());
}

$(document).ready(function () {
    $("#bootfader").fadeOut(600);

    //setTimeout(function () { $('#menu').css('right', '-160px'); }, 3000); /* Change 'left' to 'right' for panel to appear to the right */
    //setTimeout(function () { $('#updates_box').css('left', '-514px'); }, 3000);

    videoElement = document.getElementById('bgvid');

    playNewEntry();
    $('#blending').fadeOut(fadeTime * 1000);

    $('#bgvid').bind('ended', function (event) {
        playNewEntry();
        $('#blending').fadeOut(fadeTime * 1000);
    });

    // fixes video size
    vid_w_orig = parseInt($('video').attr('width'));
    vid_h_orig = parseInt($('video').attr('height'));
    $(window).resize(function () { resizeToCover(); });
    $(window).trigger('resize');

    // run blending
    checkTime();

    // fix layout
    $(window).on('resize', function() {
        windowResized();
    });
    windowResized();

    // run beamng things
    if(typeof beamng !== 'undefined') {
        beamng.requestVersionInfo();
        beamng.requestSteamInfo('gotSteamData');
        updateChangelog();
    }

});
