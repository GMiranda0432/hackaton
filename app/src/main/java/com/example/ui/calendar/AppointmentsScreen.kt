package com.example.ui.calendar

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Event
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Schedule
import androidx.compose.material.icons.filled.VideoCall
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.Appointment
import com.example.data.model.Patient
import com.example.data.repository.PsicoSocialRepository
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AppointmentsScreen(
    currentUserId: String,
    repository: PsicoSocialRepository,
    initialPreselectedPatient: Patient? = null,
    onNavigateToPatientNotes: (String) -> Unit
) {
    val coroutineScope = rememberCoroutineScope()
    val appointmentsFlow = remember(currentUserId) { repository.observeAppointments(currentUserId) }
    val appointments by appointmentsFlow.collectAsState(initial = null)

    val patientsFlow = remember(currentUserId) { repository.observePatients(currentUserId) }
    val patients by patientsFlow.collectAsState(initial = emptyList())

    val todayStr = remember { SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date()) }
    var selectedDate by remember { mutableStateOf(todayStr) }
    var filterAllDates by remember { mutableStateOf(false) }
    var showAddDialog by remember { mutableStateOf(initialPreselectedPatient != null) }

    val calendarDays = remember {
        val days = mutableListOf<Pair<String, String>>()
        val cal = Calendar.getInstance()
        val formatKey = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
        val formatDisplay = SimpleDateFormat("EEE\ndd", Locale("pt", "BR"))
        for (i in 0..13) {
            days.add(Pair(formatKey.format(cal.time), formatDisplay.format(cal.time).uppercase()))
            cal.add(Calendar.DAY_OF_YEAR, 1)
        }
        days
    }

    val displayedAppointments = (appointments ?: emptyList()).filter { apt ->
        if (filterAllDates) true else apt.date == selectedDate
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Bem-te-ver • Agenda", fontWeight = FontWeight.Bold)
                        Text(
                            text = "${appointments?.size ?: 0} sessões marcadas no total",
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                },
                actions = {
                    FilterChip(
                        selected = filterAllDates,
                        onClick = { filterAllDates = !filterAllDates },
                        label = { Text(if (filterAllDates) "Ver Dia" else "Ver Todos", fontSize = 12.sp) },
                        modifier = Modifier.padding(end = 8.dp)
                    )
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface
                )
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = { showAddDialog = true },
                containerColor = MaterialTheme.colorScheme.primary,
                contentColor = MaterialTheme.colorScheme.onPrimary,
                modifier = Modifier.testTag("add_appointment_fab")
            ) {
                Icon(Icons.Default.Add, contentDescription = "Agendar Nova Sessão")
            }
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            if (!filterAllDates) {
                LazyRow(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(MaterialTheme.colorScheme.surface)
                        .padding(horizontal = 12.dp, vertical = 8.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    items(calendarDays) { (dateKey, displayStr) ->
                        val isSelected = selectedDate == dateKey
                        val isToday = dateKey == todayStr

                        Box(
                            modifier = Modifier
                                .width(56.dp)
                                .clip(RoundedCornerShape(12.dp))
                                .background(
                                    if (isSelected) MaterialTheme.colorScheme.primary
                                    else if (isToday) MaterialTheme.colorScheme.primaryContainer
                                    else MaterialTheme.colorScheme.surfaceVariant
                                )
                                .clickable { selectedDate = dateKey }
                                .padding(vertical = 8.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = displayStr,
                                style = MaterialTheme.typography.labelSmall.copy(
                                    fontWeight = if (isSelected || isToday) FontWeight.Bold else FontWeight.Normal,
                                    fontSize = 11.sp,
                                    lineHeight = 14.sp
                                ),
                                color = if (isSelected) MaterialTheme.colorScheme.onPrimary
                                else if (isToday) MaterialTheme.colorScheme.primary
                                else MaterialTheme.colorScheme.onSurfaceVariant,
                                textAlign = androidx.compose.ui.text.style.TextAlign.Center
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(4.dp))

            if (appointments == null) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = MaterialTheme.colorScheme.primary)
                }
            } else if (displayedAppointments.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(32.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            Icons.Default.Event,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.outline,
                            modifier = Modifier.size(56.dp)
                        )
                        Spacer(modifier = Modifier.height(12.dp))
                        Text(
                            text = if (filterAllDates) "Nenhuma sessão agendada" else "Nenhum horário agendado para este dia",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.SemiBold
                        )
                        Spacer(modifier = Modifier.height(6.dp))
                        Text(
                            text = "Toque em + para agendar um horário com um dos seus acolhidos.",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    verticalArrangement = Arrangement.spacedBy(10.dp),
                    contentPadding = androidx.compose.foundation.layout.PaddingValues(16.dp)
                ) {
                    items(displayedAppointments, key = { it.id }) { appointment ->
                        AppointmentCard(
                            appointment = appointment,
                            onStatusChange = { newStatus ->
                                coroutineScope.launch {
                                    repository.updateAppointment(appointment.copy(status = newStatus))
                                }
                            },
                            onDelete = {
                                coroutineScope.launch {
                                    repository.deleteAppointment(appointment.id)
                                }
                            },
                            onOpenNotes = {
                                onNavigateToPatientNotes(appointment.patientId)
                            }
                        )
                    }
                }
            }
        }
    }

    if (showAddDialog) {
        AddAppointmentDialog(
            patients = patients ?: emptyList(),
            preselectedPatient = initialPreselectedPatient,
            defaultDate = selectedDate,
            onDismiss = { showAddDialog = false },
            onSave = { newApt ->
                coroutineScope.launch {
                    repository.createAppointment(newApt)
                    showAddDialog = false
                }
            }
        )
    }
}

