# Plan Scrum: App Ahorrant - 4 Días

## Objeto
Desarrollar un MVP (Minimum Viable Product) funcional de la aplicación Ahorrant en 4 días, enfocado en el flujo financiero básico y gamificación elemental para validar el concepto con usuarios universitarios.

---

## Equipo y Roles

| Rol | Responsabilidad |
|-----|-----------------|
| **Product Owner** | Definir historias de usuario, validar con usuarios objetivo |
| **Scrum Master** | Facilitate daily standups, remover impedimentos |
| **Desarrollador Flutter** | Interfaz de usuario, navegación, lógica de negocio cliente |
| **Desarrollador Kotlin (Android)** | NotificationListenerService, integración nativa |
| **Desarrollador Backend** | Supabase, RLS, APIs REST |

---

## Sprint Backlog (Historias por Día)

### Día 1: Fundamentos y Setup
| ID | Historia | Estimación | Acceptance Criteria |
|----|----------|------------|---------------------|
| H01 | Apertura directa app sin registro | 8h | App inicia en Módulo Inicio, sin pantallas de login/registro |
| H02 | Permisos notificaciones Android | 6h | Solicitud de permiso al iniciar, manejo graceful si deniega |
| H03 | Configurar Supabase anónimo | 4h | Proyecto Supabase creado, RLS policies activas |
| H04 | Estructura 6 pestañas navigation | 6h | Bottom navigation: Inicio, Hormiguero, Armario, Metas, Clases, Progreso |

**Del Día 1:**
- ✅ Repositorio Flutter configurado
- ✅ Pantalla de inicio con solicitud permisos
- ✅ Estructura de navegación básica
- ✅ Proyecto Supabase inicial

### Día 2: Flujo Financiero Básico
| ID | Historia | Estimación | Acceptance Criteria |
|----|----------|------------|---------------------|
| H05 | Detección Yape desde notificaciones | 10h | Servicio Kotlin captura notificaciones, extrae monto/descripción |
| H06 | Clasificación movimientos | 6h | Selector: gasto hormiga / necesario / otro tipo |
| H07 | Panel financiero resumen | 4h | Tarjetas: ingresos totales, egresos acumulados, presupuesto disponible |
| H08 | SQLite local sincronización | 8h | Movimientos guardados localmente, cola de sincronización Supabase |

**Del Día 2:**
- ✅ NotificationListenerService implementado y probado
- ✅ Movimientos clasificados y guardados en SQLite
- ✅ Panel financiero con estadísticas básicas
- ✅ Sincronización background funcional

### Día 3: Gamificación Básica
| ID | Historia | Estimación | Acceptance Criteria |
|----|----------|------------|---------------------|
| H09 | Mascota virtual 4 estados | 8h | Hormiga muestra: feliz / motivada / descansando / animada |
| H10 | Sistema Hormigasoles básico | 6h | Objetivo diario: +10 HS; registrar gasto: +5 HS |
| H11 | Hormiguero nivel inicial | 4h | Visualización progreso: nivel 1 con elementos básicos |
| H12 | Tienda virtual 3 artículos | 6h | Catálogo: Sombrero (50 HS), Mochila (80 HS), Gafas (40 HS) |

**Del Día 3:**
- ✅ Mascota con animación por estado
- ✅ Hormigasoles contados y mostrados
- ✅ Tienda con 3 artículos y precios
- ✅ Compra descuenta HS del inventario

### Día 4: Meta y Validación
| ID | Historia | Estimación | Acceptance Criteria |
|----|----------|------------|---------------------|
| H13 | Metas individuales básicas | 6h | Campo monto objetivo, barra progreso visual |
| H14 | Estadísticas categorías | 4h | Distribución: alimentación, transporte, entretenimiento, hormiga |
| H15 | Historial consultable y editable | 6h | Lista movimientos con opción corregir/eliminar |
| H16 | Pruebas con usuario real | 6h | Sesión 30min con estudiante, retroalimentación documentada |

**Del Día 4:**
- ✅ Metas con progreso y fecha límite
- ✅ Estadísticas mensuales por categoría
- ✅ Historial financiero editable
- ✅ Feedback usuario real recopilado

---

## Definition of Done (4 Días)

### Criterios Técnicos
- [ ] Abre aplicación directamente en 6 módulos
- [ ] Solicita y maneja permisos notificaciones Android
- [ ] Detecta Yape cuando notificación compatible (formato S/ XX.XX)
- [ ] Clasifica y registra movimiento en SQLite
- [ ] Funciona modo offline (SQLite local)
- [ ] Sincroniza con Supabase cuando hay conexión
- [ ] Mascota muestra 4 estados emocionales básicos
- [ ] Hormigasoles por actividades básicas (objetivo/día, registro/gasto)
- [ ] Tienda con 3 artículos comprables con HS
- [ ] Metas individuales con barra progreso
- [ ] Estadísticas básicas por categoría

### Criterios de Usuario
- [ ] Interfaz intuitiva sin tutorial
- [ ] Permisos explicados claramente
- [ ] Flujo completo: notificación → clasificación → registro → gamificación
- [ ] Sin errores críticos en 5+ pruebas con usuarios reales

---

## Riesgos y Mitigación (Timeline 4 Días)

| Riesgo | Consecuencia | Solución |
|--------|--------------|----------|
| Formato notificaciones Yape varia | Detección falla en algunos dispositivos | Diseñar adaptadores flexibles, usar expresiones regulares generales |
| Usuario deniega permisos | No detecta movimientos | Flujo alternativo: ingreso manual básico en panel |
| Sincronización Supabase falla | Datos perdidos si cambia phone | Énfasis en SQLite local como fuente de verdad |
| Clasificaciones incorrectas | Estadísticas engañosas | Permitir corrección manual después de registro |

---

## Consejos para Entrega en 4 Días

1. **Enfoque MVP**: Solo flujo feliz (usuario permite permisos, notificación compatible detectada)
2. **Datos ficticios**: Si detección Yape tarda, usar datos de prueba hardcodeados
3. **Demo > Perfecto**: Aplicación funcional con 80% features > aplicación perfecta con 50% features
4. **Usuario real**: 30 min de prueba con estudiante valen más que 10 horas de código
5. **Transparencia**: Documentar limitaciones en README (solo Android, requiere permisos, etc.)

---

## Estructura de Archivos Esperada

```
Ahorrant/
├── lib/
│   ├── main.dart
│   ├── screens/         # 6 pantallas de módulos
│   ├── services/        # Firebase/Supabase, NotificationService
│   ├── models/        # Transaction, Category, Ant, Hormigasol
│   └── widgets/       # Mascota, Tarjetas, ProgressBar
├── android/
│   └── app/src/main/kotlin/com/ahorrant/
│       └── NotificationService.kt
├── supabase/
│   └── migrations/
└── README.md
```

---

## Criterio de Éxito del Sprint
**MVP demonstrable** que permita a un universitario:
1. Abrir la app y ver panel financiero
2. Recibir notificación de Yape y clasificarlo
3. Ver mascota reaccionar
4. Ganar Hormigasoles
5. Comprar un accesorio en la tienda

*Plan diseñado para máxima validación en mínimo tiempo. Ajustes finos se harán post-entrega basado en feedback real.*