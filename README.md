# 🧠 QuizApp — Prueba Técnica RioLabs

Aplicación de quizzes construida con **Ruby on Rails 8**, con interfaz web completa (MVC) y API JSON.

## 📋 Descripción

QuizApp permite a administradores crear y publicar quizzes con preguntas de opción múltiple,
y a jugadores responderlos y ver sus resultados. La aplicación expone la misma lógica tanto
a través de vistas server-side como de una API RESTful.

### Roles

| Rol | Permisos |
|---|---|
| **Admin** | Crear quizzes (draft/published), crear preguntas con 4 opciones, subir imágenes/videos, publicar quizzes |
| **Player** | Ver quizzes publicados, responder quizzes, ver resultado final (score y detalle) |

### Reglas de negocio

- No se pueden responder quizzes en estado **draft**
- Un intento finalizado **no puede modificarse**
- Cada pregunta debe tener **exactamente 4 opciones y 1 correcta** para publicarse
- Un quiz necesita **al menos 1 pregunta válida** para publicarse

---

## 🛠 Stack Técnico

| Componente | Tecnología | Versión |
|---|---|---|
| Framework | Ruby on Rails | 8.0.4 |
| Lenguaje | Ruby | 3.4.8 |
| Base de datos | PostgreSQL | 16 |
| CSS | Tailwind CSS | Integrado con Rails |
| Autenticación | Devise | 5.0.2 |
| Autorización | Pundit | 2.5.2 |
| Paginación | Pagy | 43.3.0 |
| Uploads | Active Storage | Rails nativo |
| API Auth | Token Bearer (has_secure_token) | — |
| Interactividad | Hotwire (Turbo + Stimulus) | Rails nativo |
| Deploy | Docker + AWS EC2 + Nginx + Puma | — |

---

## 🚀 Setup Local

### Prerrequisitos

- Ruby 3.4.x (recomendado: rbenv)
- PostgreSQL 16
- Node.js 22+ (para asset pipeline)
- Git

### Instalación

```bash
# 1. Clonar el repositorio
git clone <URL_REPOSITORIO>
cd quiz_app

# 2. Instalar dependencias
bundle install

# 3. Crear y migrar la base de datos
rails db:create
rails db:migrate

# 4. Cargar datos de ejemplo
rails db:seed

# 5. Levantar el servidor
bin/dev
```

La app estará disponible en `http://localhost:3000`

### Credenciales de demo

| Rol | Email | Contraseña |
|---|---|---|
| Admin | admin@quizapp.com | password123 |
| Player | player@quizapp.com | password123 |
| Player | maria@example.com | password123 |

---

## 🐳 Docker

```bash
# Desarrollo
docker compose up --build

# La app estará en http://localhost:3000
```

---

## 📡 API REST

La API se encuentra en `/api/v1/`. Usa autenticación por token Bearer.

### Obtener token

```bash
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@quizapp.com", "password": "password123"}'
```

Respuesta:
```json
{
  "token": "abc123...",
  "user": { "id": 1, "email": "admin@quizapp.com", "name": "Admin Demo", "role": "admin" }
}
```

### Endpoints

#### Autenticación
| Método | Endpoint | Auth | Descripción |
|---|---|---|---|
| POST | `/api/v1/login` | No | Login → devuelve token |

#### Quizzes
| Método | Endpoint | Auth | Descripción |
|---|---|---|---|
| GET | `/api/v1/quizzes` | Opcional | Listar publicados (admin: todos) |
| GET | `/api/v1/quizzes/:id` | Opcional | Detalle con preguntas |
| POST | `/api/v1/quizzes` | Admin | Crear quiz (draft) |
| PATCH | `/api/v1/quizzes/:id` | Admin | Actualizar quiz |
| DELETE | `/api/v1/quizzes/:id` | Admin | Eliminar (solo draft) |
| PATCH | `/api/v1/quizzes/:id/publish` | Admin | Publicar quiz |

#### Preguntas
| Método | Endpoint | Auth | Descripción |
|---|---|---|---|
| GET | `/api/v1/quizzes/:qid/questions` | Token | Listar preguntas |
| GET | `/api/v1/quizzes/:qid/questions/:id` | Token | Detalle pregunta |
| POST | `/api/v1/quizzes/:qid/questions` | Admin | Crear con opciones |
| PATCH | `/api/v1/quizzes/:qid/questions/:id` | Admin | Actualizar |
| DELETE | `/api/v1/quizzes/:qid/questions/:id` | Admin | Eliminar (solo draft) |

