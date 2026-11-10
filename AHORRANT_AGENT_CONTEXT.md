# Proyecto: App Ahorrant

**Estructuración integral del proyecto**\
Finanzas personales · Gamificación · Educación financiera

------------------------------------------------------------------------

## 1. Contexto general del proyecto

### 1.1. ¿Qué es App Ahorrant?

**App Ahorrant** es una aplicación móvil de educación y gestión de
finanzas personales dirigida principalmente a jóvenes universitarios
de Lima Metropolitana que tienen dificultades para controlar sus gastos cotidianos y
desarrollar hábitos de ahorro.

La propuesta consiste en mostrar automáticamente los ingresos y egresos detectables sin solicitar registro de cuenta, credenciales bancarias ni movimientos manuales. Busca convertir el seguimiento financiero en una
experiencia interactiva mediante una mascota virtual (una hormiga),
objetivos de ahorro, recompensas, desafíos diarios y educación
financiera.

A diferencia de las aplicaciones tradicionales que se concentran en
mostrar tablas, gráficos y estadísticas, Ahorrant busca que el usuario
se involucre con su economía a través de la gamificación.

**Experiencia de acceso:** el estudiante abre Ahorrant y accede directamente a Inicio, Hormiguero, Armario, Metas compartidas, Clases y Mi progreso. No se solicitan credenciales bancarias ni registro de cuenta. La detección en Android exige una autorización inicial explícita del usuario para acceder a notificaciones. Ahorrant es un visor y organizador de movimientos detectados: no retiene, transfiere ni modifica dinero.

### 1.2. Problemática identificada

Muchos estudiantes universitarios reciben dinero de sus padres, becas,
trabajos de medio tiempo o emprendimientos. Sin embargo, no siempre
tienen un control adecuado de cómo utilizan esos recursos.

Uno de los principales problemas son los llamados **gastos hormiga**:
pequeños desembolsos que parecen insignificantes individualmente, pero
que acumulados representan una cantidad considerable de dinero.

Ejemplos:

-   Comprar café o bebidas diariamente.
-   Comprar snacks durante las clases.
-   Pedir comida por aplicaciones sin planificación.
-   Realizar compras impulsivas.
-   Gastar pequeñas cantidades en entretenimiento.
-   Realizar pagos digitales sin llevar un registro.

El problema no es necesariamente la falta de ingresos, sino la falta de
visibilidad, planificación y constancia para administrar el dinero.

### 1.3. Público objetivo

**Usuarios principales:** jóvenes universitarios de Lima Metropolitana,
aproximadamente entre 17 y 26 años, que utilizan billeteras digitales y
realizan gastos frecuentes.

**Características:**

-   Utilizan Yape y Plin.
-   Realizan pagos digitales.
-   Tienen ingresos limitados o variables.
-   Quieren ahorrar, pero les cuesta mantener la disciplina.
-   Están familiarizados con aplicaciones y videojuegos.

### 1.4. Objetivo general

Desarrollar una aplicación móvil que permita a los jóvenes
universitarios de Lima Metropolitana identificar, controlar y reducir sus gastos
hormiga mediante herramientas de seguimiento financiero, gamificación y
educación financiera, incentivando la creación de hábitos de ahorro
sostenibles.

### 1.5. Objetivos específicos

1.  Visualizar automáticamente los movimientos de Yape que puedan detectarse en las notificaciones del dispositivo.
2.  Identificar los patrones de consumo y los gastos hormiga.
3.  Motivar el ahorro mediante una mascota virtual y recompensas.
4.  Permitir establecer metas financieras individuales y compartidas.
5.  Promover conocimientos financieros mediante microlecciones.
6.  Automatizar, cuando sea técnicamente posible, la detección de
    transacciones.
7.  Proporcionar estadísticas visuales sobre los hábitos financieros del
    usuario.

### 1.6. Propuesta de valor

> Transformar la invisibilidad de los microgastos y la dificultad para
> ahorrar de los universitarios de Lima Metropolitana en una experiencia interactiva
> y motivadora, utilizando detección inteligente de transacciones,
> gamificación y recompensas virtuales para construir hábitos
> financieros saludables.

------------------------------------------------------------------------

## 2. Concepto central: el universo de Ahorrant

La aplicación no debe sentirse como un banco ni como una hoja de
cálculo. Debe sentirse como un pequeño mundo que evoluciona según las
decisiones financieras del usuario.

La idea se construye alrededor de cuatro elementos:

  Elemento           Función
  ------------------ ----------------------------------------------------------
  La hormiga         Representa al usuario y su progreso.
  El hormiguero      Representa su desarrollo financiero.
  Los Hormigasoles   Son las monedas virtuales de recompensa.
  Las metas          Representan los objetivos de ahorro que quiere alcanzar.

La metáfora principal es sencilla: **cada buena decisión financiera
ayuda a construir y mejorar el hormiguero**.

La mascota no debe castigar al usuario por gastar. Su comportamiento
debe motivarlo a retomar sus objetivos sin generar culpa o ansiedad
financiera.

------------------------------------------------------------------------

## 3. Estructura funcional: pestañas y módulos de la aplicación

