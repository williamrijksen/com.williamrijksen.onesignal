var win = Ti.UI.createWindow({
    backgroundColor:'white'
});

var onesignal = require('com.williamrijksen.onesignal');
onesignal.addEventListener("notificationOpened", onNotificationOpened);
onesignal.addEventListener("notificationReceived", onNotificationReceived);

var scroll = Ti.UI.createScrollView({
    layout: 'vertical',
    top: 50
});
win.add(scroll);

if (Ti.Platform.osname !== 'android') {
    var startModule = Ti.UI.createButton({
        title:'Start One Signal module',
        width:Ti.UI.FILL,
        height:40,
        color:'black',
        opacity:0.8,
        backgroundColor:'transparent',
        top:10
    });

    startModule.addEventListener('click',function(e){
        onesignal.setInFocusDisplayType('none');
        onesignal.promptForPushNotificationsWithUserResponse(function(resp){
            if(resp && resp.accepted){
                Ti.API.info(new Date() + ': ' + ' One Signal - User accepted iOS push notifications! Thanks =)');
            }
        });
    });
    scroll.add(startModule);
}

var addTag = Ti.UI.createButton({
    title:'Add a tag',
    width:Ti.UI.FILL,
    height:40,
    color:'black',
    opacity:0.8,
    backgroundColor:'transparent',
    top:10
});

addTag.addEventListener('click',function(e){
    onesignal.sendTag({key:'tag1', value:true});
    alert('Tag added');
});
scroll.add(addTag);

var getTags = Ti.UI.createButton({
    title:'Get all tags',
    width:Ti.UI.FILL,
    height:40,
    color:'black',
    opacity:0.8,
    backgroundColor:'transparent',
    top:10
});

getTags.addEventListener('click',function(e){
    onesignal.getTags(function(e) {
        if (!e.success) {
            alert("Error: " + e.error);
            return
        }
        alert(e.results);
    });
});
scroll.add(getTags);

function onNotificationOpened(evt) {
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
}

function onNotificationReceived(evt) {
    alert(' ***** Received! ' + JSON.stringify(evt));
}
win.open();
