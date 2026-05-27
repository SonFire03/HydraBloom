# HydraBloom

HydraBloom est une application Flutter Android de rappel d'hydratation, pensée pour rester simple, douce et 100% locale.

## Aperçu

- Rappels d'hydratation configurables (30 / 45 / 60 / 120 min)
- Heures silencieuses personnalisables
- Suivi quotidien: objectif, progression, compteur de verres
- Progression visuelle par compagnon (PNG)
- Mode chaleur
- Mode TDAH (interface plus simple)
- Streak et badges
- Historique des derniers jours
- Export / import local en JSON

## Stack technique

- Flutter (Material 3)
- `provider`
- `shared_preferences`
- `flutter_local_notifications`
- `intl`
- `timezone`

## Structure du projet

- `lib/main.dart` : bootstrap de l'app
- `lib/app.dart` : configuration `MaterialApp`
- `lib/screens/` : écrans principaux
- `lib/services/` : logique métier, notifications, persistance
- `lib/models/` : modèles
- `lib/widgets/` : composants UI
- `lib/theme/` : thème et styles

## Prérequis

- Flutter SDK installé
- Android SDK configuré
- Un appareil Android ou un émulateur

## Lancement local

```bash
cd /home/sofiane/projects/HydraBloom
flutter pub get
flutter run
```

## Qualité

```bash
flutter analyze
flutter test
```

## Screenshots

<p align="center">
  <img src="docs/screenshots/goutili.png" alt="HydraBloom - Goutili" width="30%" />
  <img src="docs/screenshots/florali.png" alt="HydraBloom - Florali" width="30%" />
  <img src="docs/screenshots/nereabelle.png" alt="HydraBloom - Nereabelle" width="30%" />
</p>

## Permissions Android

Déclarées dans `android/app/src/main/AndroidManifest.xml` :

- `android.permission.POST_NOTIFICATIONS`
- `android.permission.VIBRATE`
- `android.permission.RECEIVE_BOOT_COMPLETED`
- `android.permission.SCHEDULE_EXACT_ALARM`

## Confidentialité

HydraBloom est **local-only** :

- aucun backend
- aucun compte utilisateur
- aucun tracking
- aucune collecte de données personnelles

Les données sont stockées localement via `shared_preferences`.

## Roadmap (v2)

- Widget Android de progression
- Replanification de notifications plus robuste
- Statistiques mensuelles
- Mascotte personnalisable
- Mode météo auto (API)
- Localisation FR/EN complète

## Licence

Aucune licence définie pour le moment.
