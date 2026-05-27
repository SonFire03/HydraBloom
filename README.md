# HydraBloom

HydraBloom est une application Flutter Android, locale-only, pour rappel d'hydratation.

## Fonctionnalites MVP

- Rappels locaux configurables: 30 / 45 / 60 / 120 min
- Heures silencieuses (22h -> 8h par defaut)
- Suivi quotidien (objectif, progression ml/%, compteur de verres)
- Fleur animee selon progression
- Mode chaleur manuel
- Streak local
- Badges locaux
- Historique des 7 derniers jours
- Reset jour / reset complet
- Material 3 + theme pastel girly doux

## Stack

- Flutter
- `flutter_local_notifications`
- `shared_preferences`
- `intl`
- `timezone`
- `provider`

## Arborescence

- `lib/main.dart`: bootstrap
- `lib/app.dart`: MaterialApp
- `lib/screens/*`: ecrans
- `lib/services/*`: logique metier + notifications + persistence
- `lib/models/*`: modeles
- `lib/widgets/*`: composants UI
- `lib/theme/app_theme.dart`: theme M3

## Prerequis

- Flutter SDK installe et disponible dans le PATH
- Android SDK
- Un appareil Android ou emulateur

## Lancement

1. Se placer dans le projet:
   - `cd /home/sofiane/projects/HydraBloom`
2. Si le scaffold natif Flutter n'est pas encore complet, le generer:
   - `flutter create --platforms=android .`
3. Restaurer dependances:
   - `flutter pub get`
4. Lancer l'app:
   - `flutter run`

## Permissions Android

Dans `android/app/src/main/AndroidManifest.xml`:

- `android.permission.POST_NOTIFICATIONS`
- `android.permission.VIBRATE`
- `android.permission.RECEIVE_BOOT_COMPLETED`
- `android.permission.SCHEDULE_EXACT_ALARM`

## Notes fiabilite notifications

- Autorisations demandees au demarrage (notifications + exact alarms)
- Rappels replanifies lors des changements de parametres
- Heures silencieuses respectees
- Receiver boot present pour restaurer les notifications planifiees

## Confidentialite

- Pas de backend
- Pas de compte utilisateur
- Pas de tracking
- Pas de collecte de donnees personnelles
- Donnees stockees localement (`shared_preferences`)

## TODO v2

- Widget Android de progression
- Replanification robuste sur plus de 2 jours (worker natif)
- Statistiques mensuelles
- Mascotte personnalisable
- Mode meteo auto (API)
- Localisation FR/EN complete
