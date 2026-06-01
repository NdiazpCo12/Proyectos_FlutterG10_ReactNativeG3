# Propuesta de Aplicación

## Autor

Juan Pablo Guzman Restrepo.

## Proyecto

Mobile Development Project — Peer Assessment App

---

## 1. Descripción General

**Peer Assessment App** es una aplicación móvil que sera desarrollada en Flutter que permitira evaluar el desempeño y compromiso de estudiantes en actividades colaborativas dentro de cursos universitarios.

El sistema facilitara la evaluación entre pares en trabajos grupales, proporcionando herramientas para gestionar cursos, grupos, actividades de evaluación y análisis de resultados. La aplicación promueve la responsabilidad individual, la transparencia en el trabajo colaborativo y el seguimiento del desempeño académico.


---

## 2. Referentes Analizados

### Google Classroom

* Gestión de cursos y estudiantes.
* Organización clara de actividades académicas.
* Flujo de interacción profesor–estudiante simple e intuitivo.

### Moodle

* Sistema estructurado de evaluaciones.
* Gestión avanzada de usuarios y roles.
* Seguimiento detallado del desempeño.

### Peergrade / Sistemas de Peer Assessment

* Evaluación entre pares estructurada.
* Retroalimentación entre estudiantes.
* Visualización de resultados y métricas.

---

## 3. Arquitectura y Diseño de la Solución

### Arquitectura propuesta

La aplicación sigue principios de **Clean Architecture** para garantizar escalabilidad, mantenibilidad y separación de responsabilidades.

**Capas del sistema:**

* Presentation Layer: interfaz de usuario y manejo de interacción.
* Domain Layer: lógica de negocio y reglas del sistema.
* Data Layer: servicios externos, almacenamiento y persistencia.

### Gestión de estado

* GetX para manejo de estado, navegación y dependencias.

### Configuración del sistema

* Aplicación única con soporte de roles.
* Autenticación segura.
* Almacenamiento remoto de datos.
* Importación de grupos desde plataforma externa.

---

## 4. Funcionalidades Principales

### Profesor

* Crear y gestionar cursos.
* Invitar estudiantes mediante acceso privado o verificación.
* Importar grupos desde sistema externo.
* Crear actividades de evaluación.
* Definir visibilidad de resultados (públicos o privados).
* Visualizar métricas de desempeño.
* Consultar resultados detallados por estudiante y grupo.

### Estudiante

* Unirse a cursos.
* Visualizar grupo de trabajo.
* Evaluar a sus compañeros (sin autoevaluación).
* Consultar resultados de evaluaciones.
* Revisar historial de actividades.

---

## 5. Criterios de Evaluación

Cada estudiante es evaluado según los siguientes criterios:

* Puntualidad
* Contribuciones
* Compromiso
* Actitud

### Escala de evaluación

| Nivel | Descripción       |
| ----- | ----------------- |
| 2.0   | Needs Improvement |
| 3.0   | Adequate          |
| 4.0   | Good              |
| 5.0   | Excellent         |

No se permite autoevaluación.

---

## 6. Flujo Funcional del Sistema

### Flujo general del sistema

1. El profesor crea un curso.
2. El profesor invita estudiantes al curso.
3. El sistema importa los grupos desde la plataforma externa.
4. El profesor crea una actividad de evaluación.
5. El profesor define duración y visibilidad de la evaluación.
6. Los estudiantes acceden a la evaluación activa.
7. Cada estudiante evalúa a sus compañeros de grupo.
8. El sistema almacena y procesa las calificaciones.
9. El sistema calcula promedios por actividad, grupo y estudiante.
10. Los resultados se muestran según la configuración de visibilidad.
11. El profesor analiza métricas y desempeño.

---

### Flujo de evaluación entre pares (estudiante)


1. El estudiante inicia sesión.

<img width="507" height="898" alt="image" src="https://github.com/user-attachments/assets/674fcb14-a8ba-42ee-a173-08bcb3eb3983" />

2. Selecciona curso activo.

<img width="499" height="899" alt="image" src="https://github.com/user-attachments/assets/21901d05-a83a-4487-827c-69fea8fa2c79" />

3. Selecciona miembro del grupo.


<img width="492" height="899" alt="image" src="https://github.com/user-attachments/assets/cb820d62-0c81-452f-b1ec-b96ea87c5dc9" />

   
5. Evalúa criterios:

   * Puntualidad

<img width="512" height="899" alt="image" src="https://github.com/user-attachments/assets/d417bc45-7821-479f-a1f0-d2e96fc1196b" />

   * Contribuciones

<img width="504" height="901" alt="image" src="https://github.com/user-attachments/assets/d7686622-d254-4f6c-9bd1-168fb0b299c7" />

   * Compromiso


