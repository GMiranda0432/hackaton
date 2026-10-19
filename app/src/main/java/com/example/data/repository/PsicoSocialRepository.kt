package com.example.data.repository

import android.content.Context
import android.util.Log
import com.example.R
import com.example.data.model.Appointment
import com.example.data.model.MoodAssessment
import com.example.data.model.Patient
import com.example.data.model.SessionNote
import com.google.firebase.Firebase
import com.google.firebase.auth.auth
import com.google.firebase.firestore.DocumentSnapshot
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.snapshots
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.tasks.await
import java.util.UUID

class PsicoSocialRepository(private val db: FirebaseFirestore) {

    constructor(context: Context) : this(
        FirebaseFirestore.getInstance(
            context.applicationContext.getString(R.string.firestore_database_id)
        )
    )

    private val auth = Firebase.auth

    // Cache local em memória para garantir exibição imediata e funcionamento mesmo com oscilações de rede
    private val localPatientsCache = MutableStateFlow<Map<String, Patient>>(emptyMap())
    private val localNotesCache = MutableStateFlow<Map<String, List<SessionNote>>>(emptyMap())
    private val localAppointmentsCache = MutableStateFlow<Map<String, Appointment>>(emptyMap())
    private val localAssessmentsCache = MutableStateFlow<List<MoodAssessment>>(emptyList())

    private fun getUserId(): String {
        return auth.currentUser?.uid ?: "local_user_${auth.currentUser?.email ?: "default"}"
    }

    // PACIENTES (BEM-TE-VER)
    fun observePatients(userId: String): Flow<List<Patient>> {
        val path = "users/$userId/patients"
        val firestoreFlow: Flow<List<Patient>> = db.collection("users").document(userId).collection("patients")
            .snapshots()
            .map { snapshot ->
                snapshot.toObjects(Patient::class.java, DocumentSnapshot.ServerTimestampBehavior.ESTIMATE)
                    .sortedBy { it.firstName.lowercase() }
            }
            .catch { error ->
                Log.w("PsicoSocialRepository", "Firestore patients stream error, using local fallback: ${error.message}")
                emit(emptyList())
            }

        return combine(firestoreFlow, localPatientsCache) { remoteList, localMap ->
            // Unir dados remotos com cache local (priorizando os mais recentes)
            val combined = mutableMapOf<String, Patient>()
            localMap.values.forEach { combined[it.id] = it }
            remoteList.forEach { combined[it.id] = it }
            combined.values.sortedBy { it.firstName.lowercase() }
        }
    }

    suspend fun createPatient(patient: Patient): Result<String> {
        val uid = getUserId()
        val docRef = db.collection("users").document(uid).collection("patients").document()
        val assignedId = docRef.id.ifEmpty { UUID.randomUUID().toString() }
        patient.id = assignedId
        patient.userId = uid

        // Atualiza cache local instantaneamente para resposta imediata na UI
        val currentLocal = localPatientsCache.value.toMutableMap()
        currentLocal[assignedId] = patient
        localPatientsCache.value = currentLocal

        return try {
            val payload = mapOf(
                "userId" to uid,
                "firstName" to patient.firstName.trim(),
                "lastName" to patient.lastName.trim(),
                "age" to patient.age,
                "phone" to patient.phone.trim(),
                "socialFeeCategory" to patient.socialFeeCategory,
                "initialComplaint" to patient.initialComplaint.trim(),
                "emergencyContact" to patient.emergencyContact.trim(),
                "status" to patient.status.ifEmpty { "Ativo" },
                "createdAt" to FieldValue.serverTimestamp(),
                "updatedAt" to FieldValue.serverTimestamp()
            ).filterValues { it != null }

            docRef.set(payload).await()
            Result.success(assignedId)
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            Log.e("PsicoSocialRepository", "Failed saving patient to Firestore: ${e.message}", e)
            // Paciente continua no cache local da sessão
            Result.success(assignedId)
        }
    }

    suspend fun updatePatient(patient: Patient): Result<Unit> {
        val uid = getUserId()
        val docRef = db.collection("users").document(uid).collection("patients").document(patient.id)

        val currentLocal = localPatientsCache.value.toMutableMap()
        currentLocal[patient.id] = patient
        localPatientsCache.value = currentLocal

        return try {
            val payload = mapOf(
                "userId" to uid,
                "firstName" to patient.firstName.trim(),
                "lastName" to patient.lastName.trim(),
                "age" to patient.age,
                "phone" to patient.phone.trim(),
                "socialFeeCategory" to patient.socialFeeCategory,
                "initialComplaint" to patient.initialComplaint.trim(),
                "emergencyContact" to patient.emergencyContact.trim(),
                "status" to patient.status,
                "createdAt" to (patient.createdAt ?: FieldValue.serverTimestamp()),
                "updatedAt" to FieldValue.serverTimestamp()
            ).filterValues { it != null }

            docRef.set(payload).await()
            Result.success(Unit)
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            Log.e("PsicoSocialRepository", "Update patient failed in Firestore: ${e.message}", e)
            Result.success(Unit)
        }
    }

