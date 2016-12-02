// open a single window
var win = Ti.UI.createWindow({
    backgroundColor: 'white'
});

var onesignal = require('com.williamrijksen.onesignal');

var addTag = Ti.UI.createButton({
    title: 'Add a tag',
    width: Ti.UI.FILL,
    height: Ti.UI.FILL,
    color: 'black',
    opacity: 0.8,
    backgroundColor: 'transparent',
    borderColor: '#4ee47f',
    top: 60
});

addTag.addEventListener('click', function(e) {
    onesignal.sendTag({
        key: 'tag1',
        value: true
    });
    alert('Tag added');
});
win.add(addTag);


onesignal.addEventListener("OneSignalNotificationOpened", function(evt) {
    alert(evt);
    if (evt) {
        var title = '';
        var content = '';
        var data = {};

        if (evt.title) {
            title = evt.title;
        }

        if (evt.body) {
            content = evt.body;
        }

        if (evt.additionalData) {
            if (Ti.Platform.osname === 'android') {
                //Android receives it as a JSON string
                data = JSON.parse(evt.additionalData);
            } else {
                data = evt.additionalData;
            }
        }

        alert("Notification opened! title: " + title + ', content: ' + content + ', data: ' + evt.additionalData);
    }
});

onesignal.addEventListener("OneSignalNotificationReceived", function(evt) {
    alert(' ***** Received! ' + JSON.stringify(evt));
});

win.open();
