const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onEventCreated = functions.firestore.document('events/{docId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
   
    if(data && data.type === 'help_request'){
      const message = {
        topic: 'community',
        notification: {
          title: 'Help requested nearby',
          body: 'Someone requested help. Check map for details.'
        },
      };
      await admin.messaging().send(message);
    }
    
    return null;
  });
