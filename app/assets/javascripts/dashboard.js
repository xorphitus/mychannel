/*global setInterval, alert, document, $, swfobject */

var video = {},
    onYouTubePlayerReady,
    linkDisplay,
    channelSelector;

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

linkDisplay = (function () {
    'use strict';
    var LINK_DISPLAY_ID = 'link_display',
        LINK_TEXT_MAX_SIZE = 50;

    return {
        add: function (links) {
            links.forEach(function (i) {
                var li = $('<li>'),
                    icon = $('<i>').addClass('icon-hand-right'),
                    a = $('<a>').attr({href: i, target: '_blank'})
                        .addClass('btn btn-link'),
                    text = i;
                if (text.length > LINK_TEXT_MAX_SIZE) {
                    text = text.substring(0, LINK_TEXT_MAX_SIZE) + '...';
                }
                a.text(text);

                $('#' + LINK_DISPLAY_ID).prepend(li.append(icon).append(a));
            });
        }
    };
}());

channelSelector = (function () {
    'use strict';

    var CHANNEL_SELECTOR_ID = 'channel_selector';

    return {
        init: function () {
            var selector = $('#' + CHANNEL_SELECTOR_ID);
            if (selector.find('option').size()  > 1) {
                selector.fadeIn();
            }
        },
        getId: function () {
            return $('#' + CHANNEL_SELECTOR_ID).val();
        }
    };
}());

(function () {
    'use strict';

    var LOADING_IMG_ID = 'loadingimg',
        TEXT_DISPLAY_ID = 'textdisplay',
        PLAY_BTN_ID = 'play_btn',
        WEBRIC_URI_MAX_LENGTH = 1000,
        READ_TEXT_MAX_LENGTH = 100,
        LOAD_INTERVAL_MILLIS = 3000,
        QUEUE_SIZE = 3,
        queue = [],
        exec,
        loadData,
        channelId;

    exec = function (t) {
        var target = t,
            encodedText;
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
            encodedText = encodeURIComponent(target.text);
            if (encodedText.length > WEBRIC_URI_MAX_LENGTH) {
                encodedText = encodeURIComponent(target.text.substring(0, READ_TEXT_MAX_LENGTH));
            }
            $('audio:first').attr('src', '/voice?text=' + encodedText).bind('ended', function () {
                $(this).unbind('ended');
                exec(queue.shift());
            });
            if (target.link) {
                linkDisplay.add(target.link);
            }
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

    channelSelector.init();

    $('#' + PLAY_BTN_ID).click(function () {
        channelId = channelSelector.getId();
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
}());
