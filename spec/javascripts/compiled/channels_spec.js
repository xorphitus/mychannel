(function() {

  describe('linkDisplay', function() {
    return describe('function "add"', function() {
      var linkDisplayExpr;
      linkDisplayExpr = '#link_display';
      beforeEach(function() {
        return loadFixtures('channels.html');
      });
      it('adds a link to a link display area', function() {
        var a, expected, icon, li, links;
        links = ['http://foo.com/'];
        li = $('<li>');
        icon = $('<i class="icon-hand-right">');
        a = $('<a href="' + links[0] + '" target="_blank">').addClass('btn btn-link').text(links[0]);
        expected = $('<div>').append(li.append(icon).append(a)).html();
        linkDisplay.add(links);
        return expect($(linkDisplayExpr)).toHaveHtml(expected);
      });
      it('adds 2 links to a link display area', function() {
        var a0, a1, expected, icon0, icon1, li0, li1, links;
        links = ['http://foo.com/', 'http://bar.jp/'];
        li0 = $('<li>');
        icon0 = $('<i class="icon-hand-right">');
        a0 = $('<a href="' + links[0] + '" target="_blank">').addClass('btn btn-link').text(links[0]);
        li1 = $('<li>');
        icon1 = $('<i class="icon-hand-right">');
        a1 = $('<a href="' + links[1] + '" target="_blank">').addClass('btn btn-link').text(links[1]);
        expected = $('<div>');
        li0.append(icon0).append(a0);
        li1.append(icon1).append(a1);
        expected = $('<div>').prepend(li0).prepend(li1).html();
        linkDisplay.add(links);
        return expect($(linkDisplayExpr)).toHaveHtml(expected);
      });
      return it('shortens a link text which has a too long charactors', function() {
        var a, expected, icon, li, links;
        links = ['http://foo.com/01234567890123456789012345678901234567890123456789.html'];
        li = $('<li>');
        icon = $('<i class="icon-hand-right">');
        a = $('<a href="' + links[0] + '" target="_blank">').addClass('btn btn-link').text(links[0].substring(0, 50) + '...');
        expected = $('<div>').append(li.append(icon).append(a)).html();
        linkDisplay.add(links);
        return expect($(linkDisplayExpr)).toHaveHtml(expected);
      });
    });
  });

  describe('channelSelector', function() {
    var channelSelectorExpr;
    channelSelectorExpr = '#channel_selector';
    beforeEach(function() {
      return loadFixtures('channels.html');
    });
    return describe('getId', function() {
      it('returns the only channel id when it has only one option', function() {
        $(channelSelectorExpr).append('<option value="foo">');
        return expect(channelSelector.getId()).toBe('foo');
      });
      return it('returns the chosen channel id when it has more than one option', function() {
        $(channelSelectorExpr).append('<option value="a">').append('<option value="b" selected>').append('<option value="c">');
        return expect(channelSelector.getId()).toBe('b');
      });
    });
  });

}).call(this);
