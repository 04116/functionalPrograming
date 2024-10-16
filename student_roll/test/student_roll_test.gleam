import enrollment.{Course, NoSeats, Rejected, Student, Waitlisted}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn waitlist_exceeded_test() {
  let course =
    Course(
      id: 2,
      min_age: 0,
      seats: 10,
      seats_used: 10,
      max_waitlist_size: 2,
      waitlist: [
        Student(id: 1, age: 22),
        Student(id: 2, age: 13),
        Student(id: 3, age: 54),
      ],
    )

  let student = Student(id: 4, age: 22)

  enrollment.enroll(student, course)
  |> should.equal(Rejected(NoSeats))
}

pub fn waitlisted_test() {
  let course =
    Course(
      id: 2,
      min_age: 0,
      seats: 10,
      seats_used: 10,
      max_waitlist_size: 2,
      waitlist: [],
    )

  let student = Student(id: 4, age: 22)

  enrollment.enroll(student, course)
  |> should.equal(Waitlisted)
}
// pub fn enrolled_test() {
//   let course = Course(id: 1, min_age: 21, seats: 10, seats_used: 9)
//   let student = Student(id: 10, age: 22)
//   enrollment.enroll(student, course)
//   |> should.equal(Enrolled)
// }
