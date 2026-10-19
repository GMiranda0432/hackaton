package com.example.ui.tools

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
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.Air
import androidx.compose.material.icons.filled.Assignment
import androidx.compose.material.icons.filled.Psychology
import androidx.compose.material.icons.filled.SelfImprovement
import androidx.compose.material.icons.filled.Spa
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
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

enum class ActiveToolSubscreen {
    NONE,
    BREATHING,
    GROUNDING,
    MEDITATION,
    CLINICAL_SCALES
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TherapyToolsScreen(
    initialPreselectedPatient: Patient? = null,
    onClearPreselectedPatient: () -> Unit = {}
) {
    var preselectedPatient by remember(initialPreselectedPatient) { mutableStateOf(initialPreselectedPatient) }
    var activeSubscreen by remember(initialPreselectedPatient) {
        mutableStateOf(if (initialPreselectedPatient != null) ActiveToolSubscreen.CLINICAL_SCALES else ActiveToolSubscreen.NONE)
    }

    when (activeSubscreen) {
        ActiveToolSubscreen.BREATHING -> BreathingExerciseScreen(onBack = { activeSubscreen = ActiveToolSubscreen.NONE })
        ActiveToolSubscreen.GROUNDING -> GroundingExerciseScreen(onBack = { activeSubscreen = ActiveToolSubscreen.NONE })
        ActiveToolSubscreen.MEDITATION -> GuidedMeditationScreen(onBack = { activeSubscreen = ActiveToolSubscreen.NONE })
        ActiveToolSubscreen.CLINICAL_SCALES -> ClinicalScalesScreen(
            onBack = {
                activeSubscreen = ActiveToolSubscreen.NONE
                preselectedPatient = null
                onClearPreselectedPatient()
            },
            preselectedPatient = preselectedPatient
        )
        ActiveToolSubscreen.NONE -> TherapyToolsHub(
            onOpenBreathing = { activeSubscreen = ActiveToolSubscreen.BREATHING },
            onOpenGrounding = { activeSubscreen = ActiveToolSubscreen.GROUNDING },
            onOpenMeditation = { activeSubscreen = ActiveToolSubscreen.MEDITATION },
            onOpenScales = { activeSubscreen = ActiveToolSubscreen.CLINICAL_SCALES }
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TherapyToolsHub(
    onOpenBreathing: () -> Unit,
    onOpenGrounding: () -> Unit,
    onOpenMeditation: () -> Unit,
    onOpenScales: () -> Unit
) {
    val context = LocalContext.current
    val repository = remember { PsicoSocialRepository(context) }
    val userId = Firebase.auth.currentUser?.uid ?: ""
    val assessments by repository.observeAssessments(userId).collectAsState(initial = emptyList())

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Recursos Terapêuticos", fontWeight = FontWeight.Bold) },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = MaterialTheme.colorScheme.surface)
            )
        }
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            item {
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "Ferramentas práticas para usar em consulta com os pacientes ou prescrever para treino entre as sessões.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            item {
                Text(
                    text = "Técnicas de Relaxamento & Regulação",
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                    color = MaterialTheme.colorScheme.primary
                )
            }

            item {
                ToolOptionCard(
                    title = "Respiração Guiada (Box & 4-7-8)",
                    subtitle = "Ritmo visual para regulação rápida de ansiedade e desaceleração do sistema simpático.",
                    icon = Icons.Default.Air,
                    onClick = onOpenBreathing,
                    tag = "tool_breathing_card"
                )
            }

            item {
                ToolOptionCard(
                    title = "Aterramento Sensorial 5-4-3-2-1",
                    subtitle = "Técnica de ancoragem no presente indicada para crises de ansiedade aguda e pânico.",
                    icon = Icons.Default.Visibility,
                    onClick = onOpenGrounding,
                    tag = "tool_grounding_card"
                )
            }

            item {
                ToolOptionCard(
                    title = "Meditações Guiadas Clínicas",
                    subtitle = "Exercícios estruturados de Mindfulness, 'Lugar Seguro' e relaxamento muscular progressivo.",
                    icon = Icons.Default.Spa,
                    onClick = onOpenMeditation,
                    tag = "tool_meditation_card"
                )
            }

            item {
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "Instrumentos de Avaliação de Humor",
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                    color = MaterialTheme.colorScheme.primary
                )
            }

            item {
                ToolOptionCard(
                    title = "Escalas PHQ-9 e GAD-7",
                    subtitle = "Aplique questionários clínicos padronizados de depressão e ansiedade e salve no prontuário.",
                    icon = Icons.Default.Assignment,
                    onClick = onOpenScales,
                    tag = "tool_scales_card"
                )
            }

            if (assessments.isNotEmpty()) {
                item {
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = "Histórico Recente de Avaliações",
                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                        color = MaterialTheme.colorScheme.onSurface
                    )
                }

                items(assessments.take(5)) { item ->
                    RecentAssessmentCard(item)
                }
            }

            item {
                Spacer(modifier = Modifier.height(24.dp))
            }
        }
    }
}

@Composable
fun ToolOptionCard(
    title: String,
    subtitle: String,
    icon: ImageVector,
    onClick: () -> Unit,
    tag: String
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .testTag(tag),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape)
                    .background(MaterialTheme.colorScheme.primaryContainer),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.size(26.dp)
                )
            }

            Spacer(modifier = Modifier.width(14.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
                    color = MaterialTheme.colorScheme.onSurface
                )
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Icon(
                imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.outline,
                modifier = Modifier.size(20.dp)
            )
        }
    }
}

@Composable
fun RecentAssessmentCard(assessment: MoodAssessment) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f)
        )
    ) {
        Row(
            modifier = Modifier.padding(12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = "${assessment.scaleType} • ${assessment.patientName}",
                    style = MaterialTheme.typography.titleSmall.copy(fontWeight = FontWeight.Bold),
                    color = MaterialTheme.colorScheme.onSurface
                )
                Text(
                    text = "Resultado: ${assessment.score} pontos (${assessment.severity})",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.primary
                )
            }
            Text(
                text = assessment.date,
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}
