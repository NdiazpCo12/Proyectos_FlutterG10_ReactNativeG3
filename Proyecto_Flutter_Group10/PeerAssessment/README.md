# Propuesta Grupal – Peer Assessment App  

Asignatura: Desarrollo Móvil – 2026-10  
Proyecto_Flutter_Group10  

---

# 1. Introducción

En entornos universitarios donde se desarrollan proyectos colaborativos, la evaluación individual dentro de un grupo representa un desafío frecuente. En muchos casos, la calificación grupal no refleja con precisión el aporte real de cada estudiante, lo que genera percepciones de inequidad y reduce la responsabilidad individual dentro del equipo.

Aunque plataformas como Brightspace permiten gestionar cursos y grupos académicos, no ofrecen un mecanismo especializado para realizar evaluaciones estructuradas entre pares con métricas comparativas claras y trazabilidad de resultados.

Ante esta problemática surge **Peer Assessment App**, una aplicación móvil diseñada para facilitar la evaluación entre pares en trabajos colaborativos universitarios, proporcionando un sistema estructurado de criterios, métricas comparativas y visualización analítica de resultados tanto para docentes como para estudiantes.

---

# 2. Objetivo del Proyecto

Diseñar una aplicación móvil que permita implementar un sistema de evaluación entre pares estructurado, integrado con plataformas académicas existentes, que facilite la medición objetiva del desempeño individual dentro de trabajos colaborativos.

---

# 3. Alcance del Proyecto

La solución propuesta contempla el diseño conceptual, funcional y arquitectónico de una aplicación móvil que permita:

- Gestión de cursos académicos.
- Inscripción de estudiantes a cursos mediante código o invitación.
- Importación o sincronización de grupos desde Brightspace.
- Creación y programación de evaluaciones entre pares.
- Definición de criterios estandarizados de evaluación.
- Restricción de autoevaluación.
- Cálculo automático de métricas agregadas.
- Visualización diferenciada de resultados para docentes y estudiantes.

El sistema está diseñado bajo un enfoque **mobile-first**, priorizando la interacción desde dispositivos móviles y garantizando una experiencia de usuario clara y estructurada.

---

# 4. Análisis de Referentes

Para el desarrollo grupal y conceptual del proyecto se analizaron diferentes plataformas educativas y modelos de evaluación existentes.

## Brightspace

Brightspace es una plataforma LMS utilizada ampliamente para la gestión de cursos universitarios.

Fortalezas:
- Gestión institucional de cursos.
- Organización de estudiantes mediante categorías de grupo.

Limitaciones:
- No dispone de un sistema especializado de evaluación entre pares con métricas comparativas detalladas.
- La visualización analítica de contribuciones individuales es limitada.

---

## Moodle / Canvas

Plataformas LMS que incluyen módulos de revisión o evaluación entre pares.

Fortalezas:
- Permiten estructurar evaluaciones asociadas a actividades.
- Integración directa con cursos.

Limitaciones:
- Experiencia móvil limitada.
- Escasa visualización analítica de resultados por criterio.

---

## Modelo de Evaluación 360°

Utilizado en entornos organizacionales para evaluar desempeño desde múltiples perspectivas.

Fortalezas:
- Evaluación basada en competencias.
- Visión integral del desempeño.

Limitaciones:
- No se encuentra adaptado directamente a entornos académicos ni a plataformas LMS.

---

A partir de este análisis, la propuesta de Peer Assessment App busca integrar las fortalezas de estos modelos y superar sus limitaciones mediante una solución móvil especializada en evaluación académica entre pares.

---

# 5. Modelo de Evaluación

El sistema implementa un modelo de evaluación estructurado basado en criterios definidos por el docente.

Cada evaluación incluye:

- Nombre de la evaluación
- Periodo activo (fecha de apertura y cierre)
- Categoría de grupo asociada
- Tipo de visibilidad (pública o privada)
- Criterios evaluativos

Criterios evaluados:

- Punctuality
- Contributions
- Commitment
- Attitude

Escala de evaluación:

| Valor | Descripción |
|------|-------------|
| 2.0 | Needs Improvement |
| 3.0 | Adequate |
| 4.0 | Good |
| 5.0 | Excellent |

El sistema no permite la autoevaluación.  
Cada estudiante únicamente puede evaluar a los miembros de su propio grupo.

---

# 6. Flujo Funcional del Sistema

## Flujo del Docente

1. El docente inicia sesión en la aplicación.
2. Accede al panel de cursos activos.
3. Puede crear un nuevo curso académico.
4. Invita estudiantes mediante:
   - código de curso
   - enlace de invitación
   - código QR
5. Importa o sincroniza grupos desde Brightspace.
6. Configura evaluaciones:
   - nombre
   - grupo
   - periodo
   - visibilidad
   - criterios
7. Monitorea el progreso de las evaluaciones.
8. Accede a resultados analíticos con métricas agregadas.

---

## Flujo del Estudiante

1. El estudiante inicia sesión en la aplicación.
2. Visualiza los cursos en los que está inscrito.
3. Accede a evaluaciones activas del curso.
4. Evalúa a sus compañeros según los criterios definidos.
5. Envía la evaluación dentro del periodo habilitado.
6. Puede visualizar resultados si la evaluación es pública.