La aplicación se divide en seis módulos principales. Cada uno tiene una
responsabilidad específica, pero todos se conectan mediante el sistema
de usuarios, transacciones, progreso y recompensas.

### 3.1. Módulo 1: Inicio -- Panel inteligente de notificaciones

Es la pantalla principal de Ahorrant. Su propósito es mostrar al usuario
qué está sucediendo con sus finanzas y facilitar el registro de cada
movimiento.

**Componentes principales:**

1.  **Resumen financiero:** muestra los gastos registrados, el ahorro
    acumulado y el presupuesto disponible.
2.  **Centro de notificaciones:** presenta las transacciones detectadas
    por los mecanismos de integración.
3.  **Clasificación rápida:** permite identificar si una transacción
    corresponde a un gasto necesario, gasto hormiga, entretenimiento u
    otra categoría.
4.  **Movimientos recientes:** muestra los últimos ingresos y egresos
    registrados.
5.  **Acceso a la mascota:** permite visualizar rápidamente el estado
    del hormiguero.

**Ejemplo de funcionamiento:**

Un estudiante realiza una transferencia de S/ 8.00 mediante Yape para
comprar un café. Ahorrant recibe una notificación compatible y muestra
una solicitud de confirmación:

-   Pago mediante Yape.
-   Monto: S/ 8.00.
-   Pregunta: «¿Qué tipo de gasto fue?».
-   Opciones: gasto hormiga, transporte necesario, compra necesaria u
    otro tipo de gasto.

**Resultado esperado:** el usuario clasifica el movimiento en pocos
segundos y la información pasa al registro financiero y al sistema de
gamificación.

### 3.2. Módulo 2: Hormiguero -- Gamificación y mascota virtual

Este es el elemento diferenciador de Ahorrant. La mascota representa el
comportamiento financiero del usuario.

#### A. Mascota virtual

La hormiga tiene diferentes estados visuales según el progreso:

-   **Feliz:** el usuario está cumpliendo sus objetivos.
-   **Motivada:** mantiene una buena racha.
-   **Descansando:** el usuario tiene días sin registrar actividad.
-   **Animada:** consigue una meta o una recompensa.

No se busca que la mascota enferme o sufra por una compra. La
gamificación debe ser positiva.

#### B. Sistema de rachas

Se implementa un mecanismo parecido al de Duolingo.

  -----------------------------------------------------------------------
  Día                     Actividad               Resultado
  ----------------------- ----------------------- -----------------------
  Lunes                   Cumplió su objetivo     Racha +1
                          diario                  

  Martes                  Evitó un gasto          Racha +1
                          impulsivo               

  Miércoles               Alcanzó su meta         Racha +1

  Jueves                  No cumplió el objetivo  Se pausa o reinicia
                                                  según las reglas
  -----------------------------------------------------------------------

La racha debe basarse en objetivos configurados por el usuario, no en la
obligación de no gastar.

#### C. Sistema de Hormigasoles

Los Hormigasoles son monedas virtuales que se obtienen mediante
actividades positivas.

  Acción                                 Recompensa propuesta
  ------------------------------------ ----------------------
  Cumplir el objetivo diario                            10 HS
  Registrar todos los gastos del día                     5 HS
  Completar una microlección                            15 HS
  Cumplir una meta semanal                              30 HS
  Participar en un desafío                              10 HS

HS significa Hormigasoles. Las recompensas son valores de ejemplo y
deben configurarse mediante reglas de negocio. No representan dinero
real ni deben confundirse con el ahorro bancario.

#### D. Evolución del hormiguero

La mascota y su entorno pueden mejorar por niveles:

1.  Hormiguero inicial.
2.  Hormiguero en crecimiento.
3.  Hormiguero organizado.
4.  Hormiguero avanzado.
5.  Hormiguero desarrollado.

Cada nivel desbloquea elementos visuales, animaciones y posibilidades de
personalización.

### 3.3. Módulo 3: Armario -- Tienda virtual

El armario funciona como una tienda interna en la que el usuario utiliza
sus Hormigasoles para personalizar a su mascota.

**Características:**

-   Catálogo de accesorios.
-   Ropa para la hormiga.
-   Decoraciones para el hormiguero.
-   Elementos especiales.
-   Sistema de niveles y artículos desbloqueables.
-   Inventario de objetos adquiridos.

**Ejemplo de catálogo:**

  Artículo                   Precio
  ------------------------ --------
  Sombrero de explorador      50 HS
  Mochila aventurera          80 HS
  Gafas de sol                40 HS
  Casa de madera             150 HS
  Jardín decorativo          200 HS

**Reglas de funcionamiento:**

-   El usuario solo puede comprar artículos con suficientes
    Hormigasoles.
-   Una compra descuenta monedas virtuales, nunca dinero real.
-   Los artículos comprados permanecen en su inventario.
-   Los artículos equipados modifican la apariencia de la mascota o el
    hormiguero.

### 3.4. Módulo 4: Metas compartidas -- Ahorro colaborativo

Este módulo permite que dos o más usuarios establezcan una meta
financiera conjunta.

Por ejemplo, dos amigos desean reunir S/ 1,000 para realizar un viaje.

**Funcionamiento:**

