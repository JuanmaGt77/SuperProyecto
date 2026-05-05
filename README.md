# ServiLink

> Conecta clientes con prestadores de servicios cercanos: mecánicos, albañiles, electricistas, soldadores y plomeros.

App móvil Flutter (Android + iOS) tipo Uber/InDrive para servicios profesionales en Latinoamérica.

---

## Stack

- **Flutter 3.3+ / Dart 3.3+**
- **Supabase** — Auth, PostgreSQL, PostGIS, Realtime, Edge Functions, RLS
- **Cloudinary** — Almacenamiento de imágenes
- **Google Maps Platform** — Mapas y geolocalización
- **Riverpod 2.x** — Gestión de estado
- **GoRouter** — Navegación declarativa

---

## Estructura del proyecto

```
lib/
├── app/                  # App-level: tema, rutas, constantes
├── core/                 # Servicios, widgets, errores compartidos
├── features/             # Funcionalidades por módulo (Clean Architecture)
│   ├── auth/
│   ├── onboarding/
│   ├── client/
│   ├── provider/
│   ├── chat/
│   ├── map/
│   └── ...
└── shared/               # Modelos y widgets transversales
supabase/
└── schema.sql            # Esquema completo de la base de datos
```

---

## Setup

### 1. Instalar Flutter
https://docs.flutter.dev/get-started/install

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Configurar Supabase
1. Crea proyecto en https://app.supabase.com
2. Ve a **SQL Editor** y ejecuta el contenido de `supabase/schema.sql`
3. Activa extensiones: `postgis`, `uuid-ossp`, `pg_trgm`
4. Copia `URL` y `anon key` desde **Settings → API**

### 4. Configurar Cloudinary
1. Crea cuenta en https://cloudinary.com
2. Ve a **Settings → Upload**
3. Crea un **Upload Preset** llamado `servilink_unsigned` (modo *unsigned*)
4. En carpeta especifica `servilink/`

### 5. Configurar Google Maps
1. Habilita **Maps SDK for Android**, **Maps SDK for iOS** y **Places API**
2. Crea API Key con restricciones por bundle ID
3. Agrega en `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data android:name="com.google.android.geo.API_KEY"
              android:value="TU_API_KEY"/>
   ```
4. Agrega en `ios/Runner/AppDelegate.swift`

### 6. Variables de entorno
Copia `.env.example` y rellena los valores:
```bash
cp .env.example .env
```

### 7. Ejecutar
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxx \
  --dart-define=GOOGLE_MAPS_API_KEY=xxx \
  --dart-define=CLOUDINARY_CLOUD_NAME=xxx
```

---

## Estado del proyecto

### ✅ Fase 1 — Base del proyecto (COMPLETA)
- Estructura Clean Architecture
- Tema visual completo (Material 3, Poppins)
- Pantallas: Splash, Onboarding, Selección de cuenta, Login, Registro Cliente, Registro Prestador, Recuperar contraseña
- Home Cliente y Home Prestador (UI completa con datos mock)
- Router con GoRouter
- Modelos de dominio
- Schema SQL completo con RLS, RPC y triggers
- Servicios base: Supabase, Cloudinary, Location

### 🔜 Fase 2 — Autenticación real
- AuthRepository con Supabase
- Persistencia de sesión
- Guards de ruta por rol
- Recuperación de contraseña funcional

### 🔜 Fase 3 — Perfiles
- Subida de avatar con Cloudinary
- Editar perfil
- Galería del prestador

### 🔜 Fase 4 — Categorías y prestadores
### 🔜 Fase 5 — Mapa con PostGIS
### 🔜 Fase 6 — Solicitudes y cotizaciones
### 🔜 Fase 7 — Chat en tiempo real
### 🔜 Fase 8 — Pagos
### 🔜 Fase 9 — Reseñas
### 🔜 Fase 10 — Panel admin

---

## Categorías iniciales

1. 🔧 Mecánico Automotriz
2. 🧱 Albañil
3. ⚡ Electricista
4. 🔥 Soldador
5. 🚿 Plomero

---

## Roles

- **Cliente:** Solicita servicios.
- **Prestador:** Ofrece servicios (requiere verificación).
- **Admin:** Aprueba prestadores, gestiona reportes.

---

## Seguridad

- Row Level Security activado en todas las tablas sensibles
- Documentos privados (solo dueño + admin)
- API keys nunca expuestas en el cliente (Cloudinary firmado vía Edge Functions)
- Tokens JWT manejados por Supabase Auth
