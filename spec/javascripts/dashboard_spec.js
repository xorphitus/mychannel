describe('linkDisplay', function () {
    describe('function "add"', function () {
        beforeEach(function () {
            loadFixtures('dashboard.html');
        });

        it('adds a link to a link display area', function () {
            var links = ['http://foo.com/'],
                li = $('<li>'),
                icon = $('<i class="icon-hand-right">'),
                a = $('<a href="' + links[0] + '" target="_blank">')
                    .addClass('btn btn-link')
                    .text(links[0]),
                expected =$('<div>').append(li.append(icon).append(a)).html();

            linkDisplay.add(links);
            expect($('#linkdisplay')).toHaveHtml(expected);
        });

        it('adds 2 links to a link display area', function () {
            var links = ['http://foo.com/', 'http://bar.jp/'],

                li0 = $('<li>'),
                icon0 = $('<i class="icon-hand-right">'),
                a0 = $('<a href="' + links[0] + '" target="_blank">')
                    .addClass('btn btn-link')
                    .text(links[0]),

                li1 = $('<li>'),
                icon1 = $('<i class="icon-hand-right">'),
                a1 = $('<a href="' + links[1] + '" target="_blank">')
                    .addClass('btn btn-link')
                    .text(links[1]),

                expected =$('<div>');

            li0.append(icon0).append(a0);
            li1.append(icon1).append(a1);
            expected =$('<div>').prepend(li0).prepend(li1).html();

            linkDisplay.add(links);
            expect($('#linkdisplay')).toHaveHtml(expected);
        });

        it('shortens a link text which has a too long charactors', function () {
            var links = ['http://foo.com/01234567890123456789012345678901234567890123456789.html'],
                li = $('<li>'),
                icon = $('<i class="icon-hand-right">'),
                a = $('<a href="' + links[0] + '" target="_blank">')
                    .addClass('btn btn-link')
                    .text(links[0].substring(0, 50) + '...'),
                expected =$('<div>').append(li.append(icon).append(a)).html();

            linkDisplay.add(links);
            expect($('#linkdisplay')).toHaveHtml(expected);
        });
    });
});

describe('channelSelector', function () {
    describe('init', function () {
        it('hides select box when it has only one option which has value' ,function () {
            // TODO
        });
        it('shows select box when it has more than one option which has value' ,function () {
            // TODO
        });
    });

    describe('getId', function () {
        it('returns the only channel id when it has only one option which has value' ,function () {
            // TODO
        });
    });
});