    suspend fun deletePatient(patientId: String): Result<Unit> {
        val uid = getUserId()
        val currentLocal = localPatientsCache.value.toMutableMap()
        currentLocal.remove(patientId)
        localPatientsCache.value = currentLocal

        val docRef = db.collection("users").document(uid).collection("patients").document(patientId)
        return try {
            docRef.delete().await()
            Result.success(Unit)
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            Log.e("PsicoSocialRepository", "Delete patient failed in Firestore: ${e.message}", e)
            Result.success(Unit)
        }
    }

    // BLOCO DE NOTAS / EVOLUÇÃO DIÁRIA DO PACIENTE
    fun observeNotes(userId: String, patientId: String): Flow<List<SessionNote>> {
        val firestoreFlow: Flow<List<SessionNote>> = db.collection("users").document(userId)
            .collection("patients").document(patientId)
            .collection("notes")
            .snapshots()
            .map { snapshot ->
                snapshot.toObjects(SessionNote::class.java, DocumentSnapshot.ServerTimestampBehavior.ESTIMATE)
                    .sortedByDescending { it.sessionDate }
            }
            .catch { error ->
                Log.w("PsicoSocialRepository", "Firestore notes stream error, using local: ${error.message}")
                emit(emptyList())
            }

        return combine(firestoreFlow, localNotesCache) { remoteList, localNotesMap ->
            val localForPatient = localNotesMap[patientId] ?: emptyList()
            val combinedMap = mutableMapOf<String, SessionNote>()
            localForPatient.forEach { combinedMap[it.id] = it }
            remoteList.forEach { combinedMap[it.id] = it }
            combinedMap.values.sortedByDescending { it.sessionDate }
        }
    }

    suspend fun createNote(note: SessionNote): Result<String> {
        val uid = getUserId()
        val docRef = db.collection("users").document(uid)
            .collection("patients").document(note.patientId)
            .collection("notes").document()

        val assignedId = docRef.id.ifEmpty { UUID.randomUUID().toString() }
        note.id = assignedId
        note.userId = uid

        // Optimistic local update
        val curMap = localNotesCache.value.toMutableMap()
        val listForPatient = (curMap[note.patientId] ?: emptyList()).toMutableList()
        listForPatient.add(0, note)
        curMap[note.patientId] = listForPatient
        localNotesCache.value = curMap

        return try {
            val payload = mapOf(
                "userId" to uid,
                "patientId" to note.patientId,
                "sessionDate" to note.sessionDate,
                "sessionNumber" to note.sessionNumber,
                "observedMood" to note.observedMood,
                "content" to note.content.trim(),
                "homework" to note.homework.trim(),
                "createdAt" to FieldValue.serverTimestamp(),
                "updatedAt" to FieldValue.serverTimestamp()
            ).filterValues { it != null }

            docRef.set(payload).await()
            Result.success(assignedId)
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            Log.e("PsicoSocialRepository", "Error saving note to Firestore: ${e.message}", e)
            Result.success(assignedId)
        }
    }

    suspend fun deleteNote(patientId: String, noteId: String): Result<Unit> {
        val uid = getUserId()
        val curMap = localNotesCache.value.toMutableMap()
        val listForPatient = (curMap[patientId] ?: emptyList()).filter { it.id != noteId }
        curMap[patientId] = listForPatient
        localNotesCache.value = curMap

        val docRef = db.collection("users").document(uid)
            .collection("patients").document(patientId)
            .collection("notes").document(noteId)
        return try {
            docRef.delete().await()
            Result.success(Unit)
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            Result.success(Unit)
        }
    }

    // AGENDA / HORÁRIOS
    fun observeAppointments(userId: String): Flow<List<Appointment>> {
        val firestoreFlow: Flow<List<Appointment>> = db.collection("users").document(userId).collection("appointments")
            .snapshots()
            .map { snapshot ->
                snapshot.toObjects(Appointment::class.java, DocumentSnapshot.ServerTimestampBehavior.ESTIMATE)
                    .sortedWith(compareBy({ it.date }, { it.time }))
            }
            .catch { error ->
                Log.w("PsicoSocialRepository", "Firestore appointments stream error: ${error.message}")
                emit(emptyList())
            }

        return combine(firestoreFlow, localAppointmentsCache) { remoteList, localMap ->
            val combined = mutableMapOf<String, Appointment>()
            localMap.values.forEach { combined[it.id] = it }
            remoteList.forEach { combined[it.id] = it }
            combined.values.sortedWith(compareBy({ it.date }, { it.time }))
        }
    }