1.  Un usuario crea una meta.
2.  Define el nombre, monto objetivo y fecha límite.
3.  La aplicación genera un enlace de invitación.
4.  Otra persona ingresa mediante el enlace.
5.  Ambos registran sus aportes individuales.
6.  La aplicación consolida el progreso compartido.

**Ejemplo de meta:**

-   Nombre: Viaje a Cusco.
-   Objetivo: S/ 1,000.
-   Progreso: S/ 650.
-   Avance: 65%.
-   Aporte del usuario 1: S/ 400.
-   Aporte del usuario 2: S/ 250.

**Funciones adicionales:**

-   Rachas compartidas.
-   Recordatorios de metas.
-   Registro individual de aportes.
-   Historial de contribuciones.
-   Barra de progreso conjunta.
-   Mensajes de motivación.
-   Fecha estimada de cumplimiento.

**Regla fundamental:** Ahorrant no almacena ni transfiere el dinero de
los participantes. Cada usuario conserva su dinero en su propia cuenta
bancaria o billetera digital. La aplicación registra los avances
declarados o verificados mediante integraciones disponibles.

### 3.5. Módulo 5: Clases -- Educación financiera

Su finalidad es enseñar a los estudiantes conceptos financieros que
puedan aplicar en su vida cotidiana.

**Categorías educativas:**

  Categoría              Contenido
  ---------------------- ---------------------------------------------
  Ahorro                 Cómo organizar el dinero y crear objetivos.
  Presupuesto            Cómo distribuir los ingresos.
  Tarjetas               Diferencias entre débito y crédito.
  Billeteras digitales   Uso responsable de Yape y Plin.
  Deudas                 Intereses, cuotas y endeudamiento.
  Consumo                Cómo evitar compras impulsivas.

**Funcionamiento:**

1.  El usuario ingresa a Clases.
2.  Selecciona una categoría.
3.  Visualiza una microlección o video.
4.  Responde preguntas de comprensión.
5.  Recibe Hormigasoles al completar la actividad.

Se pueden implementar niveles de aprendizaje:

-   Principiante.
-   Intermedio.
-   Avanzado.

La idea es que la educación financiera no sea una obligación académica,
sino otra forma de progresar dentro de la aplicación.

### 3.6. Módulo 6: Mi progreso -- Estadísticas financieras

Este módulo permite que el estudiante comprenda cómo está utilizando su
dinero.

**Información que presenta:**

-   Total de ingresos registrados.
-   Total de gastos.
-   Gastos hormiga acumulados.
-   Gastos necesarios.
-   Ahorro registrado.
-   Comparación entre semanas y meses.
-   Categorías en las que más gasta.
-   Evolución de sus metas.

**Ejemplo de distribución mensual:**

  Categoría               Gastos
  ----------------- ------------
  Alimentación            S/ 180
  Transporte               S/ 90
  Entretenimiento          S/ 75
  Gastos hormiga          S/ 120
  Otros                    S/ 85
  **Total**           **S/ 550**

También puede mostrar recomendaciones como:

-   Tu mayor gasto está relacionado con alimentación.
-   Tus gastos hormiga aumentaron respecto a la semana anterior.
-   Has reducido tus compras impulsivas.
-   Estás cerca de cumplir tu meta mensual.

------------------------------------------------------------------------

## 4. Funcionamiento inteligente: detección de transacciones

Esta parte representa uno de los componentes técnicos más importantes
del proyecto.

La intención es que Ahorrant no requiera ingresar manualmente los movimientos: mostrará los datos que puedan obtenerse de las notificaciones autorizadas de Android. La ausencia de una notificación legible implica que el movimiento puede no aparecer en el aplicativo.

### 4.1. Primera fuente: notificaciones de billeteras digitales

Ahorrant priorizará la detección de movimientos de Yape, tanto dinero
enviado como recibido, a partir de notificaciones disponibles en Android.
Plin podría incorporarse en una etapa posterior.

En Android, se puede implementar un servicio basado en
`NotificationListenerService`.

Este servicio permite recibir eventos de las notificaciones del
dispositivo cuando el usuario concede el acceso correspondiente. El
contenido disponible depende de lo que cada aplicación publique en su
notificación.

**Proceso:**

1.  El usuario autoriza el acceso a notificaciones.
2.  Ahorrant identifica las notificaciones provenientes de aplicaciones
    compatibles.
3.  Analiza el contenido disponible.
4.  Intenta extraer monto, fecha, tipo de operación y descripción.
5.  Determina si se trata de un ingreso (dinero recibido) o egreso
    (dinero enviado), solo si el texto disponible permite distinguirlo.
6.  Comprueba posibles duplicados y descarta eventos sin monto o dirección fiables.
7.  Guarda el movimiento detectado en Supabase (PostgreSQL) y lo muestra
    automáticamente como ingreso o egreso en Ahorrant.
8.  Si falta información, lo marca como no verificado o no lo incorpora
    a los totales para evitar cifras engañosas.

**Restricción de alcance:** este mecanismo no accede al saldo ni al
historial interno de Yape. Solo procesa información visible en las
notificaciones que Android entregue, con consentimiento del usuario.
Es necesario validar en dispositivos reales los formatos de avisos
para pagos enviados y recibidos, ya que no se garantiza que ambas
operaciones generen notificaciones con monto identificable. No se exigirá registro manual de movimientos; por ello, el historial puede ser incompleto.

