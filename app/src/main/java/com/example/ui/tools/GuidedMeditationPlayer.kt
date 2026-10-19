package com.example.ui.tools

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.ChevronLeft
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.GraphicEq
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Replay
import androidx.compose.material.icons.filled.SelfImprovement
import androidx.compose.material.icons.filled.Spa
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay

data class MeditationScript(
    val id: String,
    val title: String,
    val category: String,
    val durationText: String,
    val steps: List<MeditationStep>
)

data class MeditationStep(
    val title: String,
    val narration: String,
    val durationSeconds: Int
)

val sampleMeditations = listOf(
    MeditationScript(
        id = "lugar_seguro",
        title = "O Lugar Seguro (Regulação Emocional)",
        category = "Trauma & Estresse",
        durationText = "4 minutos",
        steps = listOf(
            MeditationStep(
                title = "1. Chegada e Postura",
                narration = "Feche suavemente os olhos ou mantenha o olhar relaxado para baixo. Deixe os ombros caírem e sinta os pés apoiados no chão.",
                durationSeconds = 15
            ),
            MeditationStep(
                title = "2. Respiração Âncora",
                narration = "Faça três respirações profundas. Inspire pelo nariz sentindo o ar fresco e solte o ar pela boca lentamente com um suspiro de alívio.",
                durationSeconds = 20
            ),
            MeditationStep(
                title = "3. Construindo seu Refúgio",
                narration = "Imagine agora um lugar onde você se sinta completamente calmo(a), seguro(a) e protegido(a). Pode ser uma praia, uma floresta, um quarto acolhedor ou um jardim.",
                durationSeconds = 30
            ),
            MeditationStep(
                title = "4. Detalhes Sensoriais",
                narration = "Observe as cores ao seu redor. A temperatura agradável do ar na sua pele. A luz suave e a tranquilidade deste espaço que é unicamente seu.",
                durationSeconds = 30
            ),
            MeditationStep(
                title = "5. Ancoragem Corporal",
                narration = "Leve a mão ao peito ou ao abdômen. Lembre-se: este refúgio vive dentro de você e você pode retornar a ele sempre que o mundo externo parecer agitado.",
                durationSeconds = 25
            ),
            MeditationStep(
                title = "6. Retorno Suave",
                narration = "Comece a movimentar os dedos das mãos e dos pés devagar. Abra os olhos suavemente e leve consigo essa sensação de paz.",
                durationSeconds = 15
            )
        )
    ),
    MeditationScript(
        id = "relax_muscular",
        title = "Relaxamento Muscular Progressivo",
        category = "Alívio de Tensão",
        durationText = "3 minutos",
        steps = listOf(
            MeditationStep(
                title = "1. Preparação",
                narration = "Acomode-se confortavelmente. Vamos contrair e depois relaxar grupos musculares para liberar o estresse acumulado no corpo.",
                durationSeconds = 15
            ),
            MeditationStep(
                title = "2. Ombros e Pescoço",
                narration = "Puxe os ombros para cima em direção às orelhas... segure a tensão por 4 segundos... agora SOLTE completamente. Sinta a diferença do peso aliviado.",
                durationSeconds = 20
            ),
            MeditationStep(
                title = "3. Punhos e Braços",
                narration = "Feche as mãos com força formando punhos firmes... sinta a contração no antebraço... e agora RELAXE. Abra as palmas e sinta o calor nas pontas dos dedos.",
                durationSeconds = 20
            ),
            MeditationStep(
                title = "4. Rosto e Mandíbula",
                narration = "Aperte levemente a mandíbula e enrugue a testa... e SOLTE. Deixe os lábios entreabertos e a língua repousar solta na boca.",
                durationSeconds = 20
            ),
            MeditationStep(
                title = "5. Integração Corporal",
                narration = "Sinta todo o seu corpo agora mais pesado e relaxado. Permita-se descansar nessa sensação de calma física.",
                durationSeconds = 25
            )
        )
    ),
    MeditationScript(
        id = "autocompaixao",
        title = "Pausa de Autocompaixão",
        category = "Autoestima & Culpa",
        durationText = "3 minutos",
        steps = listOf(
            MeditationStep(
                title = "1. Reconhecendo o Momento Difícil",
                narration = "Diga a si mesmo(a) em silêncio: 'Este é um momento de sofrimento ou cansaço. É normal se sentir assim diante de tantas pressões.'",
                durationSeconds = 20
            ),
            MeditationStep(
                title = "2. Humanidade Compartilhada",
                narration = "Lembre-se de que lutar e ter dias difíceis faz parte da experiência humana de todos nós. Você não está sozinho(a) nessa jornada.",
                durationSeconds = 25
            ),
            MeditationStep(
                title = "3. Bondade Consigo Mesmo",
                narration = "Coloque uma mão carinhosa sobre o coração. Diga mentalmente: 'Que eu possa ser gentil comigo hoje. Que eu possa me dar a paciência que preciso.'",
                durationSeconds = 25
            )
        )
    )
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GuidedMeditationScreen(
    onBack: () -> Unit
) {
    var selectedMeditationIndex by remember { mutableIntStateOf(0) }
    val meditation = sampleMeditations[selectedMeditationIndex]

    var currentStepIndex by remember { mutableIntStateOf(0) }
    var isPlaying by remember { mutableStateOf(false) }
    var secondsElapsedInStep by remember { mutableIntStateOf(0) }

    val currentStep = meditation.steps[currentStepIndex]
    val stepDuration = currentStep.durationSeconds

    // Pulsação suave durante reprodução
    val infiniteTransition = rememberInfiniteTransition(label = "pulse")
    val pulseAlpha by infiniteTransition.animateFloat(
        initialValue = 0.3f,
        targetValue = 0.8f,
        animationSpec = infiniteRepeatable(
            animation = tween(2000, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulseAlpha"
    )

    LaunchedEffect(isPlaying, currentStepIndex, selectedMeditationIndex) {
        if (!isPlaying) return@LaunchedEffect

        while (isPlaying) {
            delay(1000L)
            secondsElapsedInStep++
            if (secondsElapsedInStep >= stepDuration) {
                if (currentStepIndex < meditation.steps.size - 1) {
                    currentStepIndex++
                    secondsElapsedInStep = 0
                } else {
                    isPlaying = false
                    secondsElapsedInStep = stepDuration
                }
            }
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Meditação Guiada Clínica", fontWeight = FontWeight.Bold) },
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
            // Seletor de Meditações
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                sampleMeditations.forEachIndexed { idx, item ->
                    FilterChip(
                        selected = idx == selectedMeditationIndex,
                        onClick = {
                            selectedMeditationIndex = idx
                            currentStepIndex = 0
                            secondsElapsedInStep = 0
                            isPlaying = false
                        },
                        label = { Text(item.title.substringBefore(" ("), fontSize = 11.sp) }
                    )
                }
            }

            // Card Principal do Player
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(20.dp),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.35f)
                ),
                elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
            ) {
                Column(
                    modifier = Modifier.padding(20.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .size(110.dp)
                            .clip(CircleShape)
                            .background(
                                MaterialTheme.colorScheme.primary.copy(
                                    alpha = if (isPlaying) pulseAlpha else 0.2f
                                )
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.Spa,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.primary,
                            modifier = Modifier.size(54.dp)
                        )
                    }

                    Text(
                        text = meditation.title,
                        style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.Bold),
                        color = MaterialTheme.colorScheme.onSurface,
                        textAlign = TextAlign.Center
                    )

                    Text(
                        text = "${meditation.category} • ${meditation.durationText}",
                        style = MaterialTheme.typography.labelMedium,
                        color = MaterialTheme.colorScheme.primary
                    )

                    // Progresso do passo atual
                    Column(modifier = Modifier.fillMaxWidth()) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text(
                                text = "Passo ${currentStepIndex + 1} de ${meditation.steps.size}",
                                style = MaterialTheme.typography.labelSmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Text(
                                text = "${secondsElapsedInStep}s / ${stepDuration}s",
                                style = MaterialTheme.typography.labelSmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                        Spacer(modifier = Modifier.height(4.dp))
                        val progress = if (stepDuration > 0) secondsElapsedInStep.toFloat() / stepDuration.toFloat() else 0f
                        LinearProgressIndicator(
                            progress = { progress.coerceIn(0f, 1f) },
                            modifier = Modifier.fillMaxWidth().height(6.dp).clip(RoundedCornerShape(3.dp)),
                            color = MaterialTheme.colorScheme.primary
                        )
                    }

                    // Card de Narração do Passo
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(12.dp),
                        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
                    ) {
                        Column(modifier = Modifier.padding(16.dp)) {
                            Text(
                                text = currentStep.title,
                                style = MaterialTheme.typography.titleSmall.copy(fontWeight = FontWeight.Bold),
                                color = MaterialTheme.colorScheme.primary
                            )
                            Spacer(modifier = Modifier.height(8.dp))
                            Text(
                                text = currentStep.narration,
                                style = MaterialTheme.typography.bodyMedium.copy(lineHeight = 22.sp),
                                color = MaterialTheme.colorScheme.onSurface
                            )
                        }
                    }

                    // Controles de Reprodução
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(16.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        IconButton(
                            onClick = {
                                if (currentStepIndex > 0) {
                                    currentStepIndex--
                                    secondsElapsedInStep = 0
                                }
                            },
                            enabled = currentStepIndex > 0
                        ) {
                            Icon(Icons.Default.ChevronLeft, contentDescription = "Passo anterior", modifier = Modifier.size(32.dp))
                        }

                        Button(
                            onClick = { isPlaying = !isPlaying },
                            shape = CircleShape,
                            modifier = Modifier.size(64.dp).testTag("meditation_play_pause_button")
                        ) {
                            Icon(
                                imageVector = if (isPlaying) Icons.Default.Pause else Icons.Default.PlayArrow,
                                contentDescription = if (isPlaying) "Pausar" else "Reproduzir",
                                modifier = Modifier.size(32.dp)
                            )
                        }

                        IconButton(
                            onClick = {
                                if (currentStepIndex < meditation.steps.size - 1) {
                                    currentStepIndex++
                                    secondsElapsedInStep = 0
                                }
                            },
                            enabled = currentStepIndex < meditation.steps.size - 1
                        ) {
                            Icon(Icons.Default.ChevronRight, contentDescription = "Próximo passo", modifier = Modifier.size(32.dp))
                        }
                    }

                    OutlinedButton(
                        onClick = {
                            isPlaying = false
                            currentStepIndex = 0
                            secondsElapsedInStep = 0
                        },
                        shape = RoundedCornerShape(10.dp)
                    ) {
                        Icon(Icons.Default.Replay, contentDescription = null, modifier = Modifier.size(16.dp))
                        Spacer(modifier = Modifier.width(6.dp))
                        Text("Reiniciar Meditação", fontSize = 12.sp)
                    }
                }
            }

            // Dica de aplicação clínica
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            ) {
                Column(modifier = Modifier.padding(14.dp)) {
                    Text(
                        text = "💡 Sugestão para o Psicólogo:",
                        style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold),
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = "Você pode reproduzir ou ler esta sequência em voz suave nos primeiros 5 minutos de acolhimento ou nos minutos finais para estabilização após a sessão.",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        }
    }
}