---

# 7. Acceso a Resultados

## Docente

El docente puede visualizar:

- Promedio por actividad.
- Promedio por grupo.
- Promedio por estudiante.
- Desglose detallado por criterio.

La visualización sigue una estructura jerárquica:

Curso → Grupo → Estudiante → Criterios.

---

## Estudiante

El estudiante puede visualizar:

- Su promedio general.
- Desglose por criterio.
- Comparación con el promedio del grupo.

Los resultados solo son visibles para el estudiante si la evaluación es configurada como **pública**.

---

# 8. Prototipo UX

El prototipo de la aplicación fue diseñado utilizando Figma con un enfoque mobile-first.

Incluye las siguientes interfaces principales:

- Pantalla de autenticación
- 
<img width="346" height="733" alt="image" src="https://github.com/user-attachments/assets/6dda82a5-6bc3-48f7-bf70-f1aa272cde40" />

- Dashboard del docente

<img width="313" height="688" alt="image" src="https://github.com/user-attachments/assets/d9b6faeb-e8ac-42ac-8711-b832a2ea4b46" />


- Dashboard del estudiante

<img width="350" height="747" alt="image" src="https://github.com/user-attachments/assets/e623d110-b4a0-4956-8d92-7d6656096440" />


- Gestión de cursos

<img width="342" height="744" alt="image" src="https://github.com/user-attachments/assets/0f76b0f5-2369-459e-9278-ae0a705da001" />

- Sincronización de grupos

<img width="308" height="151" alt="image" src="https://github.com/user-attachments/assets/5e5a7bef-f5c6-4568-8993-c9d23437d523" />

- Creación de evaluaciones

<img width="347" height="750" alt="image" src="https://github.com/user-attachments/assets/47abfa56-728d-444b-911e-1e37ce70ff2c" />

- Panel de métricas y resultados

<img width="368" height="747" alt="image" src="https://github.com/user-attachments/assets/f9d5e9f5-0ab1-47b5-9b50-14e7b13c46b0" />
<img width="346" height="738" alt="image" src="https://github.com/user-attachments/assets/9ec08b52-7728-46c4-aeed-b51af13c8eaf" />


- Evaluación

<img width="350" height="749" alt="image" src="https://github.com/user-attachments/assets/b0c44bea-bc5f-4db7-86c8-6044c98c7d29" />


Enlace al prototipo:

[https://www.figma.com/make/3plBqumLI3pCBCt8W2Pv5Y/Flujo-UX-para-app-de-evaluaci%C3%B3n](https://www.figma.com/make/8IiMTQ6rQjFEKlc45ujc1P/Untitled?p=f&t=EMn8JsIewEGui4xu-0&fullscreen=1&preview-route=%2Flogin)

Las capturas utilizadas en esta propuesta corresponden al prototipo desarrollado dentro del equipo.

---

# 9. Arquitectura del Sistema

La aplicación se plantea bajo el modelo **Clean Architecture**, lo que permite separar responsabilidades y facilitar escalabilidad.

## Capa de Presentación

Responsable de la interacción con el usuario.

Incluye:

- Interfaces de usuario
- Controladores
- Navegación
- Gestión de estado

Se implementa mediante **GetX**.

---

## Capa de Dominio

Contiene las reglas de negocio y las entidades principales del sistema.

Entidades principales:

- Curso
- Grupo
- Evaluación
- Criterio
- Resultado

Reglas implementadas:

- Validación de evaluaciones
- Cálculo de promedios
- Control de visibilidad de resultados

---

## Capa de Datos

Encargada de la comunicación con servicios externos.

Incluye:

- Autenticación mediante Roble
- Almacenamiento de datos
- Integración con Brightspace para sincronización de grupos

---

# 10. Tecnologías Utilizadas

La solución propuesta se basa en el siguiente stack tecnológico:

- Flutter (desarrollo móvil multiplataforma)
- GetX (gestión de estado y navegación)
- Roble (autenticación y almacenamiento)
- Clean Architecture (estructura del sistema)
- Brightspace API (importación de grupos)

Este enfoque nos garantiza que haya:

- escalabilidad
- mantenibilidad
- facilidad para pruebas unitarias
- separación clara de responsabilidades

---

# 11. Justificación del Modelo

Peer Assessment App busca mejorar la transparencia y la equidad en la evaluación de trabajos colaborativos.

Esta solución permite:

- incrementar la responsabilidad individual dentro de los grupos
- generar métricas comparativas objetivas
- reducir la subjetividad en la calificación
- facilitar la toma de decisiones pedagógicas basadas en datos

Adicionalmente, la integración con Brightspace permite complementar el ecosistema académico existente sin reemplazar el LMS institucional.

---

# 12. Extensiones Futuras 

El sistema puede ampliarse en futuras versiones como lo podrian ser algunos apartados de:

- detección automática de sesgo evaluativo
- ponderación por confiabilidad del evaluador
- generación automática de reportes en PDF
- dashboards aun mas avanzados con análisis longitudinal
- integración bidireccional completa con LMS institucional

---
