Peer Assessment App (Flutter)
Aplicación profesional de evaluación entre pares desarrollada en Flutter, diseñada para entornos académicos.
Esta aplicación permite que los profesores creen evaluaciones entre estudiantes y que los estudiantes evalúen a sus compañeros mediante un sistema estructurado de criterios.
La aplicación incluye integración con Brightspace LMS y funcionalidad basada en roles:
•	Profesor
•	Estudiante
________________________________________
Identidad Visual
Tema: Académico Moderno Profesional
Paleta de Colores
Elemento	Color	Código
Primario	Verde Esmeralda Oscuro	#1B5E20
Secundario	Gris Pizarra	#37474F
Fondo	Gris Claro	#F5F5F5
Tipografía
•	Inter
•	Roboto
Estilo de Interfaz
•	Tarjetas redondeadas (16px)
•	Sombras suaves
•	Espaciado limpio
•	Botones de alto contraste
________________________________________
Estructura de la Aplicación
La aplicación utiliza una arquitectura única con navegación basada en roles.
Barra de Navegación Inferior
•	Inicio
•	Evaluaciones
•	Reportes
•	Perfil
Las opciones disponibles se adaptan automáticamente según el rol del usuario:
•	Profesor
•	Estudiante
________________________________________
Flujo General de la Aplicación
Splash → Login → Dashboard → Evaluaciones → Reportes → Perfil
Los flujos de Profesor y Estudiante se separan después del Login.
________________________________________
Pantallas
________________________________________
1. Pantalla Splash
Muestra el logo de la aplicación y la identidad visual.
Incluye:
•	Logo centrado
•	Fondo limpio
•	Texto en el pie:
Powered by Roble
________________________________________
2. Pantalla de Login
Permite a los usuarios iniciar sesión con sus credenciales universitarias.
Incluye:
•	Campo Email
•	Campo Contraseña
•	Botón Iniciar Sesión
•	Branding de la universidad
•	Diseño minimalista
________________________________________
Captura de Pantalla
Aquí va la captura del Login
<img width="491" height="747" alt="logging" src="https://github.com/user-attachments/assets/d295dc92-7195-40d3-a333-c9a77eefb014" />
________________________________________
3. Dashboard Universal
El Dashboard es compartido por Profesores y Estudiantes.
Muestra:
•	Lista de cursos activos en tarjetas
•	Nombre del curso
•	Código del curso
•	Estado
________________________________________
Sincronización con Brightspace
Hay un botón en la parte superior:
Sync with Brightspace
Incluye:
•	Botón de sincronización
•	Indicador circular de carga
•	Retroalimentación visual
________________________________________
Captura de Pantalla
Aquí va la captura del Dashboard
<img width="780" height="1280" alt="image" src="https://github.com/user-attachments/assets/7c89deb3-42a7-461a-b99f-8d478a519a2d" />
<img width="788" height="1280" alt="image" src="https://github.com/user-attachments/assets/0566e8bb-bfe4-47a2-ad4d-7c3cf37944e7" />
________________________________________
Flujo del Profesor
________________________________________
4. Creador de Evaluaciones
Los profesores pueden crear nuevas evaluaciones entre pares.
Campos del formulario:
•	Nombre de la evaluación
•	Ventana de tiempo
•	Selector de categoría de grupo
•	Visibilidad
o	Pública
o	Privada
________________________________________
Características
•	Formulario limpio
•	Campos redondeados
•	Validaciones
•	Botón Guardar
________________________________________
Captura de Pantalla
Aquí va la captura del creador de evaluaciones
<img width="976" height="1600" alt="image" src="https://github.com/user-attachments/assets/4b824906-4142-40ce-8598-eb70564436ae" />
<img width="982" height="1600" alt="image" src="https://github.com/user-attachments/assets/d66aff81-7975-45e3-9be9-16bac89f94d1" />
________________________________________
5. Centro de Analíticas
Permite a los profesores ver el desempeño de los estudiantes.
Incluye:
Gráficas
•	Promedio por Actividad (Gráfica de barras)
•	Promedio por Estudiante (Gráfica de barras)
________________________________________
Detalle Jerárquico
Grupo
 └── Estudiante
      └── Puntaje por criterio
