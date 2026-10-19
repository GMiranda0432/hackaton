package com.example.ui.tools

import androidx.compose.foundation.background
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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.AssignmentTurnedIn
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Info
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.MoodAssessment
import com.example.data.model.Patient
import com.example.data.repository.PsicoSocialRepository
import com.google.firebase.Firebase
import com.google.firebase.auth.auth
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

data class ClinicalQuestion(
    val id: Int,
    val prompt: String
)

val phq9Questions = listOf(
    ClinicalQuestion(1, "Pouco interesse ou prazer em fazer as coisas?"),
    ClinicalQuestion(2, "Sentir-se para baixo, deprimido(a) ou sem perspectiva?"),
    ClinicalQuestion(3, "Dificuldade para pegar no sono, acordar no meio da noite ou dormir demais?"),
    ClinicalQuestion(4, "Sentir-se cansado(a) ou com pouca energia?"),
    ClinicalQuestion(5, "Falta de apetite ou comer em excesso?"),
    ClinicalQuestion(6, "Sentir-se mal consigo mesmo(a) — achar que é um fracasso ou decepcionou a família?"),
    ClinicalQuestion(7, "Dificuldade de concentração (ex: ao ler jornal ou assistir TV)?"),
    ClinicalQuestion(8, "Mover-se ou falar tão devagar que outras pessoas notaram, ou o oposto (muito agitado/inquieto)?"),
    ClinicalQuestion(9, "Pensamentos de que seria melhor estar morto(a) ou de se ferir de alguma maneira?")
)

val gad7Questions = listOf(
    ClinicalQuestion(1, "Sentir-se nervoso(a), ansioso(a) ou muito tenso(a)?"),
    ClinicalQuestion(2, "Incapacidade de impedir ou controlar as preocupações?"),
    ClinicalQuestion(3, "Preocupar-se excessivamente com diferentes assuntos?"),
    ClinicalQuestion(4, "Dificuldade para relaxar?"),
    ClinicalQuestion(5, "Ficar tão inquieto(a) que é difícil permanecer sentado(a)?"),
    ClinicalQuestion(6, "Ficar facilmente irritado(a) ou chateado(a)?"),
    ClinicalQuestion(7, "Sentir medo como se algo terrível fosse acontecer?")
)