#### Intentos
| Método | Endpoint | Auth | Descripción |
|---|---|---|---|
| GET | `/api/v1/attempts` | Token | Mis intentos |
| GET | `/api/v1/attempts/:id` | Token | Detalle + respuestas |
| POST | `/api/v1/attempts` | Token | Iniciar intento |
| POST | `/api/v1/attempts/:id/submit` | Token | Finalizar intento |

#### Respuestas
| Método | Endpoint | Auth | Descripción |
|---|---|---|---|
| POST | `/api/v1/attempts/:id/answers` | Token | Enviar respuesta |

### Headers requeridos (endpoints autenticados)
```
Authorization: Bearer <token>
Content-Type: application/json
```

### Paginación

Los endpoints de listado soportan paginación:
```
GET /api/v1/quizzes?page=1&limit=10
```

Respuesta:
```json
{
  "data": [...],
  "meta": { "total": 15, "page": 1, "pages": 2, "limit": 10 }
}
```

---

## 🏗 Arquitectura y Decisiones de Diseño

### Modelos de datos

```
User (Devise)
  ├── has_many :quizzes          (admin crea quizzes)
  └── has_many :quiz_attempts    (player responde quizzes)

Quiz
  ├── belongs_to :user           (admin creador)
  ├── has_many :questions
  ├── has_many :quiz_attempts
  ├── has_one_attached :cover_image  (Active Storage)
  └── has_one_attached :media        (Active Storage)

Question
  ├── belongs_to :quiz
  ├── has_many :options
  ├── has_one_attached :image
  └── has_one_attached :media

Option
  └── belongs_to :question

QuizAttempt
  ├── belongs_to :user
  ├── belongs_to :quiz
  └── has_many :attempt_answers

AttemptAnswer
  ├── belongs_to :quiz_attempt
  ├── belongs_to :question
  └── belongs_to :option
```

### Decisiones clave

1. **Devise + Pundit** — Autenticación y autorización estándar del ecosistema Rails. Pundit se usa tanto en web como en API para consistencia total.

2. **Token API con `has_secure_token`** — Solución simple y nativa de Rails para auth de la API. El token se genera automáticamente al crear el usuario.

3. **Active Storage** — Solución nativa de Rails para uploads. Soporta almacenamiento local y S3 sin cambios de código.

4. **Hotwire (Turbo + Stimulus)** — Interactividad sin SPAs. Flash messages con auto-dismiss, navbar responsive, selección de opciones en tiempo real.

5. **Pagy v43** — Paginación eficiente tanto en vistas web como en API. API nueva con `Pagy::Method`.

6. **Anti-trampa en API** — Las opciones no revelan `correct` al player. Las respuestas no dicen si son correctas hasta el submit.

---

## 📁 Estructura del proyecto

```
app/
├── controllers/
│   ├── admin/              # Admin: quizzes, questions, dashboard
│   ├── api/v1/             # API JSON: auth, quizzes, questions, attempts, answers
│   ├── application_controller.rb
│   ├── home_controller.rb
│   ├── quizzes_controller.rb
│   ├── attempts_controller.rb
│   └── answers_controller.rb
├── models/
│   ├── user.rb             # Devise + roles (admin/player)
│   ├── quiz.rb             # Estados: draft/published
│   ├── question.rb         # Con nested options
│   ├── option.rb
│   ├── quiz_attempt.rb     # Estados: in_progress/completed
│   └── attempt_answer.rb
├── policies/               # Pundit policies
│   ├── quiz_policy.rb
│   ├── quiz_attempt_policy.rb
│   └── question_policy.rb
├── views/
│   ├── layouts/            # application.html.erb, admin.html.erb
│   ├── admin/              # CRUD admin
│   ├── quizzes/            # Player: listado y detalle
│   ├── attempts/           # Player: quiz-taking y resultados
│   ├── devise/             # Login, registro, perfil (estilizados)
│   ├── home/               # Landing page
│   └── shared/             # Partials reutilizables
└── javascript/
    └── controllers/        # Stimulus: flash, navbar
```

---

## 📝 Tiempo y desafíos

- **Tiempo total:** [COMPLETAR]
- **Desafío principal:** [COMPLETAR]

---

## 👤 Autor

**Bastian Araya Chacon**
Prueba técnica para RioLabs — Febrero 2026
