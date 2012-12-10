describe 'view', ->
  describe 'linkDisplay', ->
    describe 'function "add"', ->
      beforeEach(->
        @linkDisplayExpr = '#link_display'
        loadFixtures('channels.html')
      )

      it 'adds a link to a link display area', ->
        links = ['http://foo.com/']
        li = $('<li>')
        icon = $('<i class="icon-hand-right">')
        a = $('<a href="' + links[0] + '" target="_blank">')
          .addClass('btn btn-link').text(links[0])
        expected = $('<div>').append(li.append(icon).append(a)).html()
        view.linkDisplay.add(links)
        expect($(@linkDisplayExpr)).toHaveHtml(expected)

      it 'adds 2 links to a link display area', ->
        links = ['http://foo.com/', 'http://bar.jp/']
        li0 = $('<li>')
        icon0 = $('<i class="icon-hand-right">')
        a0 = $('<a href="' + links[0] + '" target="_blank">')
          .addClass('btn btn-link').text(links[0])
        li1 = $('<li>')
        icon1 = $('<i class="icon-hand-right">')
        a1 = $('<a href="' + links[1] + '" target="_blank">')
          .addClass('btn btn-link').text(links[1])
        li0.append(icon0).append(a0)
        li1.append(icon1).append(a1)
        expected = $('<div>').prepend(li0).prepend(li1).html()
        view.linkDisplay.add(links)
        expect($(@linkDisplayExpr)).toHaveHtml(expected)

      it 'shortens a link text which has a too long charactors', ->
        links = ['http://foo.com/01234567890123456789012345678901234567890123456789.html']
        li = $('<li>')
        icon = $('<i class="icon-hand-right">')
        a = $('<a href="' + links[0] + '" target="_blank">')
          .addClass('btn btn-link').text(links[0].substring(0, 50) + '...')
        expected = $('<div>').append(li.append(icon).append(a)).html()
        view.linkDisplay.add(links)
        expect($(@linkDisplayExpr)).toHaveHtml(expected)

  describe 'channelSelector', ->
    beforeEach(->
      @channelSelectorExpr = '#channel_selector'
      loadFixtures('channels.html')
    )

    describe 'getId', ->
      it 'returns the only channel id when it has only one option', ->
        $(@channelSelectorExpr).append('<option value="foo" selected>')
        expect(view.channelSelector.getId()).toBe 'foo'

      it 'returns the chosen channel id when it has more than one option', ->
        $(@channelSelectorExpr)
          .append('<option value="a">')
          .append('<option value="b" selected>')
          .append('<option value="c">')
        expect(view.channelSelector.getId()).toBe 'b'

  # TODO 何故かfixtureを読み込んでも<audio>のDOMが作られない様子
  xdescribe 'audioPlayer', ->
    beforeEach(->
      loadFixtures('channels.html')
    )

    describe 'play', ->
      it 'sets a sound source', ->
        input = 'hoge'
        audio.play input
        expect($('audio:first').attr('src')).toBe input

      it 'sets an callback called when the player finished playing a sound', ->
        value = false
        audio.play 'hoge', ->
          value = true
        expect(value).toBeTruthy()

describe 'renderer', ->
  describe 'renderText', ->
    beforeEach(->
      spyOn(view.textDisplay, 'flip')
      spyOn(view.audioPlayer, 'play')
      spyOn(view.linkDisplay, 'add')
    )

    it 'plays voice and displays texts and links', ->
      renderer.renderText(text: 'TEXT', links: ['a', 'b'])
      expect(view.textDisplay.flip).toHaveBeenCalled()
      expect(view.audioPlayer.play).toHaveBeenCalled()
      expect(view.linkDisplay.add).toHaveBeenCalled()

  describe 'renderVideo', ->
    beforeEach(->
      spyOn(view.videoPlayer, 'play')
    )

    it 'plays video', ->
      renderer.renderVideo(video: ['v'])
      expect(view.videoPlayer.play).toHaveBeenCalled()

describe 'executor', ->
  beforeEach(->
    spyOn(renderer, 'renderText')
    spyOn(renderer, 'renderVideo')
    spyOn(executor, 'loadData')
  )

  it 'is not filled when it has no data', ->
    expect(executor.isFilled()).toBeFalsy()

  it 'is filled when it many data', ->
    executor.push([1, 2, 3])
    expect(executor.isFilled()).toBeTruthy()

  it 'calles "loadData" when it has no data', ->
    executor.exec()
    expect(executor.loadData).toHaveBeenCalled()

  it 'calles "renderText" when it has data about texts ', ->
    executor.push([text: 'TEXT'])
    executor.exec()
    expect(renderer.renderText).toHaveBeenCalled()

  it 'calles "renderVideo" when it has data about videos ', ->
    executor.push([video: 'VIDEO'])
    executor.exec()
    expect(renderer.renderVideo).toHaveBeenCalled()
