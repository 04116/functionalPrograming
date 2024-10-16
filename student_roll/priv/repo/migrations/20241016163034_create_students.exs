defmodule StudentRoll.Repo.Migrations.CreateStudents do
  use Ecto.Migration

  def change do
    create table(:students) do
      add :name, :string
      add :date_of_birth, :date

      timestamps(type: :utc_datetime)
    end
  end
end
