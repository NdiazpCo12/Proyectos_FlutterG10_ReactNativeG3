# Peer Assessment App -- React Native

```text
 ╔══════════════════════════════════════════════════╗
 ║  Grupo 3 /// Proyecto Final -- React Native     ║
 ║--------------------------------------------------║
 ║  Nelson Diaz                                     ║
 ║  Presly Romero                                   ║
 ╚══════════════════════════════════════════════════╝
```

App React Native / Expo que implementa el flujo completo de **estudiante** y **profesor** para Peer Assessment, conectada a la misma base Roble del proyecto Flutter original.

---

## Funcionalidades

### Estudiante

- Login con Roble
- Consulta de cursos y grupos asignados
- Revisi0n de evaluaciones disponibles
- Calificaci0n de compa0eros de grupo
- Env0o de evaluaciones a Roble
- Consulta de resultados p0blicos por curso
- Gesti0n de perfil y cierre de sesi0n

### Profesor

- Login con Roble (rol docente/profesor/admin)
- Dashboard con resumen de cursos y evaluaciones
- Creaci0n de cursos nuevos
- Detalle de curso con importaci0n CSV de estudiantes
- Gesti0n de evaluaciones: crear, editar, eliminar
- Vista de reportes por curso y evaluaci0n
- Perfil de profesor con paridad Flutter
- Navegaci0n por tabs: Home / Cursos / Evaluaciones / Reportes / Perfil

---

## Videos

| Demo | Link |
|------|------|
| App RN (modo profe) vs App Flutter (modo estudiante) | https://youtu.be/mBmo1tZYeQE |
| Pruebas unitarias RN | https://www.youtube.com/watch?v=ksxU6OOw9yI |

---

## Stack

```text
 Expo SDK 54 + React Native 0.81
 TypeScript 5.9 (strict)
 React Navigation v7 (native-stack + bottom-tabs)
 Jest + jest-expo + React Testing Library
 AsyncStorage / Axios / PapaParse / Lucide
```

---

## Estructura

```text
src/
|-- core/
|   |-- di/                   # contenedor DI y tokens
|   |-- roble/                 # cliente HTTP compartido, modelos, mappers
|
|-- features/
    |-- auth/                 # login, roles, AuthContext
    |   |-- domain/
    |   |-- data/
    |   |-- presentation/
    |
    |-- student/              # flujo completo de estudiante
    |   |-- domain/
    |   |-- data/
    |   |-- presentation/
    |
    |-- teacher/              # flujo completo de profesor
        |-- domain/
        |-- data/
        |-- presentation/
            |-- context/
            |-- screens/
            |-- utils/
```

---

## Instalaci0n

```bash
npm install
```

## Comandos

```bash
npm start             # Expo dev server
npm run android       # Run en Android
npm run typecheck     # TypeScript strict check
npm test              # Jest -- 5 suites, 64 tests
```

## Tablas Roble

```text
 students              course_groups
 group_members         group_categories
 courses               assessments
 assessment_criteria   assessment_criterion_levels
 assessment_submissions
 assessment_peer_reviews
 assessment_scores
```

## Nota

El login usa la contrase0a por defecto del proyecto Flutter: `ThePassword!1`.
Acceso estudiante: roles `estudiante`, `student` o `alumno`.
Acceso profesor: roles `docente`, `profesor`, `teacher` o `admin`.
