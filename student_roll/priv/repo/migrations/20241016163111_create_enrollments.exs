defmodule StudentRoll.Repo.Migrations.CreateEnrollments do
  use Ecto.Migration

  def change do
    create table(:enrollments) do
      add :student_id, :integer
      add :course_id, :integer
      add :waitlisted_at, :naive_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