val responseOptions = listOf(
    Pair("Nenhum dia", 0),
    Pair("Vários dias", 1),
    Pair("Mais da metade dos dias", 2),
    Pair("Quase todos os dias", 3)
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ClinicalScalesScreen(
    onBack: () -> Unit,
    preselectedPatient: Patient? = null
) {
    val context = LocalContext.current
    val repository = remember { PsicoSocialRepository(context) }
    val userId = Firebase.auth.currentUser?.uid ?: ""
    val patients by repository.observePatients(userId).collectAsState(initial = emptyList())
    val coroutineScope = rememberCoroutineScope()

    var selectedScale by remember { mutableStateOf("PHQ-9") } // PHQ-9 or GAD-7
    var selectedPatient by remember(preselectedPatient) { mutableStateOf(preselectedPatient) }
    var patientDropdownExpanded by remember { mutableStateOf(false) }

    val currentQuestions = if (selectedScale == "PHQ-9") phq9Questions else gad7Questions
    val answers = remember(selectedScale) { mutableStateOf(IntArray(currentQuestions.size) { 0 }) }
    var isSubmitted by remember { mutableStateOf(false) }
    var isSaving by remember { mutableStateOf(false) }
    var saveSuccessMessage by remember { mutableStateOf<String?>(null) }

    val totalScore = answers.value.sum()
    val severity = if (selectedScale == "PHQ-9") {
        when {
            totalScore <= 4 -> "Depressão Mínima / Ausente (0-4)"
            totalScore <= 9 -> "Depressão Leve (5-9)"
            totalScore <= 14 -> "Depressão Moderada (10-14)"
            totalScore <= 19 -> "Depressão Moderadamente Grave (15-19)"
            else -> "Depressão Grave (20-27)"
        }
    } else {
        when {
            totalScore <= 4 -> "Ansiedade Mínima (0-4)"
            totalScore <= 9 -> "Ansiedade Leve (5-9)"
            totalScore <= 14 -> "Ansiedade Moderada (10-14)"
            else -> "Ansiedade Grave (15-21)"
        }
    }

    val clinicalAdvice = if (selectedScale == "PHQ-9") {
        when {
            totalScore <= 4 -> "Sintomatologia mínima. Recomenda-se acompanhamento de rotina e medidas preventivas de saúde mental."
            totalScore <= 9 -> "Sintomas leves. Indicada psicoeducação, técnicas de relaxamento e monitoramento quinzenal."
            totalScore <= 14 -> "Sintomas moderados. Aconselha-se intervenção psicoterápica estruturada e avaliação médica social se persistir."
            else -> "Sintomas severos. Alta prioridade clínica. Recomenda-se encaminhamento à rede pública (CAPS / UBS) e plano de contingência."
        }
    } else {
        when {
            totalScore <= 4 -> "Sem sinais expressivos de ansiedade patológica."
            totalScore <= 9 -> "Ansiedade leve. Fortalecer treino respiratório e higiene do sono."
            totalScore <= 14 -> "Ansiedade moderada. Recomenda-se reestruturação cognitiva e técnicas de ancoragem sensorial (5-4-3-2-1)."
            else -> "Ansiedade grave. Indicada intervenção psicoterapêutica intensiva e avaliação médica multidisciplinar."
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Avaliação Clínica de Humor", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Voltar")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = MaterialTheme.colorScheme.surface)
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Seletor de Escala
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                FilterChip(
                    selected = selectedScale == "PHQ-9",
                    onClick = {
                        selectedScale = "PHQ-9"
                        isSubmitted = false
                        saveSuccessMessage = null
                    },
                    label = { Text("PHQ-9 (Depressão)") }
                )
                FilterChip(
                    selected = selectedScale == "GAD-7",
                    onClick = {
                        selectedScale = "GAD-7"
                        isSubmitted = false
                        saveSuccessMessage = null
                    },
                    label = { Text("GAD-7 (Ansiedade)") }
                )
            }

            // Seleção de Paciente
            ExposedDropdownMenuBox(
                expanded = patientDropdownExpanded,
                onExpandedChange = { patientDropdownExpanded = !patientDropdownExpanded }
            ) {
                OutlinedTextField(
                    value = selectedPatient?.fullName ?: "Aplicação Geral / Anônima",
                    onValueChange = {},
                    readOnly = true,
                    label = { Text("Vincular ao Paciente (Opcional)") },
                    trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = patientDropdownExpanded) },
                    modifier = Modifier.fillMaxWidth().menuAnchor(),
                    shape = RoundedCornerShape(12.dp)
                )

                ExposedDropdownMenu(
                    expanded = patientDropdownExpanded,
                    onDismissRequest = { patientDropdownExpanded = false }
                ) {
                    DropdownMenuItem(
                        text = { Text("Sem vínculo (Avaliação Geral)") },
                        onClick = {
                            selectedPatient = null
                            patientDropdownExpanded = false
                        }
                    )
                    patients.forEach { p ->
                        DropdownMenuItem(
                            text = { Text("${p.fullName} (${p.feeLabel})") },
                            onClick = {
                                selectedPatient = p
                                patientDropdownExpanded = false
                            }
                        )
                    }
                }
            }

            Card(
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.4f)),
                shape = RoundedCornerShape(12.dp)
            ) {
                Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.Info, contentDescription = null, tint = MaterialTheme.colorScheme.primary)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "Instrução: Nas últimas 2 semanas, com que frequência o(a) paciente foi incomodado(a) por qualquer um dos problemas abaixo?",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onPrimaryContainer
                    )
                }
            }

            // Perguntas
            currentQuestions.forEachIndexed { qIndex, question ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(14.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                    elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                ) {
                    Column(modifier = Modifier.padding(14.dp)) {
                        Text(
                            text = "${question.id}. ${question.prompt}",
                            style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.SemiBold),
                            color = MaterialTheme.colorScheme.onSurface
                        )
                        Spacer(modifier = Modifier.height(8.dp))

                        val currentAns = answers.value.getOrElse(qIndex) { 0 }
                        responseOptions.forEach { (label, value) ->
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(vertical = 2.dp)
                            ) {
                                RadioButton(
                                    selected = currentAns == value,
                                    onClick = {
                                        val newArr = answers.value.clone()
                                        newArr[qIndex] = value
                                        answers.value = newArr
                                        isSubmitted = false
                                        saveSuccessMessage = null
                                    }
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    text = "$label (+$value)",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = if (currentAns == value) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            }
                        }
                    }
                }
            }

            // Card de Resultado
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.secondaryContainer.copy(alpha = 0.5f)
                )
            ) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text("Pontuação Total: $totalScore pts", fontWeight = FontWeight.Bold, fontSize = 16.sp)
                        Text(
                            text = severity,
                            fontWeight = FontWeight.SemiBold,
                            color = MaterialTheme.colorScheme.primary
                        )
                    }

                    Text(
                        text = clinicalAdvice,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )

                    if (saveSuccessMessage != null) {
                        Text(
                            text = saveSuccessMessage ?: "",
                            style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.Bold),
                            color = MaterialTheme.colorScheme.primary
                        )
                    }

                    Button(
                        onClick = {
                            isSaving = true
                            coroutineScope.launch {
                                val currentDate = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
                                val assessment = MoodAssessment(
                                    userId = userId,
                                    patientId = selectedPatient?.id ?: "",
                                    patientName = selectedPatient?.fullName ?: "Avaliação Geral",
                                    scaleType = selectedScale,
                                    score = totalScore,
                                    severity = severity,
                                    summary = clinicalAdvice,
                                    date = currentDate
                                )
                                val res = repository.createAssessment(assessment)
                                isSaving = false
                                if (res.isSuccess) {
                                    isSubmitted = true
                                    saveSuccessMessage = "Avaliação salva com sucesso no histórico do paciente no Firebase!"
                                } else {
                                    saveSuccessMessage = "Erro ao salvar avaliação: ${res.exceptionOrNull()?.message}"
                                }
                            }
                        },
                        enabled = !isSaving,
                        modifier = Modifier.fillMaxWidth().testTag("save_assessment_button"),
                        shape = RoundedCornerShape(10.dp)
                    ) {
                        if (isSaving) {
                            CircularProgressIndicator(modifier = Modifier.size(18.dp), color = MaterialTheme.colorScheme.onPrimary)
                        } else {
                            Icon(Icons.Default.AssignmentTurnedIn, contentDescription = null)
                            Spacer(modifier = Modifier.width(8.dp))
                            Text("Salvar Avaliação no Prontuário")
                        }
                    }
                }
            }
        }
    }
}
