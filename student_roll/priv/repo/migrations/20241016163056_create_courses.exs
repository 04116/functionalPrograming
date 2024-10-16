defmodule StudentRoll.Repo.Migrations.CreateCourses do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add :name, :string
      add :max_students, :integer
      add :waitlist_size, :integer
      add :min_age, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
