const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require("@firebase/rules-unit-testing");
const { test, before, after, beforeEach } = require("node:test");
const fs = require("node:fs");

let testEnv;
const PROJECT_ID = "demo-no-project";

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: fs.readFileSync("firestore.rules", "utf8"),
      host: "127.0.0.1",
      port: 8085,
    },
  });
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

after(async () => {
  if (testEnv) {
    await testEnv.cleanup();
  }
});

test("Denies unauthenticated access to patients", async () => {
  const unauthedDb = testEnv.unauthenticatedContext().firestore();
  await assertFails(unauthedDb.doc("users/alice/patients/p1").get());
});

test("Allows psychologist to create and read their own patient record", async () => {
  const aliceDb = testEnv.authenticatedContext("alice").firestore();
  const patientRef = aliceDb.doc("users/alice/patients/p1");

  await assertSucceeds(
    patientRef.set({
      userId: "alice",
      firstName: "Maria",
      lastName: "Silva",
      age: 28,
      status: "EM_ATENDIMENTO",
    })
  );

  await assertSucceeds(patientRef.get());
});

test("Denies Bob from accessing Alice's patient record", async () => {
  const aliceDb = testEnv.authenticatedContext("alice").firestore();
  await aliceDb.doc("users/alice/patients/p1").set({
    userId: "alice",
    firstName: "Maria",
    lastName: "Silva",
    status: "EM_ATENDIMENTO",
  });

  const bobDb = testEnv.authenticatedContext("bob").firestore();
  await assertFails(bobDb.doc("users/alice/patients/p1").get());
});

test("Allows psychologist to create session notes in patient record", async () => {
  const aliceDb = testEnv.authenticatedContext("alice").firestore();
  const noteRef = aliceDb.doc("users/alice/patients/p1/notes/n1");

  await assertSucceeds(
    noteRef.set({
      userId: "alice",
      patientId: "p1",
      sessionDate: "2026-10-19",
      content: "Paciente relatou melhora significativa com exercícios de respiração.",
    })
  );
});

test("Allows appointments to be scheduled by authenticated psychologist", async () => {
  const aliceDb = testEnv.authenticatedContext("alice").firestore();
  const apptRef = aliceDb.doc("users/alice/appointments/a1");

  await assertSucceeds(
    apptRef.set({
      userId: "alice",
      patientName: "Maria Silva",
      date: "2026-10-20",
      time: "14:00",
      status: "AGENDADO",
    })
  );
});
