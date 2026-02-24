class CreateQuizAttempts < ActiveRecord::Migration[8.0]
  def change
    create_table :quiz_attempts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :quiz, null: false, foreign_key: true
      t.integer :score, null: false, default: 0
      t.integer :total_questions, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.datetime :completed_at

      t.timestamps
    end
  end
end