### 4.2. Segunda fuente: correos electrónicos bancarios

Algunos bancos envían correos cuando se realiza una compra con tarjeta.

Ahorrant podría integrar un sistema de conexión con correo electrónico
mediante autorización del usuario.

**Flujo:**

1.  El usuario conecta su cuenta de correo.
2.  Autoriza los permisos necesarios.
3.  El sistema identifica mensajes que correspondan a alertas bancarias.
4.  Extrae los datos de la transacción.
5.  Detecta posibles movimientos duplicados.
6.  Solicita confirmación o registra el movimiento según las reglas
    configuradas.

La integración podría desarrollarse mediante una API de correo, por
ejemplo, Gmail API, con autorización OAuth.

### 4.3. Clasificación inteligente

No todas las transacciones son gastos hormiga. Por eso, el sistema debe
diferenciar entre detección y clasificación.

  Transacción             Clasificación sugerida
  ----------------------- ------------------------
  Café de S/ 8            Gasto hormiga
  Pasaje de S/ 3          Transporte necesario
  Compra de alimentos     Alimentación
  Pago de universidad     Educación
  Suscripción de música   Entretenimiento

La aplicación puede sugerir una categoría utilizando reglas y patrones
anteriores, pero el usuario debe poder corregirla.

### 4.4. Limitaciones técnicas importantes

Hay tres aspectos que deben considerarse desde el diseño:

-   **Android:** permite desarrollar un lector de notificaciones con
    autorización del usuario. Sin embargo, el contenido depende de lo
    que cada aplicación publique en su notificación. No garantiza que
    siempre aparezca el importe o toda la información.
-   **iOS:** no ofrece un mecanismo público equivalente para que una
    aplicación lea libremente las notificaciones privadas de otras
    aplicaciones. Por eso, la detección automática no debe prometerse de
    la misma manera en iPhone.
-   **Correos:** requieren autorización e integración con el proveedor
    de correo. No todos los bancos envían alertas y no todos los correos
    tienen un formato uniforme.

Por lo tanto, se recomienda plantear inicialmente Ahorrant para
**Android**, con detección basada en notificaciones y una arquitectura que permita agregar otras integraciones posteriormente. Los montos detectados no equivalen al saldo real de Yape.

También conviene reemplazar la idea de una ventana flotante obligatoria
por una notificación propia o una pantalla de confirmación dentro de
Ahorrant. Así se evitan dependencias innecesarias de permisos de
superposición.

------------------------------------------------------------------------

## 5. Lógica de negocio: ¿cómo se relacionan los módulos?

La aplicación debe funcionar como un sistema conectado. No basta con
desarrollar pestañas independientes: las acciones que realiza el usuario
deben producir cambios en diferentes partes de la aplicación.

### 5.1. Flujo general de funcionamiento

1.  **El usuario realiza una operación en Yape:** envía o recibe dinero.
2.  **Ahorrant detecta el movimiento:** únicamente cuando Android entrega
    una notificación compatible con datos suficientes.
3.  **Clasifica la transacción:** gasto hormiga, necesario u otra
    categoría.
4.  **Registra los datos:** actualiza el historial financiero.
5.  **Actualiza la gamificación:** modifica mascota, rachas y
    recompensas.
6.  **Actualiza las estadísticas:** recalcula gastos y progreso.

### 5.2. Reglas de negocio fundamentales

  -----------------------------------------------------------------------
  Código                              Regla de negocio
  ----------------------------------- -----------------------------------
  RN01                                Todo movimiento debe pertenecer a
                                      un usuario.

  RN02                                Los movimientos deben clasificarse
                                      por categorías.

  RN03                                Una transacción detectada debe
                                      poder confirmarse o corregirse.

  RN04                                No se deben registrar dos veces
                                      movimientos duplicados.

  RN05                                Las monedas virtuales no
                                      representan dinero real.

  RN06                                Las recompensas se calculan según
                                      las actividades realizadas.

  RN07                                Las compras del armario solo se
                                      permiten si hay saldo virtual
                                      suficiente.

  RN08                                Las metas compartidas deben
                                      registrar los aportes de cada
                                      participante.

  RN09                                Los participantes conservan su
                                      dinero en sus propias cuentas.

  RN10                                El usuario puede consultar y
                                      corregir su historial financiero.

  RN11                                Las estadísticas deben calcularse a
                                      partir de los movimientos
                                      registrados.

  RN12                                El usuario debe poder desactivar
                                      las integraciones automáticas.
  -----------------------------------------------------------------------

### 5.3. Distinción: ahorro real y ahorro virtual

Este punto debe quedar muy claro en el proyecto.

Ahorrant no mueve dinero del banco ni genera ahorro bancario
automáticamente.

Por ejemplo:

-   El usuario decide no comprar un café de S/ 8.
-   Registra que evitó ese gasto.
-   Ahorrant puede contabilizar S/ 8 como gasto evitado.
-   Puede otorgarle 8 Hormigasoles, si cumple las condiciones de
    recompensa.

Sin embargo, los S/ 8 no se convierten automáticamente en dinero
guardado.

