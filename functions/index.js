const functions = require("firebase-functions");
const admin = require("firebase-admin")

var serviceAccount = require("./dbcurd-67641-firebase-adminsdk-ax50d-1114c3adf2.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://dbcurd-67641-default-rtdb.firebaseio.com"
});

exports.createCustomToken = functions.https.onRequest(async (request, response) => {
    const user = request.body;
    
    const uid = `kakao:${user.uid}`;
    const updateParams = {
        email : user.email,
        photoURL : user.photoURL,
        displayName : user.displayName,
    }

    try {
        await admin.auth().updateUser(uid, updateParams);
    } catch (e) {
        updateParams["uid"] = uid;
        await admin.auth().createUser(updateParams);   
    }

    const token = await admin.auth().createCustomToken(uid);

    response.send(token);
});