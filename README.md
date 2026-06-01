# Desarrollo Móvil de Aplicaciones en Flutter y React Native  
## Peer Assessment App

---

## Introducción

Este repositorio reúne dos implementaciones móviles de la aplicación **Peer Assessment App**, desarrolladas con tecnologías multiplataforma diferentes: **Flutter** y **React Native con Expo**. El propósito principal es documentar, organizar y comparar ambas versiones desde una perspectiva general de desarrollo, arquitectura y funcionamiento, dejando el análisis técnico de métricas en un informe externo enlazado dentro de este mismo README.

---

## Descripción general de la Peer Assessment App

**Peer Assessment App** es una aplicación orientada a entornos académicos que permite gestionar procesos de evaluación entre pares dentro de cursos universitarios. Su finalidad es apoyar a profesores y estudiantes en actividades colaborativas, permitiendo que los integrantes de un grupo puedan evaluar el desempeño de sus compañeros de forma estructurada.

La aplicación busca resolver una problemática común en trabajos grupales: la dificultad de identificar el aporte individual de cada estudiante cuando la calificación se asigna de manera colectiva. Para esto, el sistema permite gestionar cursos, grupos, evaluaciones, criterios de calificación, respuestas de estudiantes y resultados asociados al proceso evaluativo.

Entre sus funcionalidades principales se encuentran:

- Gestión de usuarios con roles diferenciados.
- Administración de cursos académicos.
- Organización de estudiantes por grupos.
- Creación y consulta de evaluaciones.
- Definición de criterios de evaluación.
- Calificación entre compañeros de grupo.
- Registro de respuestas y resultados.
- Consulta de resultados públicos según la configuración de la evaluación.
- Soporte para flujos de profesor y estudiante.

---

## Objetivo

El objetivo de este repositorio es centralizar dos versiones de la **Peer Assessment App**, una desarrollada en **Flutter** y otra en **React Native**, con el fin de documentar su funcionamiento general, estructura tecnológica y enfoque de implementación.

Además, este repositorio sirve como punto de referencia para incluir el informe comparativo entre ambas aplicaciones, en el cual se analizan aspectos técnicos como rendimiento, consumo de recursos, tamaño de compilación, fluidez, mantenibilidad y comportamiento general.

---

## Repositorios integrados

Este repositorio principal integra los siguientes proyectos:

| Proyecto | Tecnología | Repositorio original |
|---|---|---|
| Peer Assessment App - Flutter | Flutter / Dart | [Proyecto_Flutter_Group10](https://github.com/NdiazpCo12/Proyecto_Flutter_Group10) |
| Peer Assessment App - React Native | React Native / Expo / TypeScript | [Projecto_ReactNative_Grupo3](https://github.com/NdiazpCo12/Projecto_ReactNative_Grupo3) |

---


## Descripción de la versión Flutter

La versión desarrollada en **Flutter** representa una implementación completa de la aplicación **Peer Assessment App**, contemplando los flujos principales de profesor y estudiante.

Esta versión permite gestionar el proceso académico de evaluación entre pares desde una perspectiva integral. El profesor puede administrar cursos, organizar estudiantes, configurar evaluaciones, definir criterios y revisar resultados. Por su parte, el estudiante puede consultar sus cursos, acceder a evaluaciones disponibles, calificar a sus compañeros y visualizar resultados cuando estos se encuentren habilitados.

El proyecto Flutter se encuentra organizado dentro de la carpeta `PeerAssessment` y utiliza una estructura propia de una aplicación Flutter multiplataforma. Su desarrollo se apoya en una arquitectura orientada a la separación de responsabilidades, permitiendo organizar la lógica de presentación, dominio y acceso a datos de forma más clara.

Características principales de esta versión:

- Implementación móvil usando Flutter.
- Uso del lenguaje Dart.
- Flujo de estudiante.
- Flujo de profesor.
- Gestión de cursos.
- Gestión de grupos.
- Creación y consulta de evaluaciones.
- Evaluación entre pares.
- Visualización de resultados.
- Conexión con servicios de backend y almacenamiento.
- Organización modular del proyecto.

---

## Descripción de la versión React Native

La versión desarrollada en **React Native con Expo** corresponde a una implementación equivalente de la **Peer Assessment App**, construida con TypeScript y organizada bajo una estructura modular.

Esta versión se enfoca principalmente en el flujo del estudiante, permitiendo iniciar sesión, consultar cursos asignados, revisar evaluaciones disponibles, calificar compañeros, enviar evaluaciones y consultar resultados públicos por curso. Aunque la vista de profesor no se encuentra completamente implementada en esta versión, el proyecto se plantea como una adaptación funcional equivalente a la versión Flutter, siguiendo la arquitectura definida dentro del proyecto React Native.

La estructura del proyecto está organizada en la carpeta `src`, donde se distribuyen componentes, configuración, núcleo de la aplicación, funcionalidades, navegación, tema visual y utilidades.

Características principales de esta versión:

- Implementación móvil usando React Native.
- Uso de Expo para facilitar ejecución y desarrollo.
- Uso de TypeScript.
- Flujo de estudiante implementado.
- Estructura preparada para ampliar el flujo de profesor.
- Consulta de cursos y grupos asignados.
- Visualización de evaluaciones disponibles.
- Envío de evaluaciones entre pares.
- Consulta de resultados públicos.
- Conexión con la misma base usada por la versión Flutter.
- Arquitectura modular basada en carpetas funcionales.

---



## Métricas de evaluación

El análisis comparativo detallado entre ambas aplicaciones se encuentra documentado en el siguiente informe:

**Informe comparativo en PDF:**  
[Agregar aquí el enlace al documento comparativ](#)

En dicho informe se evalúan métricas como:

- Arquitectura general comparada
- Tecnologías utilizadas
- Tamaño final del APK.
- Tiempo de respuesta API.
- Fluidez de interfaz.
- Tiempo de arranque de la aplicación
- Consumo de recursos del dispositivo
- Adaptabilidad y experiencia.

---

## Conclusiones generales del proyecto

El desarrollo de la **Peer Assessment App** en dos tecnologías diferentes permite observar cómo una misma solución académica puede ser implementada desde enfoques distintos de desarrollo móvil.

La versión Flutter destaca por presentar una implementación más completa de los flujos funcionales, incluyendo tanto el rol de profesor como el rol de estudiante. Su estructura permite organizar el proyecto con una separación clara entre las capas de la aplicación y facilita la construcción de interfaces consistentes dentro del ecosistema Flutter.

La versión React Native, por su parte, permite trasladar la lógica principal de la aplicación a un entorno basado en TypeScript, Expo y componentes reutilizables. Aunque actualmente está centrada en el flujo del estudiante, su estructura modular permite extender el sistema e incorporar nuevas funcionalidades, incluyendo la vista de profesor.

En conjunto, ambos proyectos demuestran la viabilidad de construir aplicaciones académicas multiplataforma con tecnologías modernas. La comparación entre Flutter y React Native permite analizar no solo el resultado visual de cada aplicación, sino también aspectos de arquitectura, organización del código, escalabilidad, rendimiento y facilidad de mantenimiento.

---

## Integrantes

- [Nelson Diaz Pizarro]
- [Presly Romero Col]