defmodule StudentRoll.Enrollment.Enrollment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "enrollments" do
    field :student_id, :integer
    field :course_id, :integer
    field :waitlisted_at, :naive_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(enrollment, attrs) do
    enrollment
    |> cast(attrs, [:student_id, :course_id, :waitlisted_at])
    |> validate_required([:student_id, :course_id, :waitlisted_at])
  end
end