@Composable
fun AppointmentCard(
    appointment: Appointment,
    onStatusChange: (String) -> Unit,
    onDelete: () -> Unit,
    onOpenNotes: () -> Unit
) {
    var showDeleteConfirm by remember { mutableStateOf(false) }

    Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        modifier = Modifier.fillMaxWidth().testTag("appointment_card_${appointment.id}")
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Surface(
                        shape = RoundedCornerShape(8.dp),
                        color = MaterialTheme.colorScheme.primaryContainer
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                        ) {
                            Icon(Icons.Default.Schedule, contentDescription = null, modifier = Modifier.size(14.dp), tint = MaterialTheme.colorScheme.primary)
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                text = "${appointment.time} (${appointment.durationMinutes}m)",
                                style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.Bold),
                                color = MaterialTheme.colorScheme.primary
                            )
                        }
                    }

                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = appointment.date,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }

                Surface(
                    shape = RoundedCornerShape(6.dp),
                    color = when (appointment.status) {
                        "Realizado" -> MaterialTheme.colorScheme.primary.copy(alpha = 0.15f)
                        "Confirmado" -> MaterialTheme.colorScheme.secondaryContainer
                        "Cancelado" -> MaterialTheme.colorScheme.error.copy(alpha = 0.15f)
                        else -> MaterialTheme.colorScheme.surfaceVariant
                    }
                ) {
                    Text(
                        text = appointment.status,
                        style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.SemiBold),
                        color = when (appointment.status) {
                            "Realizado" -> MaterialTheme.colorScheme.primary
                            "Confirmado" -> MaterialTheme.colorScheme.onSecondaryContainer
                            "Cancelado" -> MaterialTheme.colorScheme.error
                            else -> MaterialTheme.colorScheme.onSurface
                        },
                        modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Default.Person, contentDescription = null, tint = MaterialTheme.colorScheme.primary, modifier = Modifier.size(20.dp))
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = appointment.patientName,
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold)
                )
            }

            Spacer(modifier = Modifier.height(4.dp))

            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    val icon = if (appointment.modality.contains("Online", true)) Icons.Default.VideoCall else Icons.Default.LocationOn
                    Icon(icon, contentDescription = null, modifier = Modifier.size(14.dp), tint = MaterialTheme.colorScheme.outline)
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(appointment.modality, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.outline)
                }

                if (appointment.socialFee.isNotEmpty()) {
                    Text(
                        text = "•  ${appointment.socialFee}",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.secondary
                    )
                }
            }

            if (appointment.notes.isNotEmpty()) {
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = "Lembrete: ${appointment.notes}",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    if (appointment.status != "Confirmado" && appointment.status != "Realizado") {
                        OutlinedButton(
                            onClick = { onStatusChange("Confirmado") },
                            shape = RoundedCornerShape(8.dp),
                            modifier = Modifier.height(32.dp)
                        ) {
                            Text("Confirmar", fontSize = 11.sp)
                        }
                    }

                    if (appointment.status != "Realizado") {
                        Button(
                            onClick = { onStatusChange("Realizado") },
                            shape = RoundedCornerShape(8.dp),
                            modifier = Modifier.height(32.dp)
                        ) {
                            Text("Realizada", fontSize = 11.sp)
                        }
                    }

                    OutlinedButton(
                        onClick = onOpenNotes,
                        shape = RoundedCornerShape(8.dp),
                        modifier = Modifier.height(32.dp)
                    ) {
                        Text("Prontuário", fontSize = 11.sp)
                    }
                }

                IconButton(
                    onClick = { showDeleteConfirm = true },
                    modifier = Modifier.size(28.dp)
                ) {
                    Icon(Icons.Default.Delete, contentDescription = "Excluir agendamento", tint = MaterialTheme.colorScheme.outline, modifier = Modifier.size(16.dp))
                }
            }
        }
    }

    if (showDeleteConfirm) {
        AlertDialog(
            onDismissRequest = { showDeleteConfirm = false },
            title = { Text("Excluir Agendamento?") },
            text = { Text("Deseja cancelar e remover esta sessão com ${appointment.patientName}?") },
            confirmButton = {
                Button(
                    onClick = {
                        showDeleteConfirm = false
                        onDelete()
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error)
                ) {
                    Text("Excluir")
                }
            },
            dismissButton = {
                TextButton(onClick = { showDeleteConfirm = false }) { Text("Voltar") }
            }
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddAppointmentDialog(
    patients: List<Patient>,
    preselectedPatient: Patient?,
    defaultDate: String,
    onDismiss: () -> Unit,
    onSave: (Appointment) -> Unit
) {
    var selectedPatient by remember { mutableStateOf(preselectedPatient ?: patients.firstOrNull()) }
    var dateText by remember { mutableStateOf(defaultDate) }
    var timeText by remember { mutableStateOf("14:00") }
    var durationMinutes by remember { mutableStateOf(50) }
    var modality by remember { mutableStateOf("Presencial") }
    var socialFee by remember { mutableStateOf(selectedPatient?.socialFeeCategory ?: "Gratuito (Atendimento Social)") }
    var notes by remember { mutableStateOf("") }
    var isExpanded by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Agendar Sessão") },
        text = {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
                    .padding(vertical = 4.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                ExposedDropdownMenuBox(
                    expanded = isExpanded,
                    onExpandedChange = { isExpanded = !isExpanded },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    OutlinedTextField(
                        value = selectedPatient?.fullName ?: "Selecione o paciente",
                        onValueChange = {},
                        readOnly = true,
                        label = { Text("Paciente / Acolhido *") },
                        trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = isExpanded) },
                        modifier = Modifier.menuAnchor().fillMaxWidth()
                    )

                    ExposedDropdownMenu(
                        expanded = isExpanded,
                        onDismissRequest = { isExpanded = false }
                    ) {
                        patients.forEach { patient ->
                            DropdownMenuItem(
                                text = { Text("${patient.fullName} (${patient.socialFeeCategory})") },
                                onClick = {
                                    selectedPatient = patient
                                    socialFee = patient.socialFeeCategory
                                    isExpanded = false
                                }
                            )
                        }
                    }
                }

                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    OutlinedTextField(
                        value = dateText,
                        onValueChange = { dateText = it },
                        label = { Text("Data (AAAA-MM-DD)") },
                        singleLine = true,
                        modifier = Modifier.weight(1.4f).testTag("input_appointment_date")
                    )

                    OutlinedTextField(
                        value = timeText,
                        onValueChange = { timeText = it },
                        label = { Text("Horário") },
                        placeholder = { Text("14:00") },
                        singleLine = true,
                        modifier = Modifier.weight(1f).testTag("input_appointment_time")
                    )
                }

                Column {
                    Text("Modalidade de Atendimento:", style = MaterialTheme.typography.labelSmall)
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        listOf("Presencial", "Online", "Domiciliar").forEach { mod ->
                            FilterChip(
                                selected = modality == mod,
                                onClick = { modality = mod },
                                label = { Text(mod, fontSize = 12.sp) }
                            )
                        }
                    }
                }

                OutlinedTextField(
                    value = socialFee,
                    onValueChange = { socialFee = it },
                    label = { Text("Tarifa / Acordo Financeiro") },
                    placeholder = { Text("Ex: Gratuito, R$ 25, Social...") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )

                OutlinedTextField(
                    value = notes,
                    onValueChange = { notes = it },
                    label = { Text("Lembretes ou Objetivos da Sessão") },
                    maxLines = 2,
                    modifier = Modifier.fillMaxWidth()
                )

                if (errorMessage != null) {
                    Text(
                        text = errorMessage ?: "",
                        color = MaterialTheme.colorScheme.error,
                        style = MaterialTheme.typography.bodySmall
                    )
                }
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    val p = selectedPatient
                    if (p == null) {
                        errorMessage = "Selecione um paciente cadastrado."
                        return@Button
                    }
                    if (dateText.isBlank() || timeText.isBlank()) {
                        errorMessage = "Informe a data e o horário da sessão."
                        return@Button
                    }
                    onSave(
                        Appointment(
                            patientId = p.id,
                            patientName = p.fullName,
                            date = dateText.trim(),
                            time = timeText.trim(),
                            durationMinutes = durationMinutes,
                            modality = modality,
                            status = "Agendado",
                            notes = notes.trim(),
                            socialFee = socialFee.trim()
                        )
                    )
                },
                modifier = Modifier.testTag("submit_appointment_button")
            ) {
                Text("Confirmar Agendamento")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Cancelar") }
        }
    )
}
