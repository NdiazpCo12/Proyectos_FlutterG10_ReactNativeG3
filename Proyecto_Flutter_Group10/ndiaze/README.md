# PeerEval App – Peer Assessment Application

Proyecto desarrollado para la asignatura Desarrollo Móvil – 2026-10.  
Aplicación móvil en Flutter orientada a la evaluación académica entre pares en entornos universitarios.

---

## 1. Pregunta de Investigación

¿Cómo diseñar una aplicación móvil basada en arquitectura limpia que permita evaluar de manera objetiva, estructurada y transparente el desempeño individual en trabajos colaborativos universitarios, integrándose con sistemas académicos existentes y proporcionando métricas comparativas confiables para la toma de decisiones pedagógicas?

---

## 2. Propósito y Alcance del Proyecto

El propósito de la presente propuesta es formular una propuesta sólida de diseño conceptual, funcional y arquitectónico para el desarrollo de una aplicación móvil orientada a la evaluación entre pares en entornos académicos colaborativos. La solución busca responder a problemáticas reales identificadas en el contexto universitario relacionadas con la distribución justa de calificaciones en trabajos grupales.
El alcance contempla la gestión de cursos, sincronización de categorías de grupos desde Brightspace, creación y programación de evaluaciones con criterios definidos, cálculo automático de métricas agregadas y visualización diferenciada de resultados para docentes y estudiantes.


---

## 3. Análisis Comparativo de Referentes

### Moodle – Peer Assessment Module

Permite evaluación entre pares dentro de actividades académicas.  
Fortaleza: integración directa con cursos existentes.  
Limitación: experiencia móvil limitada y análisis agregado reducido.

### Canvas LMS – Peer Review System

Permite asignación automática de revisiones.  
Fortaleza: organización estructurada del proceso.  
Limitación: visualización analítica limitada por criterio y enfoque predominantemente web.

### Modelo de Evaluación 360°

Utilizado en entornos organizacionales para evaluar desempeño por competencias.  
Fortaleza: evaluación integral por dimensiones.  
Limitación: no adaptado a dinámicas LMS académicas.

La propuesta integra estructuración por actividades, evaluación por competencias y análisis comparativo móvil, superando limitaciones detectadas en estos referentes.

---

## 4. Justificación Empírica y Pedagógica

Docentes con experiencia en metodologías colaborativas identificaron tres problemáticas recurrentes:

- Inequidad percibida en la calificación grupal.
- Falta de evidencia cuantitativa.
- Conflictos derivados de contribuciones desiguales.

La aplicación responde mediante:

- Métricas comparativas por criterio.
- Cálculo automático de promedios.
- Control de visibilidad pública o privada.
- Trazabilidad por actividad, grupo y estudiante.

---

## 5. Modelo de Evaluación

La PeerEval App implementa un esquema evaluativo estructurado que garantiza coherencia, trazabilidad y control académico. Cada evaluación incluye nombre, periodo activo (fecha y duración), categoría de grupo asociada y tipo de visibilidad (pública o privada). Los criterios evaluados son: Punctuality, Contributions, Commitment y Attitude, bajo una escala estandarizada de 2.0 a 5.0 (Needs Improvement a Excellent). El sistema impide la autoevaluación y restringe la calificación exclusivamente a compañeros del mismo grupo, asegurando integridad del proceso y consistencia en la medición del desempeño colaborativo.

Cada evaluación configurada por el docente incluye:

- Nombre de la evaluación.
- Ventana temporal (fecha de apertura y cierre).
- Categoría de grupo asociada.
- Tipo de visibilidad (Pública o Privada).
- Criterios evaluativos:
  - Punctuality
  - Contributions
  - Commitment
  - Attitude

Escala de evaluación:

- 2.0 – Needs Improvement  
- 3.0 – Adequate  
- 4.0 – Good  
- 5.0 – Excellent  

No se permite autoevaluación.  
Cada estudiante evalúa únicamente a miembros de su grupo asignado.

---

## 6. Acceso a Resultados

### Docente

Acceso completo a:

- Promedio por actividad.
- Promedio por grupo.
- Promedio por estudiante.
- Desglose detallado por criterio.
- Visualización jerárquica:
  Curso → Grupo → Estudiante → Criterios.

### Estudiante

Acceso condicionado por visibilidad:

- Si la evaluación es pública:
  - Promedio general.
  - Desglose por criterio.
- Si es privada:
  - Resultados visibles únicamente para el docente.

---

## 7. Flujo Funcional del Sistema

