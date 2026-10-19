package com.example.ui.tools

import androidx.compose.animation.core.animateFloatAsState
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
import androidx.compose.material.icons.filled.Air
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.SelfImprovement
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay

enum class BreathingTechnique(val title: String, val inhale: Int, val hold1: Int, val exhale: Int, val hold2: Int, val desc: String) {
    BOX("Box Breathing (4-4-4-4)", 4, 4, 4, 4, "Técnica usada para foco e desaceleração do sistema nervoso."),
    FOUR_SEVEN_EIGHT("Respiração 4-7-8", 4, 7, 8, 0, "Potente ansiolítico natural que desacelera os batimentos cardíacos."),
    CALM("Respiração Calmante (4-6)", 4, 0, 6, 0, "Exalação prolongada para relaxamento rápido em consultas.")
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BreathingExerciseScreen(onBack: () -> Unit) {
    var technique by remember { mutableStateOf(BreathingTechnique.BOX) }
    var isRunning by remember { mutableStateOf(false) }
    var currentPhase by remember { mutableStateOf("Pronto") }
    var secondsLeft by remember { mutableIntStateOf(technique.inhale) }
    var cyclesCompleted by remember { mutableIntStateOf(0) }

    val circleScale by animateFloatAsState(
        targetValue = when (currentPhase) {
            "Inspire" -> 1.0f
            "Segure" -> 1.0f
            "Expire" -> 0.45f
            "Pausa" -> 0.45f
            else -> 0.6f
        },
        animationSpec = tween(
            durationMillis = when (currentPhase) {
                "Inspire" -> technique.inhale * 1000
                "Expire" -> technique.exhale * 1000
                else -> 400
            }
        ),
        label = "breathingScale"
    )

    LaunchedEffect(isRunning, technique) {
        if (!isRunning) {
            currentPhase = "Pronto"
            secondsLeft = technique.inhale
            return@LaunchedEffect
        }

        while (isRunning) {
            currentPhase = "Inspire"
            for (s in technique.inhale downTo 1) {
                secondsLeft = s
                delay(1000L)
            }

            if (technique.hold1 > 0) {
                currentPhase = "Segure"
                for (s in technique.hold1 downTo 1) {
                    secondsLeft = s
                    delay(1000L)
                }
            }

            currentPhase = "Expire"
            for (s in technique.exhale downTo 1) {
                secondsLeft = s
                delay(1000L)
            }

            if (technique.hold2 > 0) {
                currentPhase = "Pausa"
                for (s in technique.hold2 downTo 1) {
                    secondsLeft = s
                    delay(1000L)
                }
            }

            cyclesCompleted++
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Respiração Guiada", fontWeight = FontWeight.Bold) },
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
                .padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                BreathingTechnique.entries.forEach { tech ->
                    FilterChip(
                        selected = technique == tech,
                        onClick = {
                            technique = tech
                            isRunning = false
                            currentPhase = "Pronto"
                            secondsLeft = tech.inhale
                        },
                        label = { Text(tech.title.substringBefore(" ("), fontSize = 11.sp) }
                    )
                }
            }

            Text(
                text = technique.desc,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(horizontal = 16.dp)
            )

            Box(
                modifier = Modifier
                    .size(260.dp),
                contentAlignment = Alignment.Center
            ) {
                Box(
                    modifier = Modifier
                        .size((250 * circleScale).dp)
                        .clip(CircleShape)
                        .background(MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.5f))
                )

                Box(
                    modifier = Modifier
                        .size((190 * circleScale).dp)
                        .clip(CircleShape)
                        .background(MaterialTheme.colorScheme.primary),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = if (isRunning) currentPhase else "Começar",
                            style = MaterialTheme.typography.titleLarge.copy(
                                fontWeight = FontWeight.Bold,
                                color = MaterialTheme.colorScheme.onPrimary
                            )
                        )
                        if (isRunning) {
                            Text(
                                text = "${secondsLeft}s",
                                style = MaterialTheme.typography.headlineMedium.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = MaterialTheme.colorScheme.onPrimary
                                )
                            )
                        }
                    }
                }
            }

            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(14.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(
                    text = if (isRunning) "Ciclos realizados: $cyclesCompleted" else "Encontre uma postura confortável e relaxe os ombros.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )

                Row(
                    horizontalArrangement = Arrangement.spacedBy(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    OutlinedButton(
                        onClick = {
                            isRunning = false
                            cyclesCompleted = 0
                            currentPhase = "Pronto"
                            secondsLeft = technique.inhale
                        },
                        shape = RoundedCornerShape(12.dp)
                    ) {
                        Icon(Icons.Default.Refresh, contentDescription = null, modifier = Modifier.size(18.dp))
                        Spacer(modifier = Modifier.width(6.dp))
                        Text("Reiniciar")
                    }

                    Button(
                        onClick = { isRunning = !isRunning },
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier.height(48.dp).testTag("breathing_toggle_button")
                    ) {
                        Icon(if (isRunning) Icons.Default.Pause else Icons.Default.PlayArrow, contentDescription = null)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(if (isRunning) "Pausar" else "Iniciar Treino")
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GroundingExerciseScreen(onBack: () -> Unit) {
    val steps = listOf(
        Pair("5 Coisas que você pode VER", "Olhe ao seu redor e identifique 5 objetos específicos (ex: uma caneta, a textura da parede, uma sombra, o sapato, uma janela)."),
        Pair("4 Coisas que você pode TOCAR", "Sinta o contato dos pés no chão, o tecido da sua roupa, o apoio da cadeira ou a temperatura das suas mãos."),
        Pair("3 Coisas que você pode OUVIR", "Feche os olhos por um instante e note 3 sons distantes ou próximos (um carro na rua, a respiração, o ventilador)."),
        Pair("2 Coisas que você pode CHEIRAR", "Observe o cheiro do ambiente, do seu café, do sabonete ou simplesmente do ar que entra pelas narinas."),
        Pair("1 Coisa que você pode SABOREAR", "Sinta o gosto na sua boca, beba um gole de água fresca ou mentalize uma afirmação: 'Estou seguro(a) no presente'.")
    )
    val checkedState = remember { mutableStateOf(List(5) { false }) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Técnica de Aterramento 5-4-3-2-1", fontWeight = FontWeight.Bold) },
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
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                text = "Esta técnica de ancoragem sensorial é indicada para crises de ansiedade aguda, pânico e despersonalização. Ajuda a trazer a mente de volta ao momento presente.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            steps.forEachIndexed { index, (title, desc) ->
                val isDone = checkedState.value[index]
                Card(
                    shape = RoundedCornerShape(14.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = if (isDone) MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.4f)
                        else MaterialTheme.colorScheme.surface
                    ),
                    elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(
                        modifier = Modifier.padding(16.dp),
                        verticalAlignment = Alignment.Top
                    ) {
                        IconButton(
                            onClick = {
                                val current = checkedState.value.toMutableList()
                                current[index] = !current[index]
                                checkedState.value = current
                            },
                            modifier = Modifier
                                .size(32.dp)
                                .clip(CircleShape)
                                .background(if (isDone) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.surfaceVariant)
                        ) {
                            if (isDone) {
                                Icon(Icons.Default.Check, contentDescription = null, tint = Color.White, modifier = Modifier.size(18.dp))
                            }
                        }

                        Spacer(modifier = Modifier.width(12.dp))

                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = title,
                                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                                color = if (isDone) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = desc,
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            OutlinedButton(
                onClick = { checkedState.value = List(5) { false } },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(10.dp)
            ) {
                Text("Limpar e Recomeçar Exercício")
            }
        }
    }
}