Por eso, la aplicación debe diferenciar:

  -----------------------------------------------------------------------
  Concepto                            Significado
  ----------------------------------- -----------------------------------
  Ahorro real registrado              Dinero que el usuario declara haber
                                      separado o reservado.

  Gasto evitado                       Dinero que decidió no gastar.

  Hormigasoles                        Recompensas virtuales de la
                                      aplicación.

  Ahorro bancario                     Dinero que realmente permanece en
                                      su cuenta o instrumento de ahorro.
  -----------------------------------------------------------------------

Esta distinción evita confusiones y permite presentar estadísticas
financieras honestas.

------------------------------------------------------------------------

## 6. Arquitectura tecnológica propuesta

Para desarrollar Ahorrant, se recomienda una arquitectura
cliente-servidor con un componente nativo de Android para la detección
de notificaciones.

### 6.1. Componentes tecnológicos

  -----------------------------------------------------------------------
  Componente              Tecnología propuesta    Responsabilidad
  ----------------------- ----------------------- -----------------------
  Aplicación móvil        Flutter                 Interfaz y navegación.

  Servicio Android        Kotlin                  Lectura de
                                                  notificaciones
                                                  autorizadas.

  Backend                 Spring Boot + Java      Reglas de negocio y API
                                                  REST.

  Base de datos           Supabase PostgreSQL     Almacenamiento de
                                                  movimientos y progreso.

  Almacenamiento local    SQLite                  Historial disponible
                                                  sin conexión.

  Sincronización          Cola local + Supabase   Envío de movimientos
                                                  pendientes al reconectar.

  Identidad técnica       Supabase Auth anónima   Identificador interno
                                                  sin pantalla de registro.

  Almacenamiento          Supabase Storage        Imágenes y recursos
  multimedia                                      educativos.

  Notificaciones          Firebase Cloud          Notificaciones propias
                          Messaging               de Ahorrant.

  Integración de correo   Gmail API               Lectura autorizada de
                                                  alertas bancarias de
                                                  Gmail.
  -----------------------------------------------------------------------

Supabase será la base de datos central del proyecto. No habrá pantalla de registro ni inicio de sesión. Para aislar la información de cada instalación, se propone una identidad técnica anónima de Supabase Auth con RLS; esto no solicita correo ni contraseña al estudiante. Hay que diseñar qué sucede con el historial si se desinstala la aplicación o se cambia de teléfono. Las transacciones detectadas se registrarán en PostgreSQL con acceso restringido a su identidad técnica.
Supabase Realtime permitirá reflejar en la interfaz los cambios
guardados, pero no detecta por sí solo los pagos en Yape.

### 6.1.1. Arquitectura híbrida confirmada: SQLite y Supabase

**Decisión del proyecto:** Ahorrant utilizará almacenamiento local SQLite y
Supabase PostgreSQL con **una identidad anónima independiente por instalación**.
La aplicación se abrirá directamente en sus módulos: no habrá pantalla de
registro, correo, contraseña ni solicitud de credenciales de Yape.

**Flujo de almacenamiento y sincronización:**

1. Al abrir la aplicación por primera vez, se inicializa la base de datos
   local y, cuando existe conexión, se crea una sesión anónima con Supabase Auth.
2. Android solicita permiso explícito para acceder a las notificaciones; no
   se asume que todas las operaciones de Yape generarán avisos legibles.
3. Cuando se detecta un movimiento compatible, se registra en SQLite con
   identificador único, importe, fecha, tipo de operación, origen y estado de
   sincronización. Solo se conserva la información necesaria para el seguimiento.
4. La pantalla de Inicio, el historial y las estadísticas consultan el
   almacenamiento local, de modo que la aplicación funciona sin internet.
5. Cuando existe conexión, una cola de sincronización envía los movimientos
   pendientes a Supabase; se aplican operaciones idempotentes para evitar duplicados.
6. Supabase restringe cada registro a la identidad anónima propietaria mediante
   políticas Row Level Security (RLS). El sistema descarga únicamente los datos
   permitidos para esa misma identidad y reconcilia los cambios con SQLite.
7. La sesión anónima se conserva de forma segura en el dispositivo; al reabrir
   la aplicación se reutiliza, sin crear una identidad nueva cada vez.

**Aislamiento:** cada instalación tiene su historial de ingresos, egresos,
metas, Hormigasoles y estadísticas. Todos usan el mismo proyecto Supabase,
pero no pueden leer los movimientos de otras instalaciones.

**Límite de recuperación:** la cuenta anónima no permite recuperar el acceso
al historial al cambiar de teléfono, cerrar sesión o perder los datos locales
de la aplicación. El respaldo en Supabase no equivale a una recuperación
multidispositivo. No se promete restauración automática tras desinstalar.

**Seguridad y alcance:** Ahorrant no consulta saldos bancarios, no mueve dinero,
no solicita credenciales de Yape y no garantiza un historial exhaustivo: solo
refleja las transacciones que pueda detectar y verificar a partir de
notificaciones compatibles. El balance mostrado es un cálculo de movimientos
registrados, no el saldo real en Yape.


Flutter es una alternativa conveniente porque permite construir una
interfaz multiplataforma, mientras que Kotlin puede encargarse de las
funcionalidades nativas específicas de Android.