________________________________________
Características
•	Visualización clara
•	Listas expandibles
•	Información organizada
________________________________________
Captura de Pantalla
Aquí va la captura de analíticas
<img width="978" height="1600" alt="image" src="https://github.com/user-attachments/assets/69261436-5fc2-4e70-89ad-33d87521f58e" />
<img width="988" height="1600" alt="image" src="https://github.com/user-attachments/assets/455c226f-adc9-4374-b1d2-c7172b094df3" />
<img width="1024" height="1600" alt="image" src="https://github.com/user-attachments/assets/32279546-2ed1-45f6-8c91-41fbc6e67598" />
________________________________________
Flujo del Estudiante
________________________________________
6. Lista de Evaluaciones
Muestra las evaluaciones disponibles para el estudiante.
Incluye:
•	Tarjetas de evaluaciones
•	Fecha límite
•	Estado
________________________________________
Captura de Pantalla
Aquí va la captura de lista de evaluaciones
<img width="786" height="1280" alt="image" src="https://github.com/user-attachments/assets/e90c43f7-7d51-46da-bf44-70cd4fa86e69" />
________________________________________
7. Pantalla de Evaluación entre Pares
Los estudiantes evalúan a sus compañeros.
Incluye:
•	Lista de compañeros
•	Autoevaluación deshabilitada
•	Diseño limpio
________________________________________
8. Sistema de Calificación con Estrellas
Cada compañero es evaluado mediante un sistema de 5 estrellas.
Escala:
Estrellas	Nota
1	2.0
2	3.0
3	3.5
4	4.5
5	5.0
________________________________________
Criterios de Evaluación
•	Puntualidad
•	Contribución
•	Compromiso
•	Actitud
________________________________________
Características
•	Selección por estrellas
•	Retroalimentación visual
•	Interacción sencilla
________________________________________
Captura de Pantalla
Aquí va la captura del sistema de estrellas
<img width="784" height="1280" alt="image" src="https://github.com/user-attachments/assets/728f2bd4-559b-481e-a95f-4992e4ea363d" />
________________________________________
9. Descripción de Criterios
Cada criterio tiene un ícono de información.
Al presionarlo:
•	Se muestra un tooltip o ventana
•	Se describen los niveles de evaluación
Ejemplo:
•	Necesita mejorar
•	Regular
•	Bueno
•	Muy bueno
•	Excelente
________________________________________
Captura de Pantalla
Aquí va la captura de descripción de criterios
<img width="784" height="1280" alt="image" src="https://github.com/user-attachments/assets/73a55cf8-1341-459c-970b-99ee41b700a7" />
________________________________________
10. Confirmación de Envío
Antes de enviar la evaluación aparece un diálogo de confirmación.
Incluye:
•	Mensaje de confirmación
•	Botón Cancelar
•	Botón Enviar
________________________________________
Captura de Pantalla
Aquí va la captura del diálogo de confirmación
<img width="780" height="1280" alt="image" src="https://github.com/user-attachments/assets/c856a653-ae46-4bd1-b4c3-3e8e3ad66f62" />
________________________________________
11. Pantalla de Resultados
Visible solo si la evaluación es Pública.
Muestra:
•	Promedios
•	Desglose por criterio
Visualización:
•	Gráfico radar o
•	Lista de resultados
________________________________________
Captura de Pantalla
Aquí va la captura de resultados
<img width="986" height="1600" alt="image" src="https://github.com/user-attachments/assets/3f889ebd-0545-4c85-b1db-631dbb6dcf61" />
<img width="982" height="1600" alt="image" src="https://github.com/user-attachments/assets/bffcb80e-5e99-4d8a-9e47-1ea02f9d2f4f" />
<img width="1002" height="1600" alt="image" src="https://github.com/user-attachments/assets/71550152-8051-4e5c-8edf-978449ff8870" />
________________________________________
Comportamiento Según Rol
Profesor
Puede:
•	Crear evaluaciones
•	Configurar visibilidad
•	Ver analíticas
•	Ver desempeño por grupo
________________________________________
Estudiante
Puede:
•	Ver evaluaciones
•	Evaluar compañeros
•	Enviar evaluaciones
•	Ver resultados (si son públicos)
________________________________________
Integración con Brightspace
La aplicación permite sincronización con Brightspace LMS.
Incluye:
•	Importación de cursos
•	Importación de grupos
•	Asociación de evaluaciones
La sincronización se ejecuta desde el Dashboard con el botón:
Sync with Brightspace
________________________________________
Diseño de Interacciones
La aplicación utiliza transiciones estándar de Flutter:
•	Transiciones deslizantes
•	Transiciones suaves
•	Diálogos de confirmación
Principios UX:
•	Interacción simple
•	Acciones claras
•	Retroalimentación inmediata
________________________________________
Tecnologías
•	Flutter
•	Dart
•	Figma (Diseño UI/UX)

