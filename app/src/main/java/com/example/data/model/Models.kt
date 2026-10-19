package com.example.data.model

import com.google.firebase.Timestamp
import com.google.firebase.firestore.DocumentId
import com.google.firebase.firestore.ServerTimestamp

data class Patient(
    @DocumentId
    var id: String = "",
    var userId: String = "",
    var firstName: String = "",
    var lastName: String = "",
    var age: Int = 0,
    var phone: String = "",
    var socialFeeCategory: String = "Gratuito / Social",
    var initialComplaint: String = "",
    var emergencyContact: String = "",
    var status: String = "Ativo",
    @ServerTimestamp
    var createdAt: Timestamp? = null,
    @ServerTimestamp
    var updatedAt: Timestamp? = null
) {
    val fullName: String
        get() = "$firstName $lastName".trim().ifEmpty { "Sem nome" }

    val feeLabel: String
        get() = when {
            socialFeeCategory.contains("Gratuito", ignoreCase = true) -> "Gratuito (Social)"
            socialFeeCategory.contains("Simbólico", ignoreCase = true) || socialFeeCategory.contains("Simbolico", ignoreCase = true) -> "Valor Simbólico"
            socialFeeCategory.contains("Social", ignoreCase = true) -> "Tarifa Social"
            socialFeeCategory.contains("Particular", ignoreCase = true) -> "Particular"
            else -> socialFeeCategory.ifEmpty { "Gratuito / Social" }
        }

    val statusLabel: String
        get() = when (status) {
            "EM_ATENDIMENTO", "Ativo", "ativo" -> "Em Atendimento"
            "EM_ESPERA", "Espera", "espera" -> "Fila de Espera"
            "FINALIZADO", "Alta", "alta" -> "Concluído / Alta"
            else -> status.ifEmpty { "Em Atendimento" }
        }
}

data class SessionNote(
    @DocumentId
    var id: String = "",
    var userId: String = "",
    var patientId: String = "",
    var sessionDate: String = "",
    var sessionNumber: Int = 1,
    var observedMood: String = "Estável",
    var content: String = "",
    var homework: String = "",
    @ServerTimestamp
    var createdAt: Timestamp? = null,
    @ServerTimestamp
    var updatedAt: Timestamp? = null
)

data class Appointment(
    @DocumentId
    var id: String = "",
    var userId: String = "",
    var patientId: String = "",
    var patientName: String = "",
    var date: String = "", // YYYY-MM-DD
    var time: String = "", // HH:mm
    var durationMinutes: Int = 50,
    var modality: String = "Presencial", // Presencial, Online, Domiciliar
    var status: String = "Agendado", // Agendado, Confirmado, Realizado, Cancelado
    var notes: String = "",
    var socialFee: String = "Gratuito",
    @ServerTimestamp
    var createdAt: Timestamp? = null,
    @ServerTimestamp
    var updatedAt: Timestamp? = null
) {
    val modalityLabel: String
        get() = when (modality.uppercase()) {
            "PRESENCIAL" -> "Presencial"
            "ONLINE" -> "Online / Teleconsulta"
            "DOMICILIAR" -> "Atendimento Comunitário"
            else -> modality
        }

    val statusLabel: String
        get() = when (status.uppercase()) {
            "AGENDADO" -> "Agendado"
            "CONFIRMADO" -> "Confirmado"
            "REALIZADO" -> "Realizado"
            "CANCELADO" -> "Cancelado"
            else -> status
        }
}

data class MoodAssessment(
    @DocumentId
    var id: String = "",
    var userId: String = "",
    var patientId: String = "",
    var patientName: String = "",
    var scaleType: String = "PHQ-9",
    var score: Int = 0,
    var severity: String = "Mínima",
    var summary: String = "",
    var date: String = "",
    @ServerTimestamp
    var createdAt: Timestamp? = null
)