La elección de tecnologías es una propuesta, no una obligación. Si el
proyecto académico requiere Angular, también se podría desarrollar una
versión web complementaria, aunque no tendría acceso directo al lector
de notificaciones nativo del smartphone.

### 6.2. Arquitectura por capas

El backend puede organizarse de la siguiente manera:

**1. Capa de presentación**

-   Controladores REST.
-   Endpoints.
-   Validación de solicitudes.

**2. Capa de lógica de negocio**

-   Servicios de transacciones.
-   Servicios de gamificación.
-   Servicios de metas.
-   Servicios de recompensas.
-   Servicios de educación financiera.

**3. Capa de persistencia**

-   Entidades.
-   Repositorios.
-   Consultas a Supabase PostgreSQL.

**4. Capa de seguridad**

-   Autenticación.
-   Autorización.
-   Protección de datos.
-   Gestión de sesiones.

### 6.3. Estructura de módulos del backend

``` text
ahorrant-backend/
│
├── auth/
│   ├── controller/
│   ├── service/
│   └── dto/
│
├── users/
├── transactions/
├── categories/
├── budgets/
├── savings/
├── gamification/
│   ├── ant/
│   ├── streaks/
│   └── hormigasoles/
│
├── store/
├── inventory/
├── shared-goals/
├── education/
├── notifications/
├── integrations/
│   ├── android/
│   ├── email/
│   └── wallets/
│
└── config/
```

### 6.4. Modelo de base de datos

Las entidades principales podrían ser las siguientes:

  Entidad               Información que almacena
  --------------------- -------------------------------------------------
  Usuario               Datos personales, correo y contraseña cifrada.
  Transacción           Monto, fecha, descripción, ingreso/egreso,
                        origen (Yape/manual) y estado de confirmación.
  Categoría             Alimentación, transporte, entretenimiento, etc.
  Presupuesto           Límites de gasto definidos por el usuario.
  MetaAhorro            Objetivos financieros individuales.
  AporteMeta            Aportes registrados a cada meta.
  MetaCompartida        Objetivos vinculados a varios usuarios.
  ParticipanteMeta      Relación entre usuarios y metas compartidas.
  Mascota               Estado, nivel y personalización de la hormiga.
  Racha                 Días consecutivos de cumplimiento.
  Hormigasol            Saldo de monedas virtuales.
  HistorialRecompensa   Monedas ganadas o gastadas.
  ProductoTienda        Artículos disponibles en el armario.
  Inventario            Objetos adquiridos por cada usuario.
  Lección               Contenido educativo.
  ProgresoLección       Lecciones completadas por usuario.
  Notificación          Alertas generadas por Ahorrant.
  Integración           Fuentes externas autorizadas por el usuario.

**Relaciones importantes:**

-   Un usuario tiene muchas transacciones.
-   Una transacción pertenece a una categoría.
-   Un usuario puede tener varias metas.
-   Una meta compartida puede tener varios participantes.
-   Un usuario tiene una mascota.
-   Un usuario puede obtener muchas recompensas.
-   Un usuario puede adquirir varios productos.
-   Un usuario puede completar varias lecciones.

------------------------------------------------------------------------

## 7. Seguridad y protección de información

Debido a que Ahorrant trabaja con información financiera, la seguridad
debe considerarse desde el principio.

Los principales aspectos son:

1.  **Acceso sin registro visible:** la aplicación abre directamente sus módulos.
2.  **Identidad interna:** usar sesiones anónimas seguras de Supabase Auth, sin solicitar correo, contraseña ni datos bancarios.
3.  **RLS:** restringir cada registro al identificador técnico correspondiente.
4.  **Persistencia local:** proteger la base SQLite y conservar de forma segura la sesión anónima.
5.  **Sincronización:** enviar movimientos pendientes sin duplicarlos y mantener datos separados por identidad.
4.  **Privacidad:** solicitar únicamente los permisos necesarios.
5.  **Consentimiento:** informar qué datos se recopilan y para qué se
    utilizan.
6.  **Cifrado:** proteger información sensible durante su transmisión y
    almacenamiento.
7.  **Control de acceso:** un usuario no puede consultar movimientos
    privados de otro.
8.  **Desconexión:** permitir revocar el acceso a las integraciones.
9.  **Eliminación:** permitir que el usuario solicite la eliminación de
    su información conforme a las obligaciones legales aplicables.

En Perú, también se debe considerar la Ley N.º 29733, Ley de Protección
de Datos Personales, y su reglamentación vigente.

------------------------------------------------------------------------

## 8. Usuarios y roles del sistema

La aplicación puede manejar los siguientes perfiles:

  -----------------------------------------------------------------------
  Rol                                 Responsabilidades
  ----------------------------------- -----------------------------------
  Usuario universitario               Consulta movimientos detectados,
                                      sigue metas y aprende.

  Administrador                       Gestiona usuarios, categorías,
                                      contenido y artículos de la tienda.

  Editor de contenido                 Administra las clases, videos y
                                      materiales educativos.
  -----------------------------------------------------------------------

El administrador no debería tener acceso indiscriminado a los
movimientos financieros privados de los usuarios.

------------------------------------------------------------------------

## 9. Alcance del proyecto: ¿qué se desarrollará primero?

