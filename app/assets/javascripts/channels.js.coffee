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
    selector = '#videoplayer'

    show: ->
      $(selector).slideDown()

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
    selector = 'audio:first'
    audioObj = $(selector).get(0)
    if audioObj
      if typeof audioObj.canPlayType isnt 'function' or not audioObj.canPlayType(config.AUDIO_CONTENT_TYPE)
        audiojs.events.ready ->
          as = audiojs.createAll()
        alert('ごめんなさい. 現在お使いのブラウザでは視聴できないです. もう少々お待ち下さい. Google Chromeだといいかも')

    play: (src, callback) ->
      $(selector).attr('src', src).bind('ended', ->
        $(selector).unbind('ended')
        callback()
      )
  )()

  linkDisplay: (->
    selector = '#link_display'

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
        $(selector).prepend(li.append(icon).append(a))
  )()

  channelSelector: (->
    selector = '#channel_selector'

    $(selector).fadeIn() if $(selector).find('option').size() > 1

    getId: ->
      $(selector).val()
  )()

  loadingImage: (->
    selector = '#loadingimg'

    show: ->
      $(selector).show()
    hide: ->
      $(selector).hide()
  )()

  textDisplay: (->
    selector = '#textdisplay'

    flip: (text) ->
      $(selector).slideUp('fast').text(text).slideDown('fast')
  )()

  playBtn: (->
    selector = '#play_btn'

    onClick: (callback) ->
      $(selector).click(->
        if view.channelSelector.getId()
          callback()
        else
          alert('番組を選んで下さい')
      )
  )()

@onYouTubePlayerReady = view.videoPlayer.onReady

@renderer = (->
  encodeForRequest = (text) ->
    # . が含まれるとWEBrickがrouting errorを起こす場合があるようなので回避
    normalizedText = text.replace(/\./g, ' ')
    encodedText = encodeURIComponent(normalizedText)
    encodedText = encodeURIComponent(normalizedText.substring(0, config.READ_TEXT_MAX_SIZE)) if encodedText.length > config.WEBRIC_URL_MAX_SIZE
    encodedText

  renderText: (target) ->
    view.textDisplay.flip(target.text)
    view.audioPlayer.play('/voices/' + encodeForRequest(target.text), ->
      executor.exec()
    )
    view.linkDisplay.add(target.links) if target.links

  renderVideo: (target) ->
    view.videoPlayer.show()
    view.videoPlayer.play(target.video[0].url, ->
      # ここでplayerを非表示にすると再生用の関数等も消えてしまうので出しっぱなしにする
      executor.exec()
    )
)()

@executor = (->
  queue = []
  prevStoryHash = null

  loadData: (callback) ->
    view.loadingImage.show()
    $.get('/channels/' + view.channelSelector.getId(), (data) ->
      if data.metadata.hash is prevStoryHash
        # 2回連続で同じstoryを再生しないためのチェック機構
        executor.loadData(callback) if typeof callback is 'function'
      else
        executor.push(data.contents)
        prevStoryHash = data.metadata.hash
        view.loadingImage.hide()
        callback() if typeof callback is 'function'
    )

  exec: ->
    if queue.length > 0
      target = queue.shift()
      if target.text
        renderer.renderText(target)
      else if target.video
        renderer.renderVideo(target)
      else
        executor.exec()
    else
      executor.loadData(executor.exec)

  push: (dataArray) ->
    queue = queue.concat(dataArray)

  isFilled: ->
    queue.length >= config.QUEUE_SIZE
)()

view.playBtn.onClick(->
  setInterval((->
    executor.loadData() unless executor.isFilled()
  ), config.LOAD_INTERVAL_MILLIS)
  executor.exec()
)