// open a single window
var win = Ti.UI.createWindow({
	backgroundColor:'white'
});

var onesignal = require('com.williamrijksen.onesignal');

var scroll = Ti.UI.createScrollView({
	layout: 'vertical',
	top: 50
});
win.add(scroll);

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
		setTimeout(function () {
			var tags = JSON.parse(e.results);
			alert(tags.length);
		}, 2500);
   });
});
scroll.add(getTags);

var getIds = Ti.UI.createButton({
  title:'Get player ID',
  width:Ti.UI.FILL,
  height:40,
  color:'black',
  opacity:0.8,
  backgroundColor:'transparent',
  top:10
});

getIds.addEventListener('click',function(e){
	onesignal.idsAvailable(function(e) {
      //pushToken will be nil if the user did not accept push notifications
		alert(e);
   });
});
scroll.add(getIds);

var postNotificationButton = Ti.UI.createButton({
  title:'Send a notification',
  width:Ti.UI.FILL,
  height:40,
  color:'black',
  opacity:0.8,
  backgroundColor:'transparent',
  top:10
});

postNotificationButton.addEventListener('click',function(e){
	onesignal.postNotification({
		message:'Titanium test message',
		playerIds:["00000000-0000-0000-0000-000000000000"]
	});
});
scroll.add(postNotificationButton);


onesignal.addEventListener("notificationOpened", function(evt) {
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

onesignal.addEventListener("notificationReceived", function(evt) {
    alert(' ***** Received! ' + JSON.stringify(evt));
});

win.open();