Se recomienda no intentar construir todas las funcionalidades al mismo
tiempo. Ahorrant tiene varios componentes y algunos presentan una
dificultad técnica considerable.

Conviene dividir su desarrollo en tres niveles.

### 9.1. Primera versión (MVP) -- Prioridad alta

Es la primera versión funcional que permite demostrar el valor del
proyecto.

-   Apertura directa de la aplicación, sin formulario de registro ni inicio de sesión.
-   Solicitud de acceso a notificaciones de Android, solo con consentimiento.
-   Detección automática de ingresos y egresos de Yape, cuando el contenido de las notificaciones lo permita.
-   Clasificación sugerida de movimientos detectados.
-   Panel financiero.
-   Mascota virtual básica.
-   Hormigasoles y rachas.
-   Metas individuales.

### 9.2. Segunda versión -- Prioridad media

Incorpora más elementos de gamificación y colaboración.

-   Armario y tienda virtual.
-   Inventario de accesorios.
-   Metas compartidas.
-   Rachas conjuntas.
-   Clases financieras.
-   Estadísticas avanzadas.

### 9.3. Tercera versión -- Desarrollo avanzado

Busca mejorar la detección ya incluida desde la primera versión.

-   Mejoras del lector de notificaciones Android.
-   Ampliación de tipos de transacciones compatibles.
-   Integración con correo electrónico.
-   Clasificación automática sugerida.
-   Detección de movimientos duplicados.
-   Recomendaciones financieras inteligentes.

Esta división permite que Ahorrant tenga una primera versión demostrable
sin depender desde el inicio de integraciones bancarias directas. La lectura de notificaciones de Yape sí forma parte del MVP y requiere validación real.

------------------------------------------------------------------------

## 10. Requerimientos del sistema

Para documentar el proyecto académicamente, es importante separar los
requerimientos funcionales de los no funcionales.

### 10.1. Requerimientos funcionales

  -----------------------------------------------------------------------
  Código                              Requerimiento
  ----------------------------------- -----------------------------------
  RF01                                La aplicación abrirá sus módulos
                                      sin registro ni inicio de sesión.

  RF02                                El sistema solicitará autorización
                                      para leer notificaciones Android.

  RF03                                El sistema mostrará ingresos y
                                      egresos detectados desde Yape.

  RF04                                El sistema permitirá clasificar
                                      transacciones por categorías.

  RF05                                El sistema permitirá identificar
                                      gastos hormiga.

  RF06                                El usuario podrá establecer
                                      presupuestos.

  RF07                                El sistema mostrará estadísticas
                                      financieras.

  RF08                                El sistema permitirá visualizar y
                                      personalizar una mascota virtual.

  RF09                                El sistema otorgará Hormigasoles
                                      por actividades completadas.

  RF10                                El usuario podrá comprar accesorios
                                      en la tienda virtual.

  RF11                                El usuario podrá establecer metas
                                      individuales.

  RF12                                El sistema permitirá crear metas
                                      compartidas.

  RF13                                El sistema permitirá invitar
                                      participantes mediante enlaces.

  RF14                                El usuario podrá consultar clases
                                      de educación financiera.

  RF15                                El sistema registrará el progreso
                                      educativo.

  RF16                                El sistema podrá detectar
                                      transacciones mediante
                                      integraciones autorizadas.

  RF17                                El usuario podrá confirmar y
                                      corregir las transacciones
                                      detectadas.

  RF18                                El sistema enviará notificaciones y
                                      recordatorios.
  -----------------------------------------------------------------------

### 10.2. Requerimientos no funcionales

-   **Seguridad:** proteger las credenciales y la información
    financiera.
-   **Usabilidad:** ofrecer una interfaz sencilla e intuitiva.
-   **Rendimiento:** cargar rápidamente los módulos principales.
-   **Disponibilidad:** permitir el acceso al sistema cuando el usuario
    lo necesite.
-   **Escalabilidad:** facilitar la incorporación de nuevos módulos.
-   **Compatibilidad:** funcionar en los dispositivos y versiones de
    sistema operativo definidos para el proyecto.
-   **Mantenibilidad:** utilizar una arquitectura modular.
-   **Privacidad:** garantizar el consentimiento y control sobre los
    datos personales.

------------------------------------------------------------------------

## 11. Riesgos y posibles dificultades

  -----------------------------------------------------------------------
  Riesgo                  Consecuencia            Solución propuesta
  ----------------------- ----------------------- -----------------------
  Restricciones de        La detección automática Priorizar Android y
  Android/iOS             puede no funcionar en   señalar movimientos
                          todos los dispositivos. no detectados.

  Cambios en              El sistema podría dejar Crear adaptadores y
  notificaciones de Yape  de interpretar algunos  validar formatos.
  o Plin                  movimientos.            

  Movimientos duplicados  Estadísticas            Implementar mecanismos
                          financieras             de detección de
                          incorrectas.            duplicados.

  Clasificaciones         Datos financieros poco  Permitir confirmación y
  incorrectas             confiables.             corrección.

  Abandono de la          El usuario deja de      Incorporar retos y
  aplicación              utilizarla.             recompensas
                                                  equilibradas.

  Uso indebido de datos   Riesgos de privacidad.  Aplicar seguridad,
                                                  consentimiento y
                                                  controles de acceso.

  Complejidad del         Retrasos en la entrega. Dividir el proyecto en
  desarrollo                                      versiones y
                                                  entregables.
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## 12. Indicadores para medir el éxito del proyecto

