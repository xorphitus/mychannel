window.video =
  ID: 'videoplayer'
  PLAYER_ID: 'mychannelVideoplayer'
  play: (url, callback) ->
    player = document.getElementById(video.PLAYER_ID)
    params = allowScriptAccess: 'always'
    atts = id: video.PLAYER_ID
    id = 'videoplayerTarget'
    width = '425'
    height = '356'
    flashVersion = '8'
    targetUrl = url + '?enablejsapi=1&playerapiid=ytplayer'
    if player
      player.loadVideoByUrl(targetUrl)
    else
      video.onFinish = callback
      swfobject.embedSWF(targetUrl, id, width, height, flashVersion, null, null, params, atts)

  onPlayerStateChange: (state) ->
    video.onFinish() if state is 0

window.onYouTubePlayerReady = ->
  player = document.getElementById(video.PLAYER_ID)
  player.addEventListener('onStateChange', 'video.onPlayerStateChange')
  player.playVideo()

window.linkDisplay = (->
  LINK_DISPLAY_ID = 'link_display'
  LINK_TEXT_MAX_SIZE = 50
  add: (links) ->
    links.forEach (i) ->
      li = $('<li>')
      icon = $('<i>').addClass('icon-hand-right')
      a = $('<a>').attr(
        href: i
        target: '_blank'
      ).addClass('btn btn-link')
      text = i
      text = text.substring(0, LINK_TEXT_MAX_SIZE) + '...' if text.length > LINK_TEXT_MAX_SIZE
      a.text text
      $('#' + LINK_DISPLAY_ID).prepend(li.append(icon).append(a))
)()

window.channelSelector = (->
  CHANNEL_SELECTOR_ID = 'channel_selector'
  selector = $('#' + CHANNEL_SELECTOR_ID)
  selector.fadeIn() if selector.find('option').size() > 1
  getId: ->
    $('#' + CHANNEL_SELECTOR_ID).val()
)()

window.audio = (->
  audioElem = $('audio:first')
  audioObj = audioElem.get(0)
  AUDIO_CONTENT_TYPE = 'audio/mpeg'
  if typeof audioObj.canPlayType isnt 'function' or not audioObj.canPlayType(AUDIO_CONTENT_TYPE)
    audiojs.events.ready ->
      as = audiojs.createAll()

    alert 'ごめんなさい. 現在お使いのブラウザでは視聴できないです. もう少々お待ち下さい. Google Chromeだといいかも'
  play: (src, callback) ->
    audioElem.attr('src', src).bind 'ended', ->
      audioElem.unbind 'ended'
      callback()
)()

(->
  LOADING_IMG_ID = 'loadingimg'
  TEXT_DISPLAY_ID = 'textdisplay'
  PLAY_BTN_ID = 'play_btn'
  WEBRIC_URL_MAX_LENGTH = 1000
  READ_TEXT_MAX_LENGTH = 100
  LOAD_INTERVAL_MILLIS = 3000
  QUEUE_SIZE = 3

  queue = []
  exec = (t) ->
    target = t
    unless target
      if queue and queue.length > 0
        target = queue.shift()
      else
        loadData exec
        return
    if target.text
      $('#' + TEXT_DISPLAY_ID).slideUp('fast').text(target.text).slideDown('fast')
      # . が含まれるとWEBrickがrouting errorを起こす場合があるようなので回避
      encodedText = encodeURIComponent(target.text.replace(/\./g, ' '))
      encodedText = encodeURIComponent(target.text.substring(0, READ_TEXT_MAX_LENGTH)) if encodedText.length > WEBRIC_URL_MAX_LENGTH
      audio.play '/voices/' + encodedText, ->
        exec queue.shift()

      linkDisplay.add(target.links) if target.links
    else if target.video
      $('#' + video.ID).slideDown()
      video.play target.video[0].url, ->
        # TODO ここでplayerを非表示にすると再生用の関数等も消えてしまう
        # $('#' + video.ID).slideUp();
        exec queue.shift()
    else
      exec queue.shift()

  channelId = null
  prevStoryHash = null
  loadData = (callback) ->
    $('#' + LOADING_IMG_ID).show()
    $.get '/channels/' + channelId, (data) ->
      if data.metadata.hash is prevStoryHash
        # 2回連続で同じstoryを再生しないためのチェック機構
        loadData callback if typeof callback is 'function'
      else
        queue = queue.concat(data.contents)
        prevStoryHash = data.metadata.hash
        $('#' + LOADING_IMG_ID).hide()
        callback() if typeof callback is 'function'

  $('#' + PLAY_BTN_ID).click ->
    channelId = channelSelector.getId()
    if channelId
      setInterval (->
        loadData() if queue.length < QUEUE_SIZE
      ), LOAD_INTERVAL_MILLIS
      exec()
    else
      alert '番組を選んで下さい'
)()