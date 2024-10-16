defmodule StudentRoll.EnrollmentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `StudentRoll.Enrollment` context.
  """

  @doc """
  Generate a student.
  """
  def student_fixture(attrs \\ %{}) do
    {:ok, student} =
      attrs
      |> Enum.into(%{
        date_of_birth: ~D[2024-10-15],
        name: "some name"
      })
      |> StudentRoll.Enrollment.create_student()

    student
  end

  @doc """
  Generate a course.
  """
  def course_fixture(attrs \\ %{}) do
    {:ok, course} =
      attrs
      |> Enum.into(%{
        max_students: 42,
        min_age: 42,
        name: "some name",
        waitlist_size: 42
      })
      |> StudentRoll.Enrollment.create_course()

    course
  end
end
