class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.text :body, null: false
      t.integer :position, null: false, default: 0
      t.references :quiz, null: false, foreign_key: true

      t.timestamps
    end
  end
end