Ahorrant no debe medir su éxito únicamente por la cantidad de usuarios
registrados. También debe evaluar si realmente ayuda a mejorar sus
hábitos financieros.

  -----------------------------------------------------------------------
  Indicador                           Qué permite medir
  ----------------------------------- -----------------------------------
  Usuarios activos                    Nivel de utilización de la
                                      aplicación.

  Transacciones registradas           Cantidad de movimientos
                                      controlados.

  Gastos hormiga identificados        Capacidad de reconocer pequeños
                                      gastos.

  Metas completadas                   Efectividad del seguimiento de
                                      objetivos.

  Rachas mantenidas                   Constancia en los hábitos de
                                      ahorro.

  Lecciones completadas               Participación en educación
                                      financiera.

  Retención de usuarios               Capacidad de mantener usuarios
                                      activos.

  Transacciones corregidas            Calidad de las sugerencias
                                      automáticas.
  -----------------------------------------------------------------------

Los indicadores deben tener metas cuantificables una vez que se realicen
las pruebas con estudiantes.

------------------------------------------------------------------------

## 13. Visión futura del proyecto

Ahorrant puede evolucionar más allá de una aplicación para registrar
gastos.

En futuras versiones podría incorporar:

-   Inteligencia artificial para analizar patrones de consumo.
-   Recomendaciones personalizadas de ahorro.
-   Predicción de gastos mensuales.
-   Desafíos financieros entre amigos.
-   Integraciones adicionales con entidades financieras.
-   Reconocimientos por objetivos cumplidos.
-   Nuevas mascotas y entornos personalizables.
-   Paneles de educación financiera adaptados al comportamiento del
    estudiante.

La visión a largo plazo es convertir Ahorrant en una plataforma de
acompañamiento financiero para jóvenes, donde aprender, ahorrar y
controlar los gastos sea parte de una misma experiencia.

------------------------------------------------------------------------

## 14. Resumen de la identidad del proyecto

  -----------------------------------------------------------------------
  Aspecto                             Definición
  ----------------------------------- -----------------------------------
  Nombre                              App Ahorrant

  Tipo                                Aplicación móvil

  Sector                              Finanzas personales y educación
                                      financiera

  Público                             Jóvenes universitarios de Lima Metropolitana

  Problema                            Falta de control de gastos
                                      cotidianos y dificultad para
                                      ahorrar

  Solución                            Seguimiento financiero gamificado

  Diferenciador                       Mascota virtual, Hormigasoles y
                                      detección inteligente

  Modelo de uso                       Aplicación de gestión y aprendizaje

  Objetivo                            Desarrollar hábitos financieros
                                      saludables
  -----------------------------------------------------------------------

### Seis pilares del proyecto

1.  **Detección:** identificación y registro de movimientos.
2.  **Gamificación:** mascota, hormiguero y rachas.
3.  **Recompensas:** Hormigasoles y tienda virtual.
4.  **Colaboración:** metas compartidas.
5.  **Educación:** microlecciones financieras.
6.  **Seguimiento:** estadísticas y progreso.

------------------------------------------------------------------------

## 15. ¿Cómo presentar y desarrollar este proyecto?

Se recomienda estructurarlo académicamente en este orden:

1.  **Planteamiento del problema:** explicar los gastos hormiga y la
    falta de hábitos de ahorro en universitarios.
2.  **Justificación:** explicar por qué es necesario desarrollar
    Ahorrant.
3.  **Objetivos:** establecer el objetivo general y los específicos.
4.  **Público objetivo:** describir a los estudiantes que utilizarán la
    aplicación.
5.  **Propuesta de valor:** explicar qué hace diferente a Ahorrant.
6.  **Alcance:** establecer qué funcionalidades se desarrollarán.
7.  **Requerimientos:** documentar las funcionalidades y características
    del sistema.
8.  **Diseño UX/UI:** diseñar las pantallas y navegación.
9.  **Arquitectura:** definir frontend, backend, base de datos e
    integraciones.
10. **Desarrollo:** implementar los módulos progresivamente.
11. **Pruebas:** comprobar el funcionamiento y la experiencia del
    usuario.
12. **Validación:** evaluar si la aplicación realmente ayuda a controlar
    los gastos.

### Recomendación estratégica

Se recomienda empezar construyendo el registro financiero, la
clasificación de gastos, el hormiguero y las recompensas. Esos cuatro
elementos conforman el corazón de Ahorrant.

La detección de notificaciones de Yape será una función central desde el prototipo Android; debe validarse con pruebas reales antes de considerarla operativa.

El aplicativo no manejará dinero, no ejecutará transferencias, no solicitará credenciales de Yape ni tendrá acceso al saldo real. Sus estadísticas solo reflejarán las operaciones efectivamente detectadas y no deberán presentarse como un estado de cuenta completo.

------------------------------------------------------------------------

**Identidad de Ahorrant:** *Pequeños ahorros, grandes hormigueros.*
