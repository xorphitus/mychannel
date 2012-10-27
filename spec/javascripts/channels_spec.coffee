describe 'linkDisplay', ->
  describe 'function "add"', ->
    linkDisplayExpr = '#link_display'
    beforeEach ->
      loadFixtures 'channels.html'

    it 'adds a link to a link display area', ->
      links = ['http://foo.com/']
      li = $('<li>')
      icon = $('<i class="icon-hand-right">')
      a = $('<a href="' + links[0] + '" target="_blank">')
        .addClass('btn btn-link').text(links[0])
      expected = $('<div>').append(li.append(icon).append(a)).html()
      linkDisplay.add links
      expect($(linkDisplayExpr)).toHaveHtml expected

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
      expected = $('<div>')
      li0.append(icon0).append a0
      li1.append(icon1).append a1
      expected = $('<div>').prepend(li0).prepend(li1).html()
      linkDisplay.add links
      expect($(linkDisplayExpr)).toHaveHtml expected

    it 'shortens a link text which has a too long charactors', ->
      links = ['http://foo.com/01234567890123456789012345678901234567890123456789.html']
      li = $('<li>')
      icon = $('<i class="icon-hand-right">')
      a = $('<a href="' + links[0] + '" target="_blank">')
        .addClass('btn btn-link').text(links[0].substring(0, 50) + '...')
      expected = $('<div>').append(li.append(icon).append(a)).html()
      linkDisplay.add links
      expect($(linkDisplayExpr)).toHaveHtml expected

describe 'channelSelector', ->
  channelSelectorExpr = '#channel_selector'
  beforeEach ->
    loadFixtures 'channels.html'

  describe 'getId', ->
    it 'returns the only channel id when it has only one option', ->
      $(channelSelectorExpr).append '<option value="foo">'
      expect(channelSelector.getId()).toBe 'foo'

    it 'returns the chosen channel id when it has more than one option', ->
      $(channelSelectorExpr).append('<option value="a">').append('<option value="b" selected>').append '<option value="c">'
      expect(channelSelector.getId()).toBe 'b'

# TODO 何故かfixtureを読み込んでも<audio>のDOMが作られない様子
# describe 'audio', ->
#   beforeEach ->
#     loadFixtures 'channels.html'
#
#   describe 'play', ->
#     it 'sets a sound source', ->
#       input = 'hoge'
#       audio.play input
#       expect($('audio:first').attr('src')).toBe input
#
#     it 'sets an callback called when the player finished playing a sound', ->
#       value = false
#       audio.play 'hoge', ->
#         value = true
#       expect(value).toBe true