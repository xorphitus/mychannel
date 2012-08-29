/*global $, swfobject */
$(function () {
    'use strict';

    var MOVIE_FADEOUT_SEC = 10;

    var VIDEO_PLAYER_ID = 'videoplayer';

    var LOADING_IMG_ID = 'loadingimg';

    var TEXT_DISPLAY_ID = 'textdisplay';

    var setMovie = function (url, callback) {
        var params = { allowScriptAccess: "always" },
            atts = { id: 'mychannerlVideoplayer' },
            videoId = "mYCttSFmeXA",
            id = 'videoplayerTarget',
            width = '425',
            height = '356',
            flashVersion = '8';

        url = 'http://www.youtube.com/v/' + videoId + '?enablejsapi=1&playerapiid=ytplayer';

        // TODO use a function 'onYouTubePlayerReady' in stead of callback
        swfobject.embedSWF(url, id, width, height, flashVersion, null, null, params, atts, function () {
            var player = $('object')[0],
                originalVolume,
                fadeoutTimer,
                readyTimer = setInterval(function () {
                    if (player.playVideo) {
                        player.playVideo();
                        if (!isNaN(originalVolume)) {
                            player.setVolume(originalVolume);
                        }
                        clearInterval(readyTimer);

                        // face out
                        fadeoutTimer = setInterval(function () {
                            var volume;
                            if (player.getCurrentTime() > MOVIE_FADEOUT_SEC) {
                                volume = player.getVolume();
                                originalVolume = volume;
                                if (volume > 10) {
                                    player.setVolume(volume * 0.7);
                                } else {
                                    clearInterval(fadeoutTimer);
                                    player.stopVideo();
                                    callback();
                                }
                            }
                        }, 1000);
                    }
            }, 10);
        });
    };

    //----------------------

    var queue = [];

    var exec = function (t) {
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
            $('audio:first').attr('src', '/voice?text=' + target.text).bind('ended', function () {
                $(this).unbind('ended');
                exec(queue.shift());
            });
        } else if (target.movie) {
            $('#' + VIDEO_PLAYER_ID).slideDown();
            setMovie(target.movie[0], function () {
                $('#' + VIDEO_PLAYER_ID).slideUp();
                exec(queue.shift());
            });
        } else {
            exec(queue.shift());
        }
    };

    var loadData = function () {
        $('#' + LOADING_IMG_ID).show();
        $.get('/topic', function (data) {
            queue = data;
            $('#' + LOADING_IMG_ID).hide();
            exec(queue.shift());
        });
    };

    loadData();

});

var d = [
    {
        text: '読み上げます',
        link: [{url: 'http://hoge.com', title: 'タイトル'}],
        image: [{url: 'http://hoge.com', title: 'タイトル'}],
        movie: [{url: 'http://hoge.com', title: 'タイトル'}]
    }
];