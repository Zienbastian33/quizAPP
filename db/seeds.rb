# frozen_string_literal: true

puts "🌱 Limpiando base de datos..."
# Eliminar en orden correcto (hijos antes que padres)
AttemptAnswer.destroy_all
QuizAttempt.destroy_all
Option.destroy_all
Question.destroy_all
Quiz.destroy_all
User.destroy_all

puts "👤 Creando usuarios..."

admin = User.create!(
  name: "Admin Demo",
  email: "admin@quizapp.com",
  password: "password123",
  role: :admin
)

player1 = User.create!(
  name: "Player Demo",
  email: "player@quizapp.com",
  password: "password123",
  role: :player
)

player2 = User.create!(
  name: "María González",
  email: "maria@example.com",
  password: "password123",
  role: :player
)

puts "📝 Creando Quiz 1: Capitales del Mundo..."

quiz1 = Quiz.create!(
  title: "Capitales del Mundo",
  description: "¿Cuánto sabes de geografía? Pon a prueba tus conocimientos sobre las capitales de distintos países del mundo.",
  user: admin,
  status: :published,
  published_at: Time.current
)

# Pregunta 1
q1 = quiz1.questions.create!(body: "¿Cuál es la capital de Chile?", position: 1)
q1.options.create!([
  { body: "Valparaíso", correct: false },
  { body: "Santiago", correct: true },
  { body: "Concepción", correct: false },
  { body: "Viña del Mar", correct: false }
])

# Pregunta 2
q2 = quiz1.questions.create!(body: "¿Cuál es la capital de Japón?", position: 2)
q2.options.create!([
  { body: "Osaka", correct: false },
  { body: "Kioto", correct: false },
  { body: "Tokio", correct: true },
  { body: "Nagoya", correct: false }
])

# Pregunta 3
q3 = quiz1.questions.create!(body: "¿Cuál es la capital de Australia?", position: 3)
q3.options.create!([
  { body: "Sídney", correct: false },
  { body: "Melbourne", correct: false },
  { body: "Perth", correct: false },
  { body: "Canberra", correct: true }
])

# Pregunta 4
q4 = quiz1.questions.create!(body: "¿Cuál es la capital de Brasil?", position: 4)
q4.options.create!([
  { body: "Río de Janeiro", correct: false },
  { body: "São Paulo", correct: false },
  { body: "Brasilia", correct: true },
  { body: "Salvador", correct: false }
])

# Pregunta 5
q5 = quiz1.questions.create!(body: "¿Cuál es la capital de Turquía?", position: 5)
q5.options.create!([
  { body: "Estambul", correct: false },
  { body: "Ankara", correct: true },
  { body: "Izmir", correct: false },
  { body: "Antalya", correct: false }
])

puts "📝 Creando Quiz 2: Ruby on Rails..."

quiz2 = Quiz.create!(
  title: "Fundamentos de Ruby on Rails",
  description: "Evalúa tus conocimientos sobre el framework Ruby on Rails. Desde conceptos básicos hasta patrones de diseño.",
  user: admin,
  status: :published,
  published_at: 2.days.ago
)

rq1 = quiz2.questions.create!(body: "¿Qué patrón de diseño utiliza Rails como base de su arquitectura?", position: 1)
rq1.options.create!([
  { body: "MVVM (Model-View-ViewModel)", correct: false },
  { body: "MVC (Model-View-Controller)", correct: true },
  { body: "MVP (Model-View-Presenter)", correct: false },
  { body: "Singleton", correct: false }
])

rq2 = quiz2.questions.create!(body: "¿Qué ORM utiliza Rails por defecto para interactuar con la base de datos?", position: 2)
rq2.options.create!([
  { body: "Sequel", correct: false },
  { body: "DataMapper", correct: false },
  { body: "ActiveRecord", correct: true },
  { body: "Hibernate", correct: false }
])

rq3 = quiz2.questions.create!(body: "¿Qué comando crea una nueva aplicación Rails?", position: 3)
rq3.options.create!([
  { body: "rails create myapp", correct: false },
  { body: "ruby new myapp", correct: false },
  { body: "bundle init rails myapp", correct: false },
  { body: "rails new myapp", correct: true }
])

