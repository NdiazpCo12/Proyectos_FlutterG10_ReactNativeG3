


## Peer Assessment App – Evaluación Colaborativa

### Autor

Nombre: José Ferrer

Curso: Mobile Development

Proyecto: Peer Assessment App

Fecha: 2026

---

# 1. Problema Identificado

En los cursos universitarios donde se desarrollan actividades colaborativas, los docentes no tienen un mecanismo estructurado, transparente y cuantificable para evaluar el desempeño individual dentro de los equipos.

Actualmente:

* Los grupos se forman en Brightspace.
* No existe trazabilidad clara del desempeño individual.
* No hay métricas automáticas por estudiante, grupo o actividad.
* Las evaluaciones pueden ser subjetivas y poco estructuradas.

Esto genera:

* Injusticias en calificaciones.
* Baja responsabilidad individual.
* Falta de datos consolidados para toma de decisiones.

---

# 2. Referentes Analizados

### Brightspace (D2L)

* Gestión de grupos y categorías.
* No incluye evaluación estructurada entre pares con métricas avanzadas.

### Google Forms

* Permite evaluación entre pares.
* No genera métricas agregadas automáticas.
* No restringe autoevaluación automáticamente.

### Peergrade

* Sistema especializado en evaluación entre pares.
* Interfaz estructurada.
* Sin integración directa con Brightspace en contexto institucional.

---

# 3. Composición y Diseño de la Solución

## Arquitectura Propuesta

Se propone:

### Una sola aplicación Flutter con roles (Teacher / Student)

Justificación:

* Reduce duplicidad de código.
* Facilita mantenimiento.
* Centraliza autenticación.
* Mejor experiencia UX coherente.

---

## Arquitectura Técnica

Se implementará **Clean Architecture**:

### Presentation Layer

* GetX Controllers
* UI Screens
* Widgets

### Domain Layer

* Entities
* UseCases
* Repository Interfaces

### Data Layer

* Repository Implementations
* Remote Data Source (Roble)
* Local cache (si aplica)

---

## Gestión Técnica

* State Management: GetX
* Navigation: GetX routes
* Dependency Injection: GetX Bindings
* Auth & Storage: Roble
* Permisos: Location + Background

---

# 4. Flujo Funcional Detallado

## Teacher Flow

1. Login


   <img width="405" height="769" alt="image" src="https://github.com/user-attachments/assets/90169721-4691-438a-bcff-d623f1df8bf4" />


2. Dashboard


   <img width="402" height="757" alt="image" src="https://github.com/user-attachments/assets/2ac2ed80-110a-4722-93c2-8466ffb03d5d" />

3. Crear curso

   <img width="373" height="764" alt="image" src="https://github.com/user-attachments/assets/12e304da-dc32-4a49-ac86-663858b62f6f" />

   
4. Invitar estudiantes (token privado / código verificación)

   <img width="379" height="754" alt="image" src="https://github.com/user-attachments/assets/18287dea-ee8f-4080-b7f1-5e65def04827" />

6. Importar grupos desde Brightspace

   <img width="358" height="757" alt="image" src="https://github.com/user-attachments/assets/62a03b14-e32d-49f9-ab9e-72e284ef1460" />

7. Crear evaluación:

   * Nombre
   * Ventana de tiempo
   * Categoría
   * Visibilidad (Public / Private)

  <img width="374" height="766" alt="image" src="https://github.com/user-attachments/assets/8dae1b31-385d-41b5-a99a-9dfedfd546ee" />

  
8. Activar evaluación

<img width="348" height="271" alt="image" src="https://github.com/user-attachments/assets/e735b11d-4034-4520-b24b-4a5866f5fd4a" />

9. Visualizar métricas:

   * Promedio actividad
   * Promedio grupo
   * Promedio estudiante
   * Detalle por criterio

<img width="394" height="759" alt="image" src="https://github.com/user-attachments/assets/6c2072d5-d784-4458-9606-c7a15e3a3c03" />

---

## Student Flow

1. Login

<img width="378" height="752" alt="image" src="https://github.com/user-attachments/assets/c6c3093b-6fc7-4c83-aac0-eac45d86ee0c" />

2.Dashboard

<img width="392" height="756" alt="image" src="https://github.com/user-attachments/assets/17edd49e-5fb0-4777-ae6e-b94f94e6b284" />

3. Unirse a curso

<img width="419" height="774" alt="image" src="https://github.com/user-attachments/assets/291c3139-3bbf-47a7-a6ad-166767d5e987" />

4. Ver evaluaciones activas

<img width="376" height="282" alt="image" src="https://github.com/user-attachments/assets/4506c04f-1af4-4566-a46a-c039a1c19359" />


4. Evaluar compañeros (sin autoevaluación)

<img width="417" height="779" alt="image" src="https://github.com/user-attachments/assets/be7a1c5f-6567-4b67-89f2-496ec441cd20" />

5. Enviar evaluación

<img width="428" height="771" alt="image" src="https://github.com/user-attachments/assets/6ed89ee4-3cd8-4336-a098-465c06dc437b" />

6. Ver resultados (si son públicos)

<img width="389" height="762" alt="image" src="https://github.com/user-attachments/assets/dc2580d6-4fe0-4673-b781-0918488ad5f6" />
<img width="389" height="767" alt="image" src="https://github.com/user-attachments/assets/744f9a56-2753-4495-bf9d-790fe8ffa448" />



---

# 5. Modelo de Evaluación

Cada evaluación incluye:

* Nombre
* Duración
* Visibilidad (Pública / Privada)
* Categoría de grupo

### Criterios evaluados:

* Punctuality
* Contributions
* Commitment
* Attitude

Escala:
2.0 – Needs Improvement
3.0 – Adequate
4.0 – Good
5.0 – Excellent

No se permite autoevaluación.

---

# 6. Acceso a Resultados

### Teacher puede ver:

* Promedio por actividad
* Promedio por grupo
* Promedio por estudiante
* Detalle por criterio

### Student puede ver:

* Resultados si la evaluación es pública

---

# 7. Prototipo Figma

Enlace al prototipo:
[(Figma)](https://www.figma.com/make/0uZ0VbrH1lQeuG6b2yE7T9/Peer-Assessment-App-UX-Flow?t=OlXwS1pFtGwFbZoW-1)

Incluye:

* Login
* Dashboard Teacher
* Dashboard Student
* Crear evaluación
* Evaluar compañeros
* Vista de métricas
* Resultados públicos

---

# 8. Justificación del Modelo

La solución:

* Aumenta responsabilidad individual.
* Genera métricas objetivas.
* Permite análisis longitudinal.
* Mejora justicia en calificación.
* Se integra con Brightspace sin reemplazarlo.

---

# 9. Tecnologías

* Flutter
* GetX
* Roble
* Clean Architecture
* Brightspace API (importación grupos)

---

# 10. Posibles Extensiones Futuras

* Detección de sesgo en evaluación
* Algoritmo de ponderación por confiabilidad
* Reportes descargables PDF
* Dashboard avanzado con gráficas
* Integración directa LMS

---



