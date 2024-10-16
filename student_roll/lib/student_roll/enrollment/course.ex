defmodule StudentRoll.Enrollment.Course do
  use Ecto.Schema
  import Ecto.Changeset

  schema "courses" do
    field :name, :string
    field :max_students, :integer
    field :waitlist_size, :integer
    field :min_age, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :max_students, :waitlist_size, :min_age])
    |> validate_required([:name, :max_students, :waitlist_size, :min_age])
  end
end
