# WorkoutPlanner

App iOS (Swift Playgrounds / `.swiftpm`) lista para compilar en **Codemagic** y subir a **TestFlight**.

## Identificadores (reutilizan el equipo Apple de Somnus)

| Qué | Valor |
| --- | --- |
| Bundle ID | `live.workoutplanner.app` |
| Team ID | `757NQ675N5` |
| Codemagic ASC key | `somnus_asc_key` (misma que Somnus) |

## Una sola vez en Apple / Codemagic

1. En [Apple Developer → Identifiers](https://developer.apple.com/account/resources/identifiers/list) crea el App ID **`live.workoutplanner.app`**.
2. En [App Store Connect](https://appstoreconnect.apple.com/) crea la app con ese bundle.
3. En Codemagic:
   - Conecta este repo (GitHub `ytmness`).
   - Asegúrate de que la integración **`somnus_asc_key`** esté activa.
   - Crea el grupo de variables **`workoutplanner_ios`** y, cuando tengas el id numérico de la app en ASC, añade `APP_STORE_APPLE_ID=<id>`.
4. Dispara el workflow **WorkoutPlanner iOS · TestFlight** (push a `main` o tag `ios-v*`).

## Local

- Swift Playgrounds / Xcode: abre la carpeta raíz (`Package.swift` apunta a `App/`).
- CI (Codemagic): genera `WorkoutPlanner.xcodeproj` desde `App/` con XcodeGen e inyecta iconos con `actool` antes de subir a TestFlight.
