package com.example.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext

private val DarkColorScheme = darkColorScheme(
    primary = BemTeViYellowDarkPrimary,
    onPrimary = BemTeViYellowDarkOnPrimary,
    primaryContainer = BemTeViYellowDarkPrimaryContainer,
    onPrimaryContainer = BemTeViYellowDarkOnPrimaryContainer,
    secondary = BemTeViOliveDarkSecondary,
    onSecondary = BemTeViOliveDarkOnSecondary,
    secondaryContainer = BemTeViOliveDarkSecondaryContainer,
    onSecondaryContainer = BemTeViOliveDarkOnSecondaryContainer,
    tertiary = BemTeViCharcoalDarkTertiary,
    onTertiary = BemTeViCharcoalDarkOnTertiary,
    tertiaryContainer = BemTeViCharcoalDarkTertiaryContainer,
    onTertiaryContainer = BemTeViCharcoalDarkOnTertiaryContainer,
    background = BemTeViDarkBackground,
    onBackground = BemTeViDarkOnBackground,
    surface = BemTeViDarkSurface,
    onSurface = BemTeViDarkOnSurface,
    surfaceVariant = BemTeViDarkSurfaceVariant,
    onSurfaceVariant = BemTeViDarkOnSurfaceVariant
)

private val LightColorScheme = lightColorScheme(
    primary = BemTeViYellowPrimary,
    onPrimary = BemTeViYellowOnPrimary,
    primaryContainer = BemTeViYellowPrimaryContainer,
    onPrimaryContainer = BemTeViYellowOnPrimaryContainer,
    secondary = BemTeViOliveSecondary,
    onSecondary = BemTeViOliveOnSecondary,
    secondaryContainer = BemTeViOliveSecondaryContainer,
    onSecondaryContainer = BemTeViOliveOnSecondaryContainer,
    tertiary = BemTeViCharcoalTertiary,
    onTertiary = BemTeViCharcoalOnTertiary,
    tertiaryContainer = BemTeViCharcoalTertiaryContainer,
    onTertiaryContainer = BemTeViCharcoalOnTertiaryContainer,
    background = BemTeViBackground,
    onBackground = BemTeViOnBackground,
    surface = BemTeViSurface,
    onSurface = BemTeViOnSurface,
    surfaceVariant = BemTeViSurfaceVariant,
    onSurfaceVariant = BemTeViOnSurfaceVariant
)

@Composable
fun BemTeVerTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = false, // Preserve beautiful Bem-te-vi branding
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }
        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}

// Backward compatibility aliases
@Composable
fun PsicoSocialTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit
) = BemTeVerTheme(darkTheme = darkTheme, dynamicColor = dynamicColor, content = content)

@Composable
fun MyApplicationTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = true,
    content: @Composable () -> Unit
) = BemTeVerTheme(darkTheme = darkTheme, dynamicColor = false, content = content)
