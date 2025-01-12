const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cron = require("node-cron");

admin.initializeApp();

async function verificarVencimentoDespesas() {
  const db = admin.firestore();
  const usersSnapshot = await db.collection("users").get();

  for (const userDoc of usersSnapshot.docs) {
    const despesasRef = db
      .collection("users")
      .doc(userDoc.id)
      .collection("despesas");
    const now = new Date();
    const limite = new Date(now.getTime() + 5 * 24 * 60 * 60 * 1000); // 5 dias no futuro

    const despesasSnapshot = await despesasRef
      .where("vencimento", ">=", now)
      .where("vencimento", "<=", limite)
      .get();

    for (const doc of despesasSnapshot.docs) {
      const diasRestantes =
        (doc.data().vencimento.toDate() - now) / (1000 * 60 * 60 * 24);
      if (diasRestantes <= 5 && diasRestantes >= 0) {
        const payload = {
          notification: {
            title: "Vencimento Próximo",
            body: `A despesa ${doc.data().nome} vence em ${Math.round(diasRestantes)} dias`,
          },
        };

        // Enviar notificação via Firebase Cloud Messaging (FCM)
        await admin.messaging().sendToTopic(userDoc.id, payload);
      }
    }
  }
}

// Agendamento da tarefa para verificar a cada 2 horas
cron.schedule("0 */2 * * *", async () => {
  await verificarVencimentoDespesas();
  console.log("Verificação de vencimento de despesas executada a cada 2 horas.");
});

// Agendamento da tarefa para 08:00 e 23:00 no horário de Manaus (UTC-4)
cron.schedule("0 12,3 * * *", async () => {
  await verificarVencimentoDespesas();
  console.log("Verificação de vencimento de despesas executada às 08:00 e 23:00 AMT.");
});

// Exportar uma função HTTPS para teste manual
exports.verificarVencimentoDespesas = functions.https.onRequest(async (req, res) => {
  await verificarVencimentoDespesas();
  res.status(200).send("Verificação de vencimento de despesas concluída.");
});
