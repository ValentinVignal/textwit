import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
try {admin.initializeApp();} catch(e) {} // You do that because the admin SDK can only be initialized once.

import * as interfaces from '../../interfaces';

/**
 * This function deletes all the messages on the deletion of a chat
 */
export const _onDeleteChat = functions.firestore.document('chats/{chatId}').onDelete(async function (snapshot, context) {
    functions.logger.log('---------- Start function ----------');

    // const ref: FirebaseFirestore.DocumentReference = snapshot.ref;
    const chat = snapshot.data() as interfaces.Chat;
    // Delete the chats on the user side
    try {
        const membersQuerySnapshot = await admin.firestore().collectionGroup('user.public').where('id', '==', 'chats').where('chats', "array-contains", chat.id).get();
        for (const doc of membersQuerySnapshot.docs) {
            const data = doc.data();
            let userChats = data.chats ? data.chats as string[] : [];
            if (userChats && userChats.length) {
                userChats = userChats.filter(function(chatId) {
                    return chatId !== chat.id;
                });
                userChats.sort();
                await doc.ref.update({
                    'chats': userChats
                });
            }
        }
    } catch (err) {
        functions.logger.error(`Error when deleting the chats on the user side: ${err}`);
    }
    // Delete the pictures in it
    const folderPath: string = `chats/${chat.id}/`;
    const bucket = admin.storage().bucket();
    try {
        // await paths.deleteFolder(bucket, folderPath);
        await bucket.deleteFiles({
            prefix: folderPath
        });
    } catch (err) {
        functions.logger.log(`Error when deleting pictures of chat ${chat.id}, ${chat.name} :`, err)
    }
    // Delete all the messages
    const documentReferences: FirebaseFirestore.QuerySnapshot<FirebaseFirestore.DocumentData> = await admin.firestore().collection('chats').doc(chat.id).collection('messages').get();
    for (const documentData of documentReferences.docs) {
        try {
            await documentData.ref.delete();
        } catch (err) {
            functions.logger.error(`Error when deleting chat ${chat.id}, ${chat.name}:`, err);
        }
    };


});