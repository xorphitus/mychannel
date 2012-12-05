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
      text = if i.length <= LINK_TEXT_MAX_SIZE then i else i.substring(0, LINK_TEXT_MAX_SIZE) + '...'
      a.text(text)
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
  AUDIO_CONTENT_TYPE = 'audio/mpeg'

  audioElem = $('audio:first')
  audioObj = audioElem.get(0)
  if typeof audioObj.canPlayType isnt 'function' or not audioObj.canPlayType(AUDIO_CONTENT_TYPE)
    audiojs.events.ready ->
      as = audiojs.createAll()

    alert 'ごめんなさい. 現在お使いのブラウザでは視聴できないです. もう少々お待ち下さい. Google Chromeだといいかも'

  play: (src, callback) ->
    audioElem.attr('src', src).bind('ended', ->
      audioElem.unbind('ended')
      callback()
    )
)()

(->
  LOAD_INTERVAL_MILLIS = 3000
  PLAY_BTN_ID = 'play_btn'

  renderer = (->
    TEXT_DISPLAY_ID = 'textdisplay'
    WEBRIC_URL_MAX_LENGTH = 1000
    READ_TEXT_MAX_LENGTH = 100

    renderText: (target) ->
      $('#' + TEXT_DISPLAY_ID).slideUp('fast').text(target.text).slideDown('fast')
      # . が含まれるとWEBrickがrouting errorを起こす場合があるようなので回避
      text = target.text.replace(/\./g, ' ')
      encodedText = encodeURIComponent(text)
      encodedText = encodeURIComponent(text.substring(0, READ_TEXT_MAX_LENGTH)) if encodedText.length > WEBRIC_URL_MAX_LENGTH
      audio.play( '/voices/' + encodedText, ->
        executor.execNext()
      )

      linkDisplay.add(target.links) if target.links

    renderVideo: (target) ->
      $('#' + video.ID).slideDown()
      video.play(target.video[0].url, ->
        # TODO ここでplayerを非表示にすると再生用の関数等も消えてしまう
        # $('#' + video.ID).slideUp();
        executor.execNext()
      )
  )()

  # TODO このクロージャのあたりの名前がイマイチ
  executor = (->
    QUEUE_SIZE = 3
    queue = []

    exec: ->
      if queue.length > 0 then executor.execNext() else loadData(executor.exec)

    execNext: ->
      target = queue.shift()
      if target.text
        renderer.renderText(target)
      else if target.video
        renderer.renderVideo(target)
      else
        executor.execNext()

    push: (dataArray) ->
      queue = queue.concat(dataArray)

    isFilled: ->
      queue.length >= QUEUE_SIZE
  )()

  channelId = null

  loadData = (->
    LOADING_IMG_ID = 'loadingimg'
    prevStoryHash = null

    (callback) ->
      $('#' + LOADING_IMG_ID).show()
      $.get '/channels/' + channelId, (data) ->
        if data.metadata.hash is prevStoryHash
          # 2回連続で同じstoryを再生しないためのチェック機構
          loadData(callback) if typeof callback is 'function'
        else
          executor.push(data.contents)
          prevStoryHash = data.metadata.hash
          $('#' + LOADING_IMG_ID).hide()
          callback() if typeof callback is 'function'
  )()

  $('#' + PLAY_BTN_ID).click ->
    channelId = channelSelector.getId()
    if channelId
      setInterval (->
        loadData() unless executor.isFilled()
      ), LOAD_INTERVAL_MILLIS
      executor.exec()
    else
      alert('番組を選んで下さい')
)()