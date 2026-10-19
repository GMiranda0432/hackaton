package com.example.ui.patients

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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
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
import com.example.data.model.Patient
import com.example.data.repository.PsicoSocialRepository
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PatientsScreen(
    currentUserId: String,
    repository: PsicoSocialRepository,
    onPatientClick: (Patient) -> Unit,
    onScheduleForPatient: (Patient) -> Unit
) {
    val coroutineScope = rememberCoroutineScope()
    val patientsFlow = remember(currentUserId) { repository.observePatients(currentUserId) }
    val patients by patientsFlow.collectAsState(initial = null)

    var searchQuery by remember { mutableStateOf("") }
    var selectedFilter by remember { mutableStateOf("Todos") }
    var showAddDialog by remember { mutableStateOf(false) }

    val filteredList = (patients ?: emptyList()).filter { patient ->
        val matchesSearch = patient.fullName.contains(searchQuery, ignoreCase = true) ||
                patient.initialComplaint.contains(searchQuery, ignoreCase = true) ||
                patient.phone.contains(searchQuery)
        val matchesFilter = when (selectedFilter) {
            "Ativos" -> patient.status.contains("Ativo", ignoreCase = true) || patient.status.contains("EM_ATENDIMENTO", ignoreCase = true)
            "Social/Gratuito" -> patient.socialFeeCategory.contains("Gratuito", ignoreCase = true) || patient.socialFeeCategory.contains("Social", ignoreCase = true)
            "Em Alta" -> patient.status.contains("Alta", ignoreCase = true) || patient.status.contains("FINALIZADO", ignoreCase = true)
            else -> true
        }
        matchesSearch && matchesFilter
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            text = "Bem-te-ver • Pacientes",
                            style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.Bold)
                        )
                        Text(
                            text = "${patients?.size ?: 0} acolhidos cadastrados no consultório",
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
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
                modifier = Modifier.testTag("add_patient_fab")
            ) {
                Icon(Icons.Default.Add, contentDescription = "Cadastrar Novo Paciente")
            }
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            OutlinedTextField(
                value = searchQuery,
                onValueChange = { searchQuery = it },
                placeholder = { Text("Buscar por nome, telefone ou queixa...") },
                leadingIcon = { Icon(Icons.Default.Search, contentDescription = null) },
                trailingIcon = {
                    if (searchQuery.isNotEmpty()) {
                        IconButton(onClick = { searchQuery = "" }) {
                            Icon(Icons.Default.Clear, contentDescription = "Limpar busca")
                        }
                    }
                },
                singleLine = true,
                shape = RoundedCornerShape(14.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 8.dp)
                    .testTag("patient_search_input")
            )

            LazyRow(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 4.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                val filters = listOf("Todos", "Ativos", "Social/Gratuito", "Em Alta")
                items(filters) { filter ->
                    FilterChip(
                        selected = selectedFilter == filter,
                        onClick = { selectedFilter = filter },
                        label = { Text(filter) },
                        modifier = Modifier.testTag("filter_$filter")
                    )
                }
            }

            Spacer(modifier = Modifier.height(6.dp))

            if (patients == null) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = MaterialTheme.colorScheme.primary)
                }
            } else if (filteredList.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(32.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        Surface(
                            shape = CircleShape,
                            color = MaterialTheme.colorScheme.primaryContainer,
                            modifier = Modifier.size(72.dp)
                        ) {
                            Box(contentAlignment = Alignment.Center) {
                                Icon(
                                    imageVector = Icons.Default.Person,
                                    contentDescription = null,
                                    tint = MaterialTheme.colorScheme.primary,
                                    modifier = Modifier.size(40.dp)
                                )
                            }
                        }
                        Spacer(modifier = Modifier.height(16.dp))
                        Text(
                            text = if (searchQuery.isNotEmpty()) "Nenhum paciente encontrado" else "Nenhum paciente cadastrado ainda",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(modifier = Modifier.height(6.dp))
                        Text(
                            text = "Cadastre acolhidos para vincular questionários clínicos (PHQ-9 / GAD-7) e fazer anotações diárias de progresso.",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            textAlign = androidx.compose.ui.text.style.TextAlign.Center
                        )
                        Spacer(modifier = Modifier.height(18.dp))
                        Button(
                            onClick = { showAddDialog = true },
                            shape = RoundedCornerShape(12.dp),
                            modifier = Modifier.testTag("empty_state_add_button")
                        ) {
                            Icon(Icons.Default.Add, contentDescription = null)
                            Spacer(modifier = Modifier.width(6.dp))
                            Text("Cadastrar Paciente Agora")
                        }
                    }
                }
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    verticalArrangement = Arrangement.spacedBy(10.dp),
                    contentPadding = androidx.compose.foundation.layout.PaddingValues(16.dp)
                ) {
                    items(filteredList, key = { it.id }) { patient ->
                        PatientCard(
                            patient = patient,
                            onClick = { onPatientClick(patient) },
                            onSchedule = { onScheduleForPatient(patient) }
                        )
                    }
                }
            }
        }
    }

    if (showAddDialog) {
        PatientFormDialog(
            patientToEdit = null,
            onDismiss = { showAddDialog = false },
            onSave = { newPatient ->
                coroutineScope.launch {
                    repository.createPatient(newPatient)
                    showAddDialog = false
                }
            }
        )
    }
}

