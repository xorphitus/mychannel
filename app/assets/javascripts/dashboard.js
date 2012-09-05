/*global setInterval, clearInterval, document, $, swfobject */

var video = {};
video.ID = 'videoplayer';
video.PLAYER_ID = 'mychannerlVideoplayer';
video.set = function (url, callback) {
    'use strict';
    var params = { allowScriptAccess: "always" },
        atts = { id: video.PLAYER_ID },
        id = 'videoplayerTarget',
        width = '425',
        height = '356',
        flashVersion = '8',
        targetUrl = url + '?enablejsapi=1&playerapiid=ytplayer';

    video.onFinish = callback;
    swfobject.embedSWF(targetUrl, id, width, height, flashVersion, null, null, params, atts);
};
var onVideoPlayerStateChange = function (state) {
    'use strict';
    if (state === 0) {
        video.onFinish();
    }
};
var onYouTubePlayerReady = function (id) {
    'use strict';
    var player = document.getElementById(video.PLAYER_ID);
    player.addEventListener('onStateChange', 'onVideoPlayerStateChange');
    player.playVideo();
};

$(function () {
    'use strict';

    var LOADING_IMG_ID = 'loadingimg',
        TEXT_DISPLAY_ID = 'textdisplay',
        queue = [],
        exec,
        loadData;

    exec = function (t) {
        var target = t;
        if (!target) {
            if (queue && queue.length > 0) {
                target = queue.shift();
            } else {
                loadData();
                return;
            }
        }
        if (target.text) {
            $('#' + TEXT_DISPLAY_ID).slideUp('fast').text(target.text).slideDown('fast');
            $('audio:first').attr('src', '/voice?text=' + encodeURI(target.text)).bind('ended', function () {
                $(this).unbind('ended');
                exec(queue.shift());
            });
        } else if (target.video) {
            $('#' + video.ID).slideDown();
            video.set(target.video[0].url, function () {
                $('#' + video.ID).slideUp();
                exec(queue.shift());
            });
        } else {
            exec(queue.shift());
        }
    };

    loadData = function () {
        $('#' + LOADING_IMG_ID).show();
        $.get('/topic', function (data) {
            queue = data;
            $('#' + LOADING_IMG_ID).hide();
            exec(queue.shift());
        });
    };

    loadData();

});