<img width="513" height="900" alt="image" src="https://github.com/user-attachments/assets/394847d8-687d-4b28-9fb1-2e67787e6543" />

    
   * Actitud


<img width="509" height="901" alt="image" src="https://github.com/user-attachments/assets/7d2aa526-b401-43f4-a74e-444fc254172d" />


  
6. Sistema registra resultados.


<img width="504" height="896" alt="image" src="https://github.com/user-attachments/assets/21160c85-d90d-4d44-b2f1-bd09ba69a29c" />


---

### Flujo de creación de evaluación (profesor)


1. Profesor inicia sesión.


<img width="486" height="896" alt="image" src="https://github.com/user-attachments/assets/827bfa61-78ec-4e4a-887f-91bd7319e6b0" />


2. Selecciona curso.


<img width="508" height="898" alt="image" src="https://github.com/user-attachments/assets/718d7cdd-2f62-46df-98f2-916efd443c14" />


3. Define:


   * nombre


<img width="508" height="902" alt="image" src="https://github.com/user-attachments/assets/78d013c0-54f0-4e92-8404-49a9d42191e3" />


   * duración


<img width="509" height="902" alt="image" src="https://github.com/user-attachments/assets/511cfa49-99b7-482a-bdd3-8534b193da3d" />


   * visibilidad


<img width="511" height="901" alt="image" src="https://github.com/user-attachments/assets/dcc7eb73-b2af-4780-aee5-e7c494dcb902" />


   * criterios


<img width="511" height="901" alt="image" src="https://github.com/user-attachments/assets/251121f5-98ac-4022-9ae4-fa47c3f60a75" />


4. Publica evaluación.


<img width="501" height="899" alt="image" src="https://github.com/user-attachments/assets/b2ef4757-ed78-469a-9377-8711e95b7c4f" />

---

### Flujo de visualización de resultados

1. Sistema procesa evaluaciones.
2. Calcula promedios.


<img width="504" height="900" alt="image" src="https://github.com/user-attachments/assets/f7e74425-430e-4454-af30-b116de6fc9d7" />


5. Genera métricas:
   * promedio por grupo


<img width="513" height="903" alt="image" src="https://github.com/user-attachments/assets/508ab0cf-c2e9-4caa-ba4a-6526bb604834" />


   * comparacion entre grupos por medio de graficos


<img width="493" height="904" alt="image" src="https://github.com/user-attachments/assets/cf0a1edf-b6fc-43a5-90e3-1e92384e9a21" />


   * Completitud del trabajo
     

<img width="506" height="906" alt="image" src="https://github.com/user-attachments/assets/51daccbf-eee9-417f-aa7f-920ec7cbf486" />

  * Tendencias de rendimiento


<img width="527" height="904" alt="image" src="https://github.com/user-attachments/assets/245a6227-5a58-4ec7-b7f0-deb49c00b1b1" />


5. Muestra resultados según configuración:

   * solo profesor


<img width="516" height="901" alt="image" src="https://github.com/user-attachments/assets/c10b7484-e426-40ac-afef-e85817fa7e5c" />


   * profesor y estudiantes


<img width="511" height="895" alt="image" src="https://github.com/user-attachments/assets/4a380bfd-fcce-4eef-9cc0-7045cd4a4d80" />


---

## 7. Diseño UX/UI

El diseño de la aplicación prioriza:

* Usabilidad y claridad visual.
* Navegación intuitiva.
* Retroalimentación inmediata al usuario.
* Visualización clara de métricas.
* Interfaz adaptable según rol.
* Accesibilidad y consistencia visual.

El sistema incluye:

* Pantallas de autenticación.
* Dashboard de usuario.
* Flujo guiado de evaluación.
* Gestión de cursos.
* Panel de resultados y analítica.

---

## 8. Justificación de la Propuesta

* Mejora la responsabilidad individual.
* Permite evaluación objetiva del trabajo en equipo.
* Facilita análisis del desempeño académico.
* Reduce sesgos en evaluaciones grupales.
* Proporciona retroalimentación cuantificable.

---

## 9. Prototipo en Figma

Link del prototipo:
https://www.figma.com/make/fUff3akO7fkAHo6xS4PnOS/Peer-Assessment-App-UI-UX?t=na7wTLLx4yijH20F-1

El prototipo incluye:

* Flujo de autenticación.
* Dashboard de usuario.
* Evaluación entre pares.
* Gestión de cursos.
* Panel de resultados.

---

## 10. Tecnologías

* Flutter
* GetX
* Clean Architecture
* Servicios de autenticación y almacenamiento remoto