- Fase 1: Gestión y Sincronización
El docente selecciona un curso y sincroniza automáticamente las categorías de grupos desde Brightspace. El sistema valida consistencia de datos y actualiza miembros.
- Fase 2: Configuración de Evaluación
El docente define nombre, duración, criterios, tipo de visibilidad y fecha de apertura/cierre. El sistema envía notificación a estudiantes.
- Fase 3: Proceso de Evaluación
Los estudiantes califican a sus compañeros (sin autoevaluación). El sistema valida respuestas completas y permite edición solo dentro del periodo activo.
- Fase 4: Cierre y Procesamiento
Al finalizar el tiempo, la evaluación se bloquea automáticamente. Se calculan promedios por criterio, actividad, grupo y estudiante.
- Fase 5: Visualización Analítica
El docente accede a reportes comparativos con métricas agregadas. Los estudiantes visualizan resultados únicamente si la evaluación es pública. 
Esta propuesta traerá las siguientes ventajas: 
• Integración directa con Brightspace.
• Métricas comparativas por criterio.
• Arquitectura escalable.
• Control de visibilidad configurable.
• Coherencia total entre diseño conceptual, prototipo y futuro seguimiento implementación grupal.


### Flujo del Estudiante

1. Autenticación y selección de rol.
2. Visualización de cursos inscritos.
3. Acceso a evaluaciones activas.
4. Evaluación de compañeros (sin autoevaluación).
5. Confirmación y registro del envío.
6. Consulta de resultados según visibilidad configurada.

### Flujo del Docente

1. Autenticación y acceso según rol.
2. Gestión de cursos activos.
3. Creación de cursos.
4. Invitación de estudiantes mediante código, enlace o QR.
5. Sincronización de grupos desde Brightspace.
6. Configuración de evaluación (criterios, visibilidad, periodo).
7. Activación y monitoreo de evaluaciones.
8. Visualización analítica de métricas agregadas.

---

## 8. Flujo Funcional de la Aplicación PeerEval App 

El prototipo fue desarrollado en Figma bajo enfoque mobile-first.

Incluye:

- Pantalla de Login.
<img width="286" height="561" alt="image" src="https://github.com/user-attachments/assets/b29b67ac-adf7-47f8-b7c4-156b6483b681" />
 
# Flujo del Estudiante

1. Autenticación con selección de rol; el sistema valida credenciales y carga funcionalidades para el estudiante.
   
     <img width="264" height="525" alt="image" src="https://github.com/user-attachments/assets/fb27d8cb-a10c-4861-84f3-8eed8cf71034" />

2. El estudiante visualiza su Dahsboard donde se ve el estado de evaluaciones, grupos asignados y acceso condicionado a resultados según visibilidad configurada.
      
     <img width="264" height="509" alt="image" src="https://github.com/user-attachments/assets/9ae0fccf-1b8b-4dcc-95f9-8936cdd76046" /> <img width="244" height="514" alt="image" src="https://github.com/user-attachments/assets/32e53d8b-b475-4ebe-bcca-50b0db0646ff" />

3. El estudiante visualiza cursos inscritos y se une mediante código; accede a grupos asignados y evaluaciones pendientes por curso, para previamente evaluar a los compañeros.

    <img width="216" height="457" alt="image" src="https://github.com/user-attachments/assets/7cf4e863-01b0-4a40-9307-59a8592690c1" /> <img width="210" height="455" alt="image" src="https://github.com/user-attachments/assets/0c16a01f-fd18-48b5-a264-57a22512cf72" /> <img width="216" height="456" alt="image" src="https://github.com/user-attachments/assets/15167118-4eb6-41b0-ad38-27ccfcec588c" /> <img width="199" height="455" alt="image" src="https://github.com/user-attachments/assets/3db16310-5507-4ed8-8328-f73ecab65e02" />
 
4. El sistema confirma el envío, registra la evaluación y notifica disponibilidad de resultados según configuración pública o privada.

     <img width="237" height="499" alt="image" src="https://github.com/user-attachments/assets/9f0f7af4-a012-48c4-bcba-2e297148c53d" />

5. El estudiante identifica evaluaciones activas, vencidas o completadas, accediendo al proceso de evaluación dentro del periodo habilitado.

     <img width="253" height="531" alt="image" src="https://github.com/user-attachments/assets/f0469f08-9395-448d-9d78-c7ce76b1e114" /> <img width="254" height="530" alt="image" src="https://github.com/user-attachments/assets/a951a1e3-c54c-4635-9df6-4755ea49663f" /> <img width="240" height="527" alt="image" src="https://github.com/user-attachments/assets/aec27137-00ea-4b46-80ad-f1793979a4f4" />


# Flujo del Profesor 

1. El usuario selecciona su rol institucional, valida credenciales y accede a la interfaz específica según permisos asignados.

    <img width="228" height="480" alt="image" src="https://github.com/user-attachments/assets/b3ebc029-e233-4914-9bc9-0f9cbe8698b8" />

2.	El docente gestiona cursos activos, crea nuevos espacios académicos y monitorea estudiantes y evaluaciones asociadas.
  
     <img width="265" height="575" alt="image" src="https://github.com/user-attachments/assets/f2e49d10-cddb-4f9d-b107-99ef6861c6aa" /> <img width="261" height="574" alt="image" src="https://github.com/user-attachments/assets/1b1cf099-00fd-4ac6-a5d4-357cb2c2f6af" />

3.	El docente registra información del curso, define semestre y código, creando el espacio académico para gestión evaluativa.
   
     <img width="256" height="548" alt="image" src="https://github.com/user-attachments/assets/6fa7bd0e-8408-40be-b3a0-9201d1fdcaef" />
 
4.	El docente administra estudiantes, grupos y evaluaciones del curso, accediendo a invitaciones, importaciones y configuración académica.
   
     <img width="249" height="500" alt="image" src="https://github.com/user-attachments/assets/5331eae5-5c78-4511-a748-49bb9b91023a" />

5.	El docente genera código, enlace o QR para inscripción controlada, asegurando acceso autorizado al curso académico.
   
     <img width="274" height="571" alt="image" src="https://github.com/user-attachments/assets/7ad2e251-6822-41d4-aa04-2622a05576ed" /> <img width="266" height="573" alt="image" src="https://github.com/user-attachments/assets/d738f372-f486-4f7d-8acb-f3e83a36ad84" />

6.	El docente sincroniza categorías desde Brightspace; el sistema importa grupos y asigna automáticamente estudiantes correspondientes.

    <img width="264" height="580" alt="image" src="https://github.com/user-attachments/assets/67a7e069-afa5-4348-bddc-d25a70009d17" />

7.	El docente define parámetros de evaluación, selecciona grupo, visibilidad y periodo, configurando reglas del proceso evaluativo. Se establecen criterios y escala de calificación, consolidando la estructura evaluativa antes de su activación.

    <img width="251" height="539" alt="image" src="https://github.com/user-attachments/assets/cfa9f8c6-30ea-429a-acf8-e6b8e0d7ff33" /> <img width="251" height="540" alt="image" src="https://github.com/user-attachments/assets/5b0d3b22-25dc-43f3-b5b4-67af4ecb9d75" />


8.	El docente accede a resultados jerárquicos por grupo y estudiante, visualizando promedios y métricas detalladas por criterio.

    <img width="220" height="472" alt="image" src="https://github.com/user-attachments/assets/41fc1807-b4b3-4a62-9ab6-a1dcc6152e29" /> <img width="219" height="475" alt="image" src="https://github.com/user-attachments/assets/bc618b27-59ee-4d43-a633-d8e01dd0cd3a" /> <img width="216" height="473" alt="image" src="https://github.com/user-attachments/assets/9d571505-d8ec-4a40-aad5-ecdca93caf28" /> <img width="215" height="465" alt="image" src="https://github.com/user-attachments/assets/be94373c-34d1-4649-89ec-394876f4f029" />

   
9.	El docente visualiza promedio general y desglose por criterio, comparado con el grupo, así mismo solo la ve el estudiante si la evaluación es pública.

    <img width="239" height="530" alt="image" src="https://github.com/user-attachments/assets/8cded9a7-0b1e-422a-a42c-9510517a0aac" /> <img width="192" height="540" alt="image" src="https://github.com/user-attachments/assets/c4bde5c1-ed0d-4700-b387-4a6b25fff7ec" />  <img width="250" height="538" alt="image" src="https://github.com/user-attachments/assets/4ac6d468-912f-4080-8d79-83fd45ebdb8c" />


Enlace al Prototipo: Flujo UX para app de evaluación – Figma Make 
https://www.figma.com/make/3plBqumLI3pCBCt8W2Pv5Y/Flujo-UX-para-app-de-evaluaci%C3%B3n?t=j0gC1DZ744Q6WXZ0-1 


---

## 9. Prototipo Hecho en Figma

El prototipo desarrollado en Figma representa el flujo completo del sistema en entorno mobile-first. Incluye autenticación con selección de rol, dashboards diferenciados, gestión de cursos, sincronización de grupos, creación de evaluaciones, proceso de calificación y paneles analíticos. La navegación se basa en barra inferior y tarjetas organizadas jerárquicamente. Se implementa paleta en escalas de azul con modo claro y oscuro, garantizando coherencia visual institucional. El prototipo simula comportamiento realista y está alineado con la arquitectura propuesta para futura implementación en Flutter.

---

## 10. Composición, Tecnologías y Diseño de la App

La solución se desarrolló mediante una aplicación móvil con roles diferenciados (docente y estudiante), lo cual reduce duplicidad de código y garantiza coherencia en experiencia de usuario.
Arquitectura basada en Clean Architecture:
- Capa de Presentación: Interfaces, controladores y gestión de estado mediante GetX.
- Capa de Dominio: Entidades principales (Curso, Grupo, Evaluación, Criterio, Resultado) y reglas de negocio como cálculo de promedios y validaciones.
- Capa de Datos: Conexión con servicios Roble para autenticación y almacenamiento.
Lo cual nos garantiza y garantizara al momento que se proceda con la continuacion de las siguientes fases del presnete proyecto mantenibilidad, escalabilidad futura y facilidad al momento de que se vayan a realizar pruebas unitarias respectivas.
