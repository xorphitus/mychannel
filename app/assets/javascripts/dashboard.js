/*global setInterval, alert, document, $, swfobject */

var video = {},
    onYouTubePlayerReady;

video.ID = 'videoplayer';
video.PLAYER_ID = 'mychannelVideoplayer';
video.set = function (url, callback) {
    'use strict';
    var player = document.getElementById(video.PLAYER_ID),
        params = { allowScriptAccess: "always" },
        atts = { id: video.PLAYER_ID },
        id = 'videoplayerTarget',
        width = '425',
        height = '356',
        flashVersion = '8',
        targetUrl = url + '?enablejsapi=1&playerapiid=ytplayer';

    if (player) {
        player.loadVideoByUrl(targetUrl);
    } else {
        video.onFinish = callback;
        swfobject.embedSWF(targetUrl, id, width, height, flashVersion, null, null, params, atts);
    }
};
video.onPlayerStateChange = function (state) {
    'use strict';
    if (state === 0) {
        video.onFinish();
    }
};
onYouTubePlayerReady = function () {
    'use strict';
    var player = document.getElementById(video.PLAYER_ID);
    player.addEventListener('onStateChange', 'video.onPlayerStateChange');
    player.playVideo();
};

$(function () {
    'use strict';

    var LOADING_IMG_ID = 'loadingimg',
        TEXT_DISPLAY_ID = 'textdisplay',
        PLAY_BTN_ID = 'play_btn',
        CHANNEL_SELECTOR_ID = 'channel_selector',
        LOAD_INTERVAL_MILLIS = 3000,
        QUEUE_SIZE = 3,
        queue = [],
        exec,
        loadData,
        channelId;

    exec = function (t) {
        var target = t;
        if (!target) {
            if (queue && queue.length > 0) {
                target = queue.shift();
            } else {
                loadData(exec);
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
                // TODO ここでplayerを非表示にすると再生用の関数等も消えてしまう
                // $('#' + video.ID).slideUp();
                exec(queue.shift());
            });
        } else {
            exec(queue.shift());
        }
    };

    loadData = function (callback) {
        $('#' + LOADING_IMG_ID).show();
        $.get('/story?channel_id=' + channelId, function (data) {
            queue = queue.concat(data);
            $('#' + LOADING_IMG_ID).hide();
            if (typeof callback === 'function') {
                callback();
            }
        });
    };

    $('#' + PLAY_BTN_ID).click(function () {
        channelId = $('#' + CHANNEL_SELECTOR_ID).val();
        if (channelId) {
            setInterval(function () {
                if (queue.length < QUEUE_SIZE) {
                    loadData();
                }
            }, LOAD_INTERVAL_MILLIS);
            exec();
        } else {
            alert('番組を選んで下さい');
        }
    });
});
