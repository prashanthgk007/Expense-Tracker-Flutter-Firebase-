
import { setGlobalOptions } from "firebase-functions";
import { onRequest } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import { onDocumentCreated, onDocumentWritten } from "firebase-functions/v2/firestore";
import { onCall } from "firebase-functions/v2/https";

admin.initializeApp();

// Start writing functions
// https://firebase.google.com/docs/functions/typescript
setGlobalOptions({ maxInstances: 10 });

export const checkHealth = onRequest((req, res) => {
  logger.info("Health Check Called");
  res.send("Function is online");
});

export const sendNotification = onRequest(async (req, res) => {
  const { fcmToken, title, body } = req.body;

  const message = {
    notification: {
      title: title,
      body: body,
    },
    token: fcmToken,
  };

  try {
    const response = await admin.messaging().send(message);
    res.status(200).send({ success: true, response });
  } catch (error) {
    res.status(500).send({ success: false, error });
  }
});

export const notifyOnExpenseAdded = onDocumentCreated(
  "users/{uid}/expenses/{expenseId}",
  async (event) => {
    if (!event.data) {
      console.log("No data found in event");
      return;
    }

    const data = event.data?.data();
    const uid = event.params.uid;

    const userDoc = await admin.firestore().collection("users").doc(uid).get();
    const fcmToken = userDoc.get("fcmToken");

    await admin.messaging().send({
      notification: {
        title: "New Expense Added",
        body: `₹${data.amount} - ${data.title}`,
      },
      token: fcmToken,
    });
  });

export const getExpenses = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new Error("Unauthorized");
  }

  const snapshot = await admin
    .firestore()
    .collection("users")
    .doc(uid)
    .collection("expenses")
    .orderBy("createdAt", "desc")
    .get();

  const expenses = snapshot.docs.map(doc => {
    const data = doc.data() as {
      title: string;
      amount: number;
      category: string;
      date: admin.firestore.Timestamp;
      notes: string;
    }; // ✅ Type assertion

    return {
      id: doc.id,
      title: data.title,
      amount: data.amount,
      category: data.category,
      date: data.date.toDate().toISOString(), // Safe now
      notes: data.notes,
    };
  });

  return { expenses };
});



export const addExpense = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new Error("Unauthorized");
  }

  const { title, amount, category, date, notes } = request.data;

  const expenseRef = await admin
    .firestore()
    .collection("users")
    .doc(uid)
    .collection("expenses")
    .add({
      title,
      amount,
      category,
      date: admin.firestore.Timestamp.fromDate(new Date(date)),
      notes,
      createdAt: admin.firestore.Timestamp.now(),
    });

  return { success: true, expenseId: expenseRef.id };
});

export const updateExpense = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new Error("Unauthorized");

  const { id, title, amount, category, date, notes } = request.data;

  await admin
    .firestore()
    .collection("users")
    .doc(uid)
    .collection("expenses")
    .doc(id)
    .update({
      title,
      amount,
      category,
      date: admin.firestore.Timestamp.fromDate(new Date(date)),
      notes,
    });

  return { success: true };
});

export const deleteExpense = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new Error("Unauthorized");

  const { id } = request.data;
  await admin
    .firestore()
    .collection("users")
    .doc(uid)
    .collection("expenses")
    .doc(id)
    .delete();

  return { success: true };
});

export const updateBudgetsOnExpenseChange = onDocumentWritten(
  "users/{userId}/expenses/{expenseId}",
  async (event) => {
    const { userId } = event.params;

    const db = admin.firestore();

    const expensesRef = db.collection(`users/${userId}/expenses`);
    const budgetDocRef = db.doc(`users/${userId}/budget/budget`);

    // Fetch all expenses
    const expensesSnapshot = await expensesRef.get();

    // Calculate total spent from all expenses
    let totalSpent = 0;
    expensesSnapshot.forEach((expenseDoc) => {
      const expense = expenseDoc.data();
      totalSpent += expense.amount || 0;
    });

    // Check if budget document exists
    const budgetDoc = await budgetDocRef.get();
    
    if (budgetDoc.exists) {
      // Update existing budget with new totalSpent
      await budgetDocRef.update({
        totalSpent: totalSpent,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      console.log(`Budget updated for user ${userId}: Total spent = ${totalSpent}`);
    } else {
      // Budget doesn't exist yet - create it with totalSpent, limit will be set by user later
      await budgetDocRef.set({
        limit: 0,
        totalSpent: totalSpent,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      console.log(`Budget created for user ${userId}: Total spent = ${totalSpent}`);
    }
  }
);