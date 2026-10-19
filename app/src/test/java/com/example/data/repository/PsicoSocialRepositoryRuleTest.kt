package com.example.data.repository

import com.example.base.FirestoreEmulatorTestBase
import com.example.data.model.Appointment
import com.example.data.model.Patient
import com.example.data.model.SessionNote
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.util.UUID

class PsicoSocialRepositoryRuleTest : FirestoreEmulatorTestBase() {

    @Test
    fun createPatient_authenticatedUser_success() = runBlocking {
        val uid = signInTestUser("psi_alice_${UUID.randomUUID()}@teste.com")
        val repository = PsicoSocialRepository(firestore)

        val patient = Patient(
            firstName = "Carlos",
            lastName = "Menezes",
            age = 29,
            phone = "11988887777",
            socialFeeCategory = "Gratuito",
            status = "Ativo"
        )

        val createResult = withTimeout(5000L) {
            repository.createPatient(patient)
        }
        assertTrue("Criar paciente deve ter sucesso", createResult.isSuccess)
        val patientId = createResult.getOrThrow()
        assertTrue(patientId.isNotEmpty())

        val list = withTimeout(5000L) {
            repository.observePatients(uid).first()
        }
        assertTrue(list.any { it.firstName == "Carlos" })
    }

    @Test
    fun createSessionNote_authenticatedUser_success() = runBlocking {
        val uid = signInTestUser("psi_notes_${UUID.randomUUID()}@teste.com")
        val repository = PsicoSocialRepository(firestore)

        val patientResult = withTimeout(5000L) {
            repository.createPatient(
                Patient(firstName = "Ana", lastName = "Clara", age = 22, status = "Ativo")
            )
        }
        val patientId = patientResult.getOrThrow()

        val note = SessionNote(
            patientId = patientId,
            sessionDate = "2026-10-20",
            sessionNumber = 1,
            observedMood = "Ansiosa",
            content = "Paciente relata ansiedade relacionada a busca de emprego e sobrecarga familiar.",
            homework = "Praticar técnica de respiração 4-7-8 duas vezes ao dia."
        )

        val noteResult = withTimeout(5000L) {
            repository.createNote(note)
        }
        assertTrue(noteResult.isSuccess)

        val notes = withTimeout(5000L) {
            repository.observeNotes(uid, patientId).first()
        }
        assertEquals(1, notes.size)
        assertEquals("Ansiosa", notes[0].observedMood)
    }

    @Test
    fun createAppointment_authenticatedUser_success() = runBlocking {
        val uid = signInTestUser("psi_app_${UUID.randomUUID()}@teste.com")
        val repository = PsicoSocialRepository(firestore)

        val appointment = Appointment(
            patientId = "pat_123",
            patientName = "João Santos",
            date = "2026-10-22",
            time = "15:00",
            durationMinutes = 50,
            modality = "Presencial",
            status = "Agendado",
            socialFee = "Tarifa Social (R$ 30)"
        )

        val result = withTimeout(5000L) {
            repository.createAppointment(appointment)
        }
        assertTrue(result.isSuccess)

        val appointments = withTimeout(5000L) {
            repository.observeAppointments(uid).first()
        }
        assertTrue(appointments.any { it.patientName == "João Santos" })
    }
}
