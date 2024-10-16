import gleam/io
import gleam/list

pub type Student {
  Student(id: Int, age: Int)
}

pub type Course {
  Course(
    id: Int,
    min_age: Int,
    seats: Int,
    seats_used: Int,
    waitlist: List(Student),
    max_waitlist_size: Int,
  )
}

pub type RejectionReason {
  NoSeats
  AgeRequirementNotMet
}

pub type CancellingEnrollmentDecision {
  Cancelled
  CancelledWithWaitlistProcessed(Student)
}

pub type EnrollmentDecision {
  Enrolled
  Rejected(reason: RejectionReason)
  Waitlisted
}

pub fn enroll(student: Student, course: Course) -> EnrollmentDecision {
  io.debug(student)
  case student.age >= course.min_age {
    False -> Rejected(AgeRequirementNotMet)
    True ->
      case course.seats > course.seats_used {
        False ->
          case list.length(course.waitlist) >= course.max_waitlist_size {
            True -> Rejected(NoSeats)
            False -> Waitlisted
          }
        True -> Enrolled
      }
  }
}
