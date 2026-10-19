package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.People
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.SelfImprovement
import androidx.compose.material.icons.outlined.CalendarMonth
import androidx.compose.material.icons.outlined.People
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.SelfImprovement
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import com.example.data.model.Patient
import com.example.data.repository.PsicoSocialRepository
import com.example.ui.auth.AuthScreen
import com.example.ui.calendar.AppointmentsScreen
import com.example.ui.patients.PatientDetailScreen
import com.example.ui.patients.PatientsScreen
import com.example.ui.profile.ProfileScreen
import com.example.ui.theme.PsicoSocialTheme
import com.example.ui.tools.TherapyToolsScreen
import com.google.firebase.Firebase
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.auth

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            PsicoSocialTheme {
                MainAppEntry()
            }
        }
    }
}

enum class NavigationTab(
    val title: String,
    val selectedIcon: ImageVector,
    val unselectedIcon: ImageVector,
    val tag: String
) {
    PATIENTS("Pacientes", Icons.Filled.People, Icons.Outlined.People, "nav_patients"),
    CALENDAR("Agenda", Icons.Filled.CalendarMonth, Icons.Outlined.CalendarMonth, "nav_calendar"),
    TOOLS("Recursos", Icons.Filled.SelfImprovement, Icons.Outlined.SelfImprovement, "nav_tools"),
    PROFILE("Consultório", Icons.Filled.Person, Icons.Outlined.Person, "nav_profile")
}

@Composable
fun MainAppEntry() {
    val context = LocalContext.current
    var currentUser by remember { mutableStateOf<FirebaseUser?>(Firebase.auth.currentUser) }

    DisposableEffect(Unit) {
        val listener = FirebaseAuth.AuthStateListener { auth ->
            currentUser = auth.currentUser
        }
        Firebase.auth.addAuthStateListener(listener)
        onDispose {
            Firebase.auth.removeAuthStateListener(listener)
        }
    }

    val user = currentUser
    if (user == null) {
        AuthScreen(
            onAuthSuccess = {
                currentUser = Firebase.auth.currentUser
            }
        )
    } else {
        val repository = remember(user.uid) { PsicoSocialRepository(context) }
        PsicoSocialMainShell(
            currentUser = user,
            repository = repository,
            onSignOut = {
                currentUser = null
            }
        )
    }
}

@Composable
fun PsicoSocialMainShell(
    currentUser: FirebaseUser,
    repository: PsicoSocialRepository,
    onSignOut: () -> Unit
) {
    var selectedTab by remember { mutableStateOf(NavigationTab.PATIENTS) }
    var selectedPatientDetail by remember { mutableStateOf<Patient?>(null) }
    var preselectedPatientForAppointment by remember { mutableStateOf<Patient?>(null) }
    var preselectedPatientForAssessment by remember { mutableStateOf<Patient?>(null) }

    val allPatients by repository.observePatients(currentUser.uid).collectAsState(initial = emptyList())

    // If viewing patient details, BackHandler returns to list
    if (selectedPatientDetail != null) {
        BackHandler {
            selectedPatientDetail = null
        }
    }

    Scaffold(
        bottomBar = {
            if (selectedPatientDetail == null) {
                NavigationBar(
                    containerColor = MaterialTheme.colorScheme.surface,
                    contentColor = MaterialTheme.colorScheme.onSurface
                ) {
                    NavigationTab.entries.forEach { tab ->
                        val selected = selectedTab == tab
                        NavigationBarItem(
                            selected = selected,
                            onClick = {
                                selectedTab = tab
                                preselectedPatientForAppointment = null
                                preselectedPatientForAssessment = null
                            },
                            icon = {
                                Icon(
                                    imageVector = if (selected) tab.selectedIcon else tab.unselectedIcon,
                                    contentDescription = tab.title
                                )
                            },
                            label = { Text(tab.title) },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = MaterialTheme.colorScheme.primary,
                                selectedTextColor = MaterialTheme.colorScheme.primary,
                                indicatorColor = MaterialTheme.colorScheme.primaryContainer
                            ),
                            modifier = Modifier.testTag(tab.tag)
                        )
                    }
                }
            }
        }
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            if (selectedPatientDetail != null) {
                PatientDetailScreen(
                    patient = selectedPatientDetail!!,
                    currentUserId = currentUser.uid,
                    repository = repository,
                    onBack = { selectedPatientDetail = null },
                    onScheduleSession = { patient ->
                        selectedPatientDetail = null
                        preselectedPatientForAppointment = patient
                        selectedTab = NavigationTab.CALENDAR
                    },
                    onApplyQuestionnaire = { patient ->
                        selectedPatientDetail = null
                        preselectedPatientForAssessment = patient
                        selectedTab = NavigationTab.TOOLS
                    }
                )
            } else {
                when (selectedTab) {
                    NavigationTab.PATIENTS -> {
                        PatientsScreen(
                            currentUserId = currentUser.uid,
                            repository = repository,
                            onPatientClick = { patient ->
                                selectedPatientDetail = patient
                            },
                            onScheduleForPatient = { patient ->
                                preselectedPatientForAppointment = patient
                                selectedTab = NavigationTab.CALENDAR
                            }
                        )
                    }

                    NavigationTab.CALENDAR -> {
                        AppointmentsScreen(
                            currentUserId = currentUser.uid,
                            repository = repository,
                            initialPreselectedPatient = preselectedPatientForAppointment,
                            onNavigateToPatientNotes = { patientId ->
                                val found = allPatients.find { it.id == patientId }
                                if (found != null) {
                                    selectedPatientDetail = found
                                }
                            }
                        )
                    }

                    NavigationTab.TOOLS -> {
                        TherapyToolsScreen(
                            initialPreselectedPatient = preselectedPatientForAssessment,
                            onClearPreselectedPatient = { preselectedPatientForAssessment = null }
                        )
                    }

                    NavigationTab.PROFILE -> {
                        ProfileScreen(
                            onSignOut = onSignOut
                        )
                    }
                }
            }
        }
    }
}
