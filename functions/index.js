const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotification = functions.https.onCall(async (data, context) => {
  const targetUserId = data.targetUserId;
  const message = data.message;

  const userDoc = await admin.firestore()
      .collection("users").doc(targetUserId).get();
  const fcmToken = userDoc.data().fcmToken;

  if (!fcmToken) {
    throw new functions
        .https.HttpsError("failed-precondition", "FCM token not found");
  }

  const payload = {
    notification: {
      title: "New Notification",
      body: message,
    },
    token: fcmToken,
  };

  try {
    await admin.messaging().send(payload);
    return {success: true};
  } catch (error) {
    console.error("Error sending notification:", error);
    throw new functions
        .https.HttpsError("unknown", "Failed to send notification");
  }
});