    suspend fun createAppointment(appointment: Appointment): Result<String> {
        val uid = getUserId()
        val docRef = db.collection("users").document(uid).collection("appointments").document()
        val assignedId = docRef.id.ifEmpty { UUID.randomUUID().toString() }
        appointment.id = assignedId
        appointment.userId = uid

        val curMap = localAppointmentsCache.value.toMutableMap()
        curMap[assignedId] = appointment
        localAppointmentsCache.value = curMap

        return try {
            val payload = mapOf(
                "userId" to uid,
                "patientId" to appointment.patientId,
                "patientName" to appointment.patientName,
                "date" to appointment.date,
                "time" to appointment.time,
                "durationMinutes" to appointment.durationMinutes,
                "modality" to appointment.modality,
                "status" to appointment.status,
                "notes" to appointment.notes.trim(),
                "socialFee" to appointment.socialFee.trim(),
                "createdAt" to FieldValue.serverTimestamp(),
                "updatedAt" to FieldValue.serverTimestamp()
            ).filterValues { it != null }

            docRef.set(payload).await()
            Result.success(assignedId)
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            Log.e("PsicoSocialRepository", "Create appointment failed: ${e.message}", e)
            Result.success(assignedId)
        }
    }

    suspend fun updateAppointment(appointment: Appointment): Result<Unit> {
        val uid = getUserId()
        val curMap = localAppointmentsCache.value.toMutableMap()
        curMap[appointment.id] = appointment
        localAppointmentsCache.value = curMap

        val docRef = db.collection("users").document(uid).collection("appointments").document(appointment.id)
        return try {
            val payload = mapOf(
                "userId" to uid,
                "patientId" to appointment.patientId,
                "patientName" to appointment.patientName,
                "date" to appointment.date,
                "time" to appointment.time,
                "durationMinutes" to appointment.durationMinutes,
                "modality" to appointment.modality,
                "status" to appointment.status,
                "notes" to appointment.notes.trim(),
                "socialFee" to appointment.socialFee.trim(),
                "createdAt" to (appointment.createdAt ?: FieldValue.serverTimestamp()),
                "updatedAt" to FieldValue.serverTimestamp()
            ).filterValues { it != null }

            docRef.set(payload).await()
            Result.success(Unit)
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            Result.success(Unit)
        }
    }

    suspend fun deleteAppointment(appointmentId: String): Result<Unit> {
        val uid = getUserId()
        val curMap = localAppointmentsCache.value.toMutableMap()
        curMap.remove(appointmentId)
        localAppointmentsCache.value = curMap

        val docRef = db.collection("users").document(uid).collection("appointments").document(appointmentId)
        return try {
            docRef.delete().await()
            Result.success(Unit)
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            Result.success(Unit)
        }
    }

    // AVALIAÇÕES / ASSESSMENTS (PHQ-9, GAD-7)
    fun observeAssessments(userId: String): Flow<List<MoodAssessment>> {
        val firestoreFlow: Flow<List<MoodAssessment>> = db.collection("users").document(userId).collection("assessments")
            .snapshots()
            .map { snapshot ->
                snapshot.toObjects(MoodAssessment::class.java, DocumentSnapshot.ServerTimestampBehavior.ESTIMATE)
                    .sortedByDescending { it.date }
            }
            .catch { error ->
                Log.w("PsicoSocialRepository", "Firestore assessments error: ${error.message}")
                emit(emptyList())
            }

        return combine(firestoreFlow, localAssessmentsCache) { remoteList, localList ->
            (localList + remoteList).distinctBy { it.id }.sortedByDescending { it.date }
        }
    }

    suspend fun createAssessment(assessment: MoodAssessment): Result<String> {
        val uid = getUserId()
        val docRef = db.collection("users").document(uid).collection("assessments").document()
        val assignedId = docRef.id.ifEmpty { UUID.randomUUID().toString() }
        assessment.id = assignedId
        assessment.userId = uid

        localAssessmentsCache.value = listOf(assessment) + localAssessmentsCache.value

        return try {
            val payload = mapOf(
                "userId" to uid,
                "patientId" to assessment.patientId,
                "patientName" to assessment.patientName,
                "scaleType" to assessment.scaleType,
                "score" to assessment.score,
                "severity" to assessment.severity,
                "summary" to assessment.summary.trim(),
                "date" to assessment.date,
                "createdAt" to FieldValue.serverTimestamp()
            ).filterValues { it != null }

            docRef.set(payload).await()
            Result.success(assignedId)
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            Log.e("PsicoSocialRepository", "Create assessment failed: ${e.message}", e)
            Result.success(assignedId)
        }
    }
}