@Composable
fun PatientCard(
    patient: Patient,
    onClick: () -> Unit,
    onSchedule: () -> Unit
) {
    Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .testTag("patient_card_${patient.id}")
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Iniciais do paciente
                val initials = "${patient.firstName.take(1)}${patient.lastName.take(1)}".uppercase()
                Box(
                    modifier = Modifier
                        .size(46.dp)
                        .clip(CircleShape)
                        .background(MaterialTheme.colorScheme.primaryContainer),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = initials.ifEmpty { "P" },
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onPrimaryContainer,
                        fontSize = 17.sp
                    )
                }

                Spacer(modifier = Modifier.width(12.dp))

                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = patient.fullName,
                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    Text(
                        text = if (patient.age > 0) "${patient.age} anos" else "Idade não informada",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }

                Surface(
                    shape = RoundedCornerShape(8.dp),
                    color = MaterialTheme.colorScheme.secondaryContainer
                ) {
                    Text(
                        text = patient.feeLabel,
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSecondaryContainer,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                    )
                }
            }

            if (patient.initialComplaint.isNotEmpty()) {
                Spacer(modifier = Modifier.height(10.dp))
                Text(
                    text = patient.initialComplaint,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 2
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                if (patient.phone.isNotEmpty()) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.Phone,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.primary,
                            modifier = Modifier.size(15.dp)
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = patient.phone,
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.outline
                        )
                    }
                } else {
                    Spacer(modifier = Modifier.width(1.dp))
                }

                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    OutlinedButton(
                        onClick = onSchedule,
                        shape = RoundedCornerShape(10.dp),
                        modifier = Modifier.height(34.dp)
                    ) {
                        Icon(Icons.Default.CalendarMonth, contentDescription = null, modifier = Modifier.size(14.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text("Agendar", fontSize = 12.sp)
                    }

                    Button(
                        onClick = onClick,
                        shape = RoundedCornerShape(10.dp),
                        modifier = Modifier.height(34.dp)
                    ) {
                        Text("Prontuário & Notas", fontSize = 12.sp)
                    }
                }
            }
        }
    }
}

