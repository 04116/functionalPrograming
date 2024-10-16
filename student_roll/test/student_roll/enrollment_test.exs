defmodule StudentRoll.EnrollmentTest do
  use StudentRoll.DataCase

  alias StudentRoll.Enrollment

  describe "enrollment" do
    import StudentRoll.EnrollmentFixtures

    test "enroll a student" do
      birthday = DateTime.utc_now() |> DateTime.add(-18 * 365, :day)
      student = student_fixture(%{date_of_birth: birthday})
      course = course_fixture(%{min_age: 12})

      assert {:ok, _} = Enrollment.enroll(course.id, student.id)
      # assert Enrollment.enrolled?(course.id, student.id)
    end

    test "waitlist a student" do
      birthday = DateTime.utc_now() |> DateTime.add(-18 * 365, :day)
      student1 = student_fixture(%{date_of_birth: birthday})
      student2 = student_fixture(%{date_of_birth: DateTime.utc_now()})

      course = course_fixture(%{min_age: 12, max_students: 1, waitlist_size: 10})

      assert {:ok, _} = Enrollment.enroll(course.id, student1.id)
      # assert {:ok, _} = Enrollment.enroll(course.id, student2.id)

      assert Enrollment.waitlisted?(course.id, student2.id)
    end
  end
end
