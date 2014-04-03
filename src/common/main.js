function Resonance() {
    var self = this;
    kango.ui.browserButton.addEventListener(kango.ui.browserButton.event.COMMAND, function() {
        self._onCommand();
    });
}

Resonance.prototype = {

    _onCommand: function() {
        kango.browser.tabs.create({url: 'https://github.com/centime/resonance'});
    }
};

var extension = new Resonance();