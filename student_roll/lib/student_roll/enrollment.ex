defmodule StudentRoll.Enrollment do
  @moduledoc """
  The Enrollment context.
  """

  import Ecto.Query, warn: false
  alias StudentRoll.Repo

  alias StudentRoll.Enrollment.Student
  alias StudentRoll.Enrollment.Enrollment

  @doc """
  Returns the list of students.

  ## Examples

      iex> list_students()
      [%Student{}, ...]

  """
  def list_students do
    Repo.all(Student)
  end

  @doc """
  Gets a single student.

  Raises `Ecto.NoResultsError` if the Student does not exist.

  ## Examples

      iex> get_student!(123)
      %Student{}

      iex> get_student!(456)
      ** (Ecto.NoResultsError)

  """
  def get_student!(id), do: Repo.get!(Student, id)

  @doc """
  Creates a student.

  ## Examples

      iex> create_student(%{field: value})
      {:ok, %Student{}}

      iex> create_student(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_student(attrs \\ %{}) do
    %Student{}
    |> Student.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a student.

  ## Examples

      iex> update_student(student, %{field: new_value})
      {:ok, %Student{}}

      iex> update_student(student, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_student(%Student{} = student, attrs) do
    student
    |> Student.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a student.

  ## Examples

      iex> delete_student(student)
      {:ok, %Student{}}

      iex> delete_student(student)
      {:error, %Ecto.Changeset{}}

  """
  def delete_student(%Student{} = student) do
    Repo.delete(student)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking student changes.

  ## Examples

      iex> change_student(student)
      %Ecto.Changeset{data: %Student{}}

  """
  def change_student(%Student{} = student, attrs \\ %{}) do
    Student.changeset(student, attrs)
  end

  alias StudentRoll.Enrollment.Course

  @doc """
  Returns the list of courses.

  ## Examples

      iex> list_courses()
      [%Course{}, ...]

  """
  def list_courses do
    Repo.all(Course)
  end

  @doc """
  Gets a single course.

  Raises `Ecto.NoResultsError` if the Course does not exist.

  ## Examples

      iex> get_course!(123)
      %Course{}

      iex> get_course!(456)
      ** (Ecto.NoResultsError)

  """
  def get_course!(id), do: Repo.get!(Course, id)

  @doc """
  Creates a course.

  ## Examples

      iex> create_course(%{field: value})
      {:ok, %Course{}}

      iex> create_course(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_course(attrs \\ %{}) do
    %Course{}
    |> Course.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a course.

  ## Examples

      iex> update_course(course, %{field: new_value})
      {:ok, %Course{}}

      iex> update_course(course, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_course(%Course{} = course, attrs) do
    course
    |> Course.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a course.

  ## Examples

      iex> delete_course(course)
      {:ok, %Course{}}

      iex> delete_course(course)
      {:error, %Ecto.Changeset{}}

  """
  def delete_course(%Course{} = course) do
    Repo.delete(course)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking course changes.

  ## Examples

      iex> change_course(course)
      %Ecto.Changeset{data: %Course{}}

  """
  def change_course(%Course{} = course, attrs \\ %{}) do
    Course.changeset(course, attrs)
  end

  def enrolled?(course_id, student_id) do
    from(e in Enrollment,
      where:
        e.student_id == ^student_id and
          e.course_id == ^course_id and is_nil(e.waitlisted_at)
    )
    |> Repo.exists?()
  end

  # defp get_gleam_student!(id) do
  #   student = get_student!(id)
  #
  #   student_age =
  #     DateTime.utc_now() |> DateTime.to_date() |> Date.diff(student.date_of_birth) |> div(365)
  #
  #   {:student, id, student_age}
  # end
  #
  # defp get_gleam_course!(id) do
  #   course = get_course!(id)
  #
  #   seats_taken =
  #     Repo.aggregate(
  #       from(e in Enrollment, where: e.course_id == ^id and is_nil(e.waitlisted_at)),
  #       :count
  #     )
  #
  #   {:course, course.id, course.min_age, course.max_students, seats_taken}
  # end

  defp get_gleam_student!(id) do
    get_student!(id)
    |> to_gleam_student()
  end

  defp to_gleam_student(student) do
    student_age =
      DateTime.utc_now() |> DateTime.to_date() |> Date.diff(student.date_of_birth) |> div(365)

    {:student, student.id, student_age}
  end

  defp get_gleam_course!(id) do
    course = get_course!(id)

    seats_taken =
      Repo.aggregate(
        from(e in Enrollment, where: e.course_id == ^id and is_nil(e.waitlisted_at)),
        :count
      )

    waitlist =
      from(e in Enrollment, where: e.course_id == ^id and not is_nil(e.waitlisted_at))
      |> Repo.all()
      |> Enum.map(&to_gleam_student/1)

    {:course, course.id, course.min_age, course.max_students, seats_taken, waitlist,
     course.waitlist_size}
  end

  def enroll(course_id, student_id) do
    course = get_gleam_course!(course_id)
    student = get_gleam_student!(student_id)

    IO.inspect(student)

    # here, we call to gleam compiled code
    # they are atom (live inside BEAM) have methods to be called
    case :enrollment.enroll(student, course) do
      :enrolled ->
        %Enrollment{}
        |> Enrollment.changeset(%{
          waitlisted_at: DateTime.utc_now(),
          student_id: student_id,
          course_id: course_id
        })
        |> Repo.insert()

      :waitlisted ->
        %Enrollment{}
        |> Enrollment.changeset(%{
          student_id: student_id,
          course_id: course_id,
          waitlisted_at: DateTime.utc_now()
        })
        |> Repo.insert()

      {:rejected, reason} ->
        IO.inspect("rejected")
        {:error, reason}
    end
  end

  def waitlisted?(course_id, student_id) do
    from(e in Enrollment,
      where:
        e.student_id == ^student_id and
          e.course_id == ^course_id and not is_nil(e.waitlisted_at)
    )
    |> Repo.exists?()
  end
end
