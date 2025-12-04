
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

type Expense = {
  title: string;
  amount: number;
  category: string;
  date: admin.firestore.Timestamp;
  notes?: string;
};

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

  //Expense Functions

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

//Budget Functions

export const getBudget = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new Error("Unauthorized");

  const ref = admin
    .firestore()
    .collection("users")
    .doc(uid)
    .collection("budget")
    .doc("budget");

  const doc = await ref.get();

  return doc.exists
    ? doc.data()
    : { limit: 0, totalSpent: 0, updatedAt: null }; // default
});


export const updateBudget = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new Error("Unauthorized");

  const { limit } = request.data;

  if (typeof limit !== "number") {
    throw new Error("Invalid limit value");
  }

  const db = admin.firestore();
  const budgetRef = db
    .collection("users")
    .doc(uid)
    .collection("budget")
    .doc("budget");

  // Preserve existing totalSpent value
  const budgetDoc = await budgetRef.get();
  const existingTotal = budgetDoc.exists
    ? Number(budgetDoc.data()?.totalSpent ?? 0)
    : 0;

  await budgetRef.set(
    {
      limit,
      totalSpent: existingTotal, // protected
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  return {
    success: true,
    limit,
    totalSpent: existingTotal,
  };
});


export const recalculateBudget = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new Error("Unauthorized");

  const db = admin.firestore();

  try {
    // 1⃣ Get all expenses
    const expensesSnapshot = await db
      .collection("users")
      .doc(uid)
      .collection("expenses")
      .get();

    let totalSpent = 0;

    expensesSnapshot.forEach((doc) => {
      const data = doc.data();
      totalSpent += Number(data.amount || 0);
    });

    // 2⃣ Get existing budget to preserve limit
    const budgetRef = db
      .collection("users")
      .doc(uid)
      .collection("budget")
      .doc("budget");

    const budgetDoc = await budgetRef.get();
    const existingLimit = budgetDoc.exists
      ? Number(budgetDoc.data()?.limit ?? 0)
      : 0;

    // 3⃣ Update total spent safely
    await budgetRef.set(
      {
        limit: existingLimit,
        totalSpent,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    return {
      success: true,
      totalSpent,
      limit: existingLimit,
    };
  } catch (error) {
    console.error("Error recalculating budget:", error);
    throw new Error("Failed to recalculate budget");
  }
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


export const setBudgetLimit = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new Error("Unauthorized request");

  const { limit } = request.data;
  if (!limit || typeof limit !== "number") {
    throw new Error("Invalid limit value");
  }

  const db = admin.firestore();

  // Calculate totalSpent from expenses in the backend
  const expensesSnapshot = await db
    .collection("users")
    .doc(uid)
    .collection("expenses")
    .get();

  let totalSpent = 0;
  expensesSnapshot.forEach((doc) => {
    const data = doc.data();
    if (data.amount) totalSpent += Number(data.amount);
  });

  const budgetRef = db
    .collection("users")
    .doc(uid)
    .collection("budget")
    .doc("budget");

  await budgetRef.set(
    {
      limit,
      totalSpent,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  return { success: true, limit, totalSpent };
});


//Expense Summary Functions

export const getExpenseSummary = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new Error("Unauthorized");

  const db = admin.firestore();
  const now = new Date();

  const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

  let totalSpent = 0;
  let thisMonthSpent = 0;
  const categoryTotals: Record<string, number> = {};

  try {
    const snapshot = await db
      .collection("users")
      .doc(uid)
      .collection("expenses")
      .get();

    snapshot.forEach((doc) => {
      const data = doc.data() as Expense;  // ← FIX: Explicit Cast

      const amount = Number(data.amount || 0);
      const date = data.date?.toDate?.() ?? null; // Safe optional chaining

      totalSpent += amount;

      if (date && date >= startOfMonth) {
        thisMonthSpent += amount;
      }

      const category = data.category || "Other"; // Now safely typed
      categoryTotals[category] = (categoryTotals[category] || 0) + amount;
    });

    return {
      success: true,
      totalSpent,
      thisMonthSpent,
      categories: categoryTotals,
    };

  } catch (err) {
    console.error("Error summary:", err);
    throw new Error("Failed to fetch summary");
  }
});