@Composable
fun PatientFormDialog(
    patientToEdit: Patient?,
    onDismiss: () -> Unit,
    onSave: (Patient) -> Unit
) {
    var firstName by remember { mutableStateOf(patientToEdit?.firstName ?: "") }
    var lastName by remember { mutableStateOf(patientToEdit?.lastName ?: "") }
    var ageText by remember { mutableStateOf(if (patientToEdit != null && patientToEdit.age > 0) patientToEdit.age.toString() else "") }
    var phone by remember { mutableStateOf(patientToEdit?.phone ?: "") }
    var socialFeeCategory by remember { mutableStateOf(patientToEdit?.socialFeeCategory ?: "Gratuito / Social") }
    var initialComplaint by remember { mutableStateOf(patientToEdit?.initialComplaint ?: "") }
    var emergencyContact by remember { mutableStateOf(patientToEdit?.emergencyContact ?: "") }
    var status by remember { mutableStateOf(patientToEdit?.status ?: "Ativo") }

    var isSaving by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    AlertDialog(
        onDismissRequest = { if (!isSaving) onDismiss() },
        title = {
            Column {
                Text(
                    text = if (patientToEdit == null) "Novo Paciente / Contato" else "Editar Paciente",
                    fontWeight = FontWeight.Bold,
                    fontSize = 20.sp
                )
                Text(
                    text = "Preencha os dados do acolhido para o prontuário",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        },
        text = {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
                    .padding(vertical = 4.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                // Nome
                OutlinedTextField(
                    value = firstName,
                    onValueChange = {
                        firstName = it
                        errorMessage = null
                    },
                    label = { Text("Nome *") },
                    placeholder = { Text("Ex: Maria, Carlos...") },
                    singleLine = true,
                    modifier = Modifier
                        .fillMaxWidth()
                        .testTag("input_patient_firstname")
                )

                // Sobrenome
                OutlinedTextField(
                    value = lastName,
                    onValueChange = {
                        lastName = it
                        errorMessage = null
                    },
                    label = { Text("Sobrenome *") },
                    placeholder = { Text("Ex: da Silva, Souza...") },
                    singleLine = true,
                    modifier = Modifier
                        .fillMaxWidth()
                        .testTag("input_patient_lastname")
                )

                // Idade e Telefone lado a lado
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    OutlinedTextField(
                        value = ageText,
                        onValueChange = {
                            ageText = it.filter { ch -> ch.isDigit() }
                            errorMessage = null
                        },
                        label = { Text("Idade *") },
                        placeholder = { Text("Ex: 28") },
                        singleLine = true,
                        modifier = Modifier
                            .weight(0.4f)
                            .testTag("input_patient_age")
                    )

                    OutlinedTextField(
                        value = phone,
                        onValueChange = { phone = it },
                        label = { Text("WhatsApp / Contato") },
                        placeholder = { Text("(XX) XXXXX-XXXX") },
                        singleLine = true,
                        modifier = Modifier
                            .weight(0.6f)
                            .testTag("input_patient_phone")
                    )
                }

                // Tipo de Atendimento - Simples e legível
                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(
                        text = "Tipo de Atendimento:",
                        style = MaterialTheme.typography.labelMedium,
                        fontWeight = FontWeight.SemiBold
                    )
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        val feeOptions = listOf(
                            "Gratuito / Social",
                            "Valor Simbólico",
                            "Particular"
                        )
                        feeOptions.forEach { option ->
                            val selected = socialFeeCategory.contains(option.split(" ").first(), ignoreCase = true)
                            FilterChip(
                                selected = selected,
                                onClick = { socialFeeCategory = option },
                                label = { Text(option, fontSize = 11.sp) },
                                colors = FilterChipDefaults.filterChipColors(
                                    selectedContainerColor = MaterialTheme.colorScheme.primaryContainer,
                                    selectedLabelColor = MaterialTheme.colorScheme.onPrimaryContainer
                                )
                            )
                        }
                    }
                }

                // Motivo da Procura / Queixa Inicial
                OutlinedTextField(
                    value = initialComplaint,
                    onValueChange = { initialComplaint = it },
                    label = { Text("Motivo da Procura / Queixa Inicial") },
                    placeholder = { Text("Ex: Relatos de ansiedade, sobrecarga no trabalho ou sintomas depressivos...") },
                    maxLines = 3,
                    modifier = Modifier
                        .fillMaxWidth()
                        .testTag("input_patient_complaint")
                )

                // Contato de Emergência (Opcional)
                OutlinedTextField(
                    value = emergencyContact,
                    onValueChange = { emergencyContact = it },
                    label = { Text("Contato de Apoio / Emergência (Opcional)") },
                    placeholder = { Text("Ex: Familiar ou amigo - (XX) 99999-9999") },
                    singleLine = true,
                    modifier = Modifier
                        .fillMaxWidth()
                        .testTag("input_patient_emergency")
                )

                if (errorMessage != null) {
                    Text(
                        text = errorMessage ?: "",
                        color = MaterialTheme.colorScheme.error,
                        style = MaterialTheme.typography.bodySmall,
                        fontWeight = FontWeight.Medium
                    )
                }
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    val age = ageText.toIntOrNull() ?: 0
                    if (firstName.isBlank()) {
                        errorMessage = "Por favor, informe o nome do paciente."
                        return@Button
                    }
                    if (lastName.isBlank()) {
                        errorMessage = "Por favor, informe o sobrenome do paciente."
                        return@Button
                    }
                    if (age <= 0 || age > 130) {
                        errorMessage = "Por favor, informe uma idade válida (ex: 25)."
                        return@Button
                    }

                    isSaving = true
                    errorMessage = null

                    onSave(
                        Patient(
                            id = patientToEdit?.id ?: "",
                            userId = patientToEdit?.userId ?: "",
                            firstName = firstName.trim(),
                            lastName = lastName.trim(),
                            age = age,
                            phone = phone.trim(),
                            socialFeeCategory = socialFeeCategory,
                            initialComplaint = initialComplaint.trim(),
                            emergencyContact = emergencyContact.trim(),
                            status = status,
                            createdAt = patientToEdit?.createdAt
                        )
                    )
                },
                enabled = !isSaving,
                modifier = Modifier.testTag("submit_patient_button")
            ) {
                if (isSaving) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(16.dp),
                        color = MaterialTheme.colorScheme.onPrimary
                    )
                } else {
                    Text("Salvar Paciente")
                }
            }
        },
        dismissButton = {
            TextButton(
                onClick = onDismiss,
                enabled = !isSaving
            ) {
                Text("Cancelar")
            }
        }
    )
}
