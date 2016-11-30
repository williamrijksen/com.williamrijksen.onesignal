// open a single window
var win = Ti.UI.createWindow({
	backgroundColor:'white'
});

var onesignal = require('com.williamrijksen.onesignal');

var addTag = Ti.UI.createButton({
  title:'Add a tag',
  color:'black',
  opacity:0.8,
  backgroundColor:'transparent',
  top:60
});
addTag.addEventListener('click',function(e){
   onesignal.sendTag({key:'tag1', value:true});
   alert('Tag added');
});
win.add(addTag);

// ANDROID ONLY!
onesignal.addEventListener("OneSignalNotificationOpened",function(evt){
   if(evt){
      var title = '';
      var content = '';
      var data = {};

      if(evt.title){
         title = evt.title;
      }

      if(evt.body){
         content = evt.body;
      }

      if(evt.additionalData){
         data = JSON.parse(evt.additionalData);
      }

      alert("Notification opened! title: " + title + ', content: ' + content + ', data: ' + evt.additionalData);
      console.log('evt: ' + data.email + ' :: ' + data.age);
   }
});

// ANDROID ONLY!
onesignal.addEventListener("OneSignalNotificationReceived",function(evt){
   console.log(' ***** Received! ' + JSON.stringify(evt));
});

win.open();
