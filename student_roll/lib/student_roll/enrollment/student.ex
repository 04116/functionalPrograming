defmodule StudentRoll.Enrollment.Student do
  use Ecto.Schema
  import Ecto.Changeset

  schema "students" do
    field :name, :string
    field :date_of_birth, :date

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(student, attrs) do
    student
    |> cast(attrs, [:name, :date_of_birth])
    |> validate_required([:name, :date_of_birth])
  end
end
