config = Object.freeze(
  LOAD_INTERVAL_MILLIS: 3000
  QUEUE_SIZE: 3
  WEBRIC_URL_MAX_SIZE: 1000
  READ_TEXT_MAX_SIZE: 100
  LINK_TEXT_MAX_SIZE: 50
  VIDEO_WIDTH: 425
  VIDEO_HEIGHT: 356
  VIDEO_FLASH_VERSION: '8'
  AUDIO_CONTENT_TYPE: 'audio/mpeg'
)

@view =
  videoPlayer: (->
    PLAYER_ID = 'mychannelVideoplayer'
    onFinish = null

    elem = $('#videoplayer')

    show: ->
      elem.slideDown()

    play: (url, callback) ->
      player = document.getElementById(PLAYER_ID)
      targetUrl = url + '?enablejsapi=1&playerapiid=ytplayer'
      if player
        player.loadVideoByUrl(targetUrl)
      else
        params = allowScriptAccess: 'always'
        atts = id: PLAYER_ID
        id = 'videoplayerTarget'
        onFinish = callback
        swfobject.embedSWF(targetUrl, id, config.VIDEO_WIDTH, config.VIDEO_HEIGHT, config.VIDEO_FLASH_VERSION, null, null, params, atts)

    onReady: ->
      player = document.getElementById(PLAYER_ID)
      player.addEventListener('onStateChange', (state) ->
        onFinish() if state is 0
      )
      player.playVideo()
  )()

  audioPlayer: (->
    elem = $('audio:first')
    audioObj = elem.get(0)
    if typeof audioObj['canPlayType'] isnt 'function' or not audioObj.canPlayType(config.AUDIO_CONTENT_TYPE)
      audiojs.events.ready ->
        as = audiojs.createAll()
      alert('ごめんなさい. 現在お使いのブラウザでは視聴できないです. もう少々お待ち下さい. Google Chromeだといいかも')

    play: (src, callback) ->
      elem.attr('src', src).bind('ended', ->
        elem.unbind('ended')
        callback()
      )
  )()

  linkDisplay: (->
    elem = $('#link_display')

    add: (links) ->
      links.forEach (i) ->
        li = $('<li>')
        icon = $('<i>').addClass('icon-hand-right')
        a = $('<a>').attr(
          href: i
          target: '_blank'
        ).addClass('btn btn-link')
        text = if i.length <= config.LINK_TEXT_MAX_SIZE then i else i.substring(0, config.LINK_TEXT_MAX_SIZE) + '...'
        a.text(text)
        elem.prepend(li.append(icon).append(a))
  )()

  channelSelector: (->
    elem = $('#channel_selector')
    elem.fadeIn() if elem.find('option').size() > 1

    getId: ->
      elem.val()
  )()

  loadingImage: (->
    elem = $('#loadingimg')

    show: ->
      elem.show()
    hide: ->
      elem.hide()
  )()

  textDisplay: (->
    elem = $('#textdisplay')

    flip: (text) ->
      elem.slideUp('fast').text(text).slideDown('fast')
  )()

  playBtn: (->
    elem = $('#play_btn')

    onClick: (callback) ->
      elem.click(->
        if view.channelSelector.getId()
          callback()
        else
          alert('番組を選んで下さい')
      )
  )()

@onYouTubePlayerReady = videoPlayer.onReady

renderer = (->
  encodeForRequest = (text) ->
    # . が含まれるとWEBrickがrouting errorを起こす場合があるようなので回避
    normalizedText = text.replace(/\./g, ' ')
    encodedText = encodeURIComponent(normalizedText)
    encodedText = encodeURIComponent(normalizedText.substring(0, config.READ_TEXT_MAX_SIZE)) if encodedText.length > config.WEBRIC_URL_MAX_SIZE
    encodedText

  renderText: (target) ->
    view.textDisplay.flip(target.text)
    view.audioPlayer.play('/voices/' + encodeForRequest(target.text), ->
      executor.execNext()
    )
    view.linkDisplay.add(target.links) if target.links

  renderVideo: (target) ->
    view.videoPlayer.show()
    view.videoPlayer.play(target.video[0].url, ->
      # ここでplayerを非表示にすると再生用の関数等も消えてしまうので出しっぱなしにする
      executor.execNext()
    )
)()

executor = (->
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
    queue.length >= config.QUEUE_SIZE
)()

loadData = (->
  prevStoryHash = null

  (callback) ->
    view.loadingImage.show()
    $.get('/channels/' + view.channelSelector.getId(), (data) ->
      if data.metadata.hash is prevStoryHash
        # 2回連続で同じstoryを再生しないためのチェック機構
        loadData(callback) if typeof callback is 'function'
      else
        executor.push(data.contents)
        prevStoryHash = data.metadata.hash
        view.loadingImage.hide()
        callback() if typeof callback is 'function'
    )
)()

view.playBtn.onClick(->
  setInterval((->
    loadData() unless executor.isFilled()
  ), config.LOAD_INTERVAL_MILLIS)
  executor.exec()
)