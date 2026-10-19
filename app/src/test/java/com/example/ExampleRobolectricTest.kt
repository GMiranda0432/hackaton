package com.example

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import com.example.data.model.Appointment
import com.example.data.model.Patient
import com.example.data.model.SessionNote
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class ExampleRobolectricTest {

  @Test
  fun `read string from context`() {
    val context = ApplicationProvider.getApplicationContext<Context>()
    val appName = context.getString(R.string.app_name)
    assertEquals("PsicoSocial", appName)
  }

  @Test
  fun `patient model properties and label calculation`() {
    val patient = Patient(
      id = "p1",
      userId = "u1",
      firstName = "Ana",
      lastName = "Souza",
      age = 32,
      socialFeeCategory = "GRATUITO",
      status = "EM_ATENDIMENTO"
    )

    assertEquals("Ana Souza", patient.fullName)
    assertEquals("Gratuito (100% Social)", patient.feeLabel)
    assertEquals("Em Atendimento", patient.statusLabel)
  }

  @Test
  fun `session note and appointment model defaults`() {
    val note = SessionNote(
      patientId = "p1",
      sessionDate = "2026-10-19",
      content = "Paciente demonstrou estabilidade emocional."
    )
    val appointment = Appointment(
      patientName = "Ana Souza",
      date = "2026-10-20",
      time = "10:00",
      modality = "ONLINE"
    )

    assertEquals(1, note.sessionNumber)
    assertEquals("Online / Teleconsulta", appointment.modalityLabel)
    assertEquals("Agendado", appointment.statusLabel)
  }
}