rq4 = quiz2.questions.create!(body: "¿Qué principio de Rails establece que la configuración debe ser mínima?", position: 4)
rq4.options.create!([
  { body: "Don't Repeat Yourself (DRY)", correct: false },
  { body: "Convention over Configuration (CoC)", correct: true },
  { body: "KISS (Keep It Simple, Stupid)", correct: false },
  { body: "YAGNI (You Ain't Gonna Need It)", correct: false }
])

puts "📝 Creando Quiz 3: Ciencia General..."

quiz3 = Quiz.create!(
  title: "Ciencia General",
  description: "Preguntas sobre ciencia, naturaleza y el universo. ¿Cuánto sabes del mundo que te rodea?",
  user: admin,
  status: :published,
  published_at: 1.week.ago
)

sq1 = quiz3.questions.create!(body: "¿Cuál es el planeta más grande del sistema solar?", position: 1)
sq1.options.create!([
  { body: "Saturno", correct: false },
  { body: "Neptuno", correct: false },
  { body: "Júpiter", correct: true },
  { body: "Urano", correct: false }
])

sq2 = quiz3.questions.create!(body: "¿Qué gas es el más abundante en la atmósfera terrestre?", position: 2)
sq2.options.create!([
  { body: "Oxígeno", correct: false },
  { body: "Nitrógeno", correct: true },
  { body: "Dióxido de carbono", correct: false },
  { body: "Hidrógeno", correct: false }
])

sq3 = quiz3.questions.create!(body: "¿Cuántos huesos tiene el cuerpo humano adulto?", position: 3)
sq3.options.create!([
  { body: "186", correct: false },
  { body: "206", correct: true },
  { body: "226", correct: false },
  { body: "256", correct: false }
])

puts "📝 Creando Quiz 4: Borrador (sin publicar)..."

quiz4 = Quiz.create!(
  title: "Quiz en Borrador",
  description: "Este quiz aún está en construcción y no es visible para los players.",
  user: admin,
  status: :draft
)

# Una pregunta incompleta (solo 2 opciones, no se puede publicar aún)
dq1 = quiz4.questions.create!(body: "Pregunta de prueba en borrador", position: 1)
dq1.options.create!([
  { body: "Opción A", correct: true },
  { body: "Opción B", correct: false }
])

puts "🎮 Creando intento de ejemplo (player1 respondió Quiz 1)..."

attempt = QuizAttempt.create!(
  user: player1,
  quiz: quiz1,
  score: 0,
  total_questions: 0,
  status: :in_progress
)

# Player respondió 3 de 5 preguntas correctamente
attempt.attempt_answers.create!(question: q1, option: q1.options.find_by(correct: true))
attempt.attempt_answers.create!(question: q2, option: q2.options.find_by(correct: true))
attempt.attempt_answers.create!(question: q3, option: q3.options.first) # incorrecta
attempt.attempt_answers.create!(question: q4, option: q4.options.find_by(correct: true))
attempt.attempt_answers.create!(question: q5, option: q5.options.first) # incorrecta

# Finalizar el intento
attempt.calculate_score!

puts ""
puts "✅ Seeds completados!"
puts "=" * 50
puts "📊 Resumen:"
puts "   Usuarios: #{User.count} (#{User.admin.count} admin, #{User.player.count} players)"
puts "   Quizzes: #{Quiz.count} (#{Quiz.published.count} publicados, #{Quiz.drafts.count} borradores)"
puts "   Preguntas: #{Question.count}"
puts "   Opciones: #{Option.count}"
puts "   Intentos: #{QuizAttempt.count}"
puts ""
puts "🔑 Credenciales de acceso:"
puts "   Admin:  admin@quizapp.com / password123"
puts "   Player: player@quizapp.com / password123"
puts "   Player: maria@example.com / password123"
puts ""
puts "🔑 API Tokens:"
puts "   Admin:  #{admin.api_token}"
puts "   Player: #{player1.api_token}"
puts "=" * 50
