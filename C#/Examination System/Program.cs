using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Xml.Linq;

namespace Examination_System
{
    internal class Program
    {
        static List<Course> courses = new();
        static List<Student> students = new();
        static List<Instructor> instructors = new();

        static void Main(string[] args)
        {
            MainMenu();
        }

   
        static void MainMenu()
        {
            while (true)
            {
                try
                {
                    Console.Clear();
                    Console.WriteLine("=== Examination System ===");
                    Console.WriteLine("1. Student Menu");
                    Console.WriteLine("2. Instructor Menu");
                    Console.WriteLine("3. Management Menu");
                    Console.WriteLine("0. Exit");
                    Console.Write("Choose option: ");

                    var choice = Console.ReadLine();
                    if (choice == "0")
                        break;

                    switch (choice)
                    {
                        case "1":
                            StudentMenu();
                            break;
                        case "2":
                            InstructorMenu();
                            break;
                        case "3":
                            ManagementMenu();
                            break;
                        default:
                            Console.WriteLine("Invalid option.");
                            Thread.Sleep(1000);
                            break;
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Critical error: {ex.Message}");
                    Thread.Sleep(1500);
                }
            }
        }
        static void ManagementMenu()
        {
            while (true)
            {
                try
                {
                    Console.Clear();
                    Console.WriteLine("=== Management Menu ===");
                    Console.WriteLine("1. Add Student ");
                    Console.WriteLine("2. Add Instructor ");
                    Console.WriteLine("3. Edit Student");
                    Console.WriteLine("4. Remove Student");
                    Console.WriteLine("5. Edit Instructor");
                    Console.WriteLine("6. Remove Instructor");
                    Console.WriteLine("0. Back to Main Menu");
                    Console.Write("Choose option: ");

                    var choice = Console.ReadLine()?.Trim();
                    switch (choice)
                    {
                        case "1": AddStudent(); break;
                        case "2": AddInstructor(); break;
                        case "3": EditStudent(); break;
                        case "4": RemoveStudent(); break;
                        case "5": EditInstructor(); break;
                        case "6": RemoveInstructor(); break;
                        case "0": return;
                        default: Console.WriteLine("Invalid option."); Thread.Sleep(1000); break;
                    }
                    Console.WriteLine("Press Enter to continue...");
                    Console.ReadLine();
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Critical error: {ex.Message}");
                    Thread.Sleep(1500);
                }
            }
        }


        static void StudentMenu()
        {
            try
            {
                Console.Clear();
                var student = PickStudent();
                if (student == null) return;

                while (true)
                {
                    try
                    {
                        Console.Clear();
                        Console.WriteLine($"=== Student Menu ({student.Name}) ===");
                        Console.WriteLine("1. Enroll in Course");
                        Console.WriteLine("2. Unenroll from Course");
                        Console.WriteLine("3. Take Exam");
                        Console.WriteLine("4. Show My Results");
                        Console.WriteLine("5. Show My Courses");
                        Console.WriteLine("0. Back to Main Menu");
                        Console.Write("Choose option: ");

                        var choice = Console.ReadLine()?.Trim();
                        switch (choice)
                        {
                            case "1": EnrollStudentInCourse(student); break;
                            case "2": UnenrollStudentFromCourse(student); break;
                            case "3": StudentTakeExam(student); break;
                            case "4": ShowStudentResult(student); break;
                            case "5": ShowStudentCourses(student); break;
                            case "0": return;
                            default: Console.WriteLine("Invalid option."); Thread.Sleep(1000); break;
                        }
                        Console.WriteLine("Press Enter to continue...");
                        Console.ReadLine();
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Critical error: {ex.Message}");
                        Thread.Sleep(1500);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Critical error: {ex.Message}");
                Thread.Sleep(1500);
            }
        }

        
        static void InstructorMenu()
        {
            try
            {
                Console.Clear();
                var instructor = PickInstructor();
                if (instructor == null) return;

                while (true)
                {
                    try
                    {
                        Console.Clear();
                        Console.WriteLine($"=== Instructor Menu ({instructor.Name}) ===");
                        Console.WriteLine("1. Add Course");
                        Console.WriteLine("2. Assign Instructor to Course");
                        Console.WriteLine("3. Unassign Instructor from Course");
                        Console.WriteLine("4. Create Exam");
                        Console.WriteLine("5. Add Question to Exam");
                        Console.WriteLine("6. Edit / Remove Question from Exam");
                        Console.WriteLine("7. Duplicate Exam");
                        Console.WriteLine("8. Reschedule / Lock Exam");
                        Console.WriteLine("9. Grade Essay for Student");
                        Console.WriteLine("10. Show Course Report");
                        Console.WriteLine("11. Compare Students in Exam");
                        Console.WriteLine("0. Back to Main Menu");
                        Console.Write("Choose option: ");

                        var choice = Console.ReadLine()?.Trim();
                        switch (choice)
                        {
                            case "1": AddCourse(); break;
                            case "2": AssignInstructorToCourse(instructor); break;
                            case "3": UnassignInstructorFromCourse(instructor); break;
                            case "4": CreateExam(instructor); break;
                            case "5": AddQuestionToExam(instructor); break;
                            case "6": EditOrRemoveQuestion(instructor); break;
                            case "7": DuplicateExam(instructor); break;
                            case "8": RescheduleOrLockExam(); break;
                            case "9": GradeEssayForStudent(instructor); break;
                            case "10": ShowCourseReport(); break;
                            case "11": CompareStudentsInExam(); break;
                            case "0": return;
                            default: Console.WriteLine("Invalid option."); Thread.Sleep(1000); break;
                        }
                        Console.WriteLine("Press Enter to continue...");
                        Console.ReadLine();
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Critical error: {ex.Message}");
                        Thread.Sleep(1500);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Critical error: {ex.Message}");
                Thread.Sleep(1500);
            }
        }

        static void EnrollStudentInCourse(Student student)
        {
            try
            {
                var course = PickCourse();
                if (course == null) return;

                student.EnrollInCourse(course);
                Console.WriteLine($"Enrolled {student.Name} in {course.Title}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error enrolling student: {ex.Message}");
            }
        }

        static void UnenrollStudentFromCourse(Student student)
        {
            try
            {
                var course = PickCourse();
                if (course == null) return;

                bool removed = student.UnenrollFromCourse(course);
                if (removed) Console.WriteLine($"{student.Name} unenrolled from {course.Title}");
                else Console.WriteLine("Student was not enrolled in that course.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error unenrolling student: {ex.Message}");
            }
        }

        static void StudentTakeExam(Student student)
        {
            try
            {
                var exams = courses.SelectMany(c => c.Exams).ToList();
                if (!exams.Any()) { Console.WriteLine("No exams available."); return; }

                var exam = PickExam();
                if (exam == null) return;

                student.TakeExam(exam);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }

        static void ShowStudentResult(Student student)
        {
            try
            {
                student.ShowAllResults();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error showing results: {ex.Message}");
            }
        }

        static void ShowStudentCourses(Student student)
        {
            try
            {
                var list = student.GetEnrolledCourses();
                Console.WriteLine($"\n{student.Name} is enrolled in:");
                foreach (var c in list) Console.WriteLine($"- {c.Title}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error showing courses: {ex.Message}");
            }
        }

        static void AddCourse()
        {
            try
            {
                Console.Write("Course title: ");
                var title = Console.ReadLine();
                Console.Write("Description: ");
                var desc = Console.ReadLine();
                Console.Write("Max degree: ");
                if (!int.TryParse(Console.ReadLine(), out int max)) { Console.WriteLine("Invalid max degree"); return; }

                var c = new Course(title, desc, max);
                courses.Add(c);
                Console.WriteLine($"Added course {c.Title}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error adding course: {ex.Message}");
            }
        }

        static void AssignInstructorToCourse(Instructor instructor)
        {
            try
            {
                var course = PickCourse();
                if (course == null) return;

                instructor.AssignCourse(course);
                course.AssignInstructor(instructor);
                Console.WriteLine($"Assigned {instructor.Name} to {course.Title}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error assigning instructor: {ex.Message}");
            }
        }

        static void UnassignInstructorFromCourse(Instructor instructor)
        {
            try
            {
                var course = PickCourse();
                if (course == null) return;

                instructor.RemoveCourse(course);
                course.UnassignInstructor(instructor);
                Console.WriteLine($"Unassigned {instructor.Name} from {course.Title}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error unassigning instructor: {ex.Message}");
            }
        }

        static void CreateExam(Instructor instructor)
        {
            try
            {
                var course = PickCourse();
                if (course == null) return;
                if (!instructor.GetCourses().Contains(course)) { Console.WriteLine("Instructor not assigned to this course."); return; }

                Console.Write("Exam title: ");
                var title = Console.ReadLine();
                Console.Write("Start time (yyyy-MM-dd HH:mm): ");
                var startText = Console.ReadLine();
                Console.Write("End time (yyyy-MM-dd HH:mm): ");
                var endText = Console.ReadLine();

                if (!DateTime.TryParse(startText, out DateTime start) || !DateTime.TryParse(endText, out DateTime end))
                {
                    Console.WriteLine("Invalid dates"); return;
                }
                if (end <= start) { Console.WriteLine("End must be after start"); return; }
                if (start <= DateTime.Now) { Console.WriteLine("Start must be in the future"); return; }
                var exam = instructor.CreateExam(course, title, start, end);
                Console.WriteLine($"Created exam {exam.Title}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error creating exam: {ex.Message}");
            }
        }

        static void AddQuestionToExam(Instructor instructor)
        {
            try
            {
                var exam = PickExam();
                if (exam == null) return;

                Console.WriteLine("Question types: 1) MCQ 2) True/False 3) Essay");
                Console.Write("Choose type: ");
                var type = Console.ReadLine();

                switch (type)
                {
                    case "1":
                        Console.Write("Text: "); var text = Console.ReadLine();
                        Console.Write("Marks: "); int m = int.Parse(Console.ReadLine());
                        Console.Write("Options (sep by |): "); var opts = Console.ReadLine()?.Split('|', StringSplitOptions.RemoveEmptyEntries).Select(x => x.Trim()).ToList();
                        Console.Write("Correct option index (1-based): "); int idx = int.Parse(Console.ReadLine()) - 1;
                        var mcq = new MCQQuestion(text, m, opts, idx);
                        instructor.AddQuestionToExam(exam, mcq);
                        break;
                    case "2":
                        Console.Write("Text: "); var tfText = Console.ReadLine();
                        Console.Write("Marks: "); int tfMarks = int.Parse(Console.ReadLine());
                        Console.Write("Correct (true/false): "); bool correct = bool.Parse(Console.ReadLine());
                        var tf = new TrueFalseQuestion(tfText, tfMarks, correct);
                        instructor.AddQuestionToExam(exam, tf);
                        break;
                    case "3":
                        Console.Write("Text: "); var eText = Console.ReadLine();
                        Console.Write("Marks: "); int eMarks = int.Parse(Console.ReadLine());
                        var essay = new EssayQuestion(eText, eMarks);
                        instructor.AddQuestionToExam(exam, essay);
                        break;
                }
                Console.WriteLine("Question added.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error adding question: {ex.Message}");
            }
        }

        static void EditOrRemoveQuestion(Instructor instructor)
        {
            try
            {
                var exam = PickExam();
                if (exam == null) return;

                Console.WriteLine("Questions:");
                for (int i = 0; i < exam.Questions.Count; i++)
                    Console.WriteLine($"{i}. {exam.Questions[i].Text}");

                Console.Write("Pick question index to edit/remove: ");
                if (!int.TryParse(Console.ReadLine(), out int idx) || idx < 0 || idx >= exam.Questions.Count) return;
                var question = exam.Questions[idx];

                Console.WriteLine("1) Edit 2) Remove");
                var choice = Console.ReadLine();

                if (choice == "1")
                {
                    Console.Write("New text: "); var newText = Console.ReadLine();
                    Console.Write("New marks: "); var newMarksInput = Console.ReadLine();
                    if (!int.TryParse(newMarksInput, out int newMarks)) { Console.WriteLine("Invalid marks."); return; }

                    var edited = question.Clone();
                    edited.Text = newText;
                    edited.Marks = newMarks;

                    exam.RemoveQuestion(question);
                    exam.AddQuestion(edited);

                    Console.WriteLine("Edited successfully.");
                }
                else if (choice == "2")
                {
                    exam.RemoveQuestion(question);
                    Console.WriteLine("Removed successfully.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error editing/removing question: {ex.Message}");
            }
        }


        static void DuplicateExam(Instructor instructor)
        {
            try
            {
                var exam = PickExam();
                if (exam == null) return;

                var targetCourse = PickCourse("Select target course: ");
                if (targetCourse == null) return;

                Console.Write("New start (yyyy-MM-dd HH:mm): "); var s = Console.ReadLine();
                Console.Write("New end (yyyy-MM-dd HH:mm): "); var e = Console.ReadLine();
                if (!DateTime.TryParse(s, out DateTime start) || !DateTime.TryParse(e, out DateTime end)) return;

                var copy = exam.DuplicateExam(targetCourse, instructor, start, end);
                if (copy != null)
                {
                    targetCourse.AddExam(copy);
                    Console.WriteLine($"Duplicated exam to {targetCourse.Title}");
                }
                else
                {
                    Console.WriteLine("Exam duplication failed.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error duplicating exam: {ex.Message}");
            }
        }


        static void RescheduleOrLockExam()
        {
            try
            {
                var exam = PickExam();
                if (exam == null) return;

                Console.WriteLine("1) Reschedule  2) Lock");
                var opt = Console.ReadLine();
                if (opt == "1")
                {
                    Console.Write("New start: "); var s = Console.ReadLine();
                    Console.Write("New end: "); var e = Console.ReadLine();
                    if (!DateTime.TryParse(s, out DateTime start) || !DateTime.TryParse(e, out DateTime end)) return;
                    exam.Reschedule(start, end);
                    Console.WriteLine("Rescheduled.");
                }
                else if (opt == "2")
                {
                    exam.LockExam();
                    Console.WriteLine("Locked.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error rescheduling/locking exam: {ex.Message}");
            }
        }

        static void GradeEssayForStudent(Instructor instructor)
        {
            try
            {
                var course = PickCourse("Pick course: ");
                if (course == null) return;

                var exam = PickExamFromCourse(course);
                if (exam == null) return;

                var student = PickStudentFromCourse(course);
                if (student == null) return;

                var result = student.GetResult(exam);
                if (result == null) { Console.WriteLine("Student didn't take exam"); return; }

                foreach (var eq in result.Answers.Keys.OfType<EssayQuestion>())
                {
                    Console.WriteLine($"Essay: {eq.Text}");
                    Console.WriteLine($"Answer: {result.Answers[eq]}");
                    Console.Write($"Grade (0-{eq.Marks}): ");
                    int g = int.Parse(Console.ReadLine());
                    result.GradeEssay(eq, g);
                }

                Console.WriteLine($"Updated score: {result.Score}/{exam.Course.MaxDegree}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error grading essay: {ex.Message}");
            }
        }

        static void ShowCourseReport()
        {
            try
            {
                var course = PickCourse();
                if (course == null) return;
                course.GenerateReport();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error showing course report: {ex.Message}");
            }
        }

        static void CompareStudentsInExam()
        {
            try
            {
                var course = PickCourse();
                if (course == null) return;
                var exam = PickExamFromCourse(course);
                if (exam == null) return;
                course.CompareStudents(exam);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error comparing students: {ex.Message}");
            }
        }
        static void AddStudent()
        {
            try
            {
                Console.Write("Enter student name: ");
                string sName = Console.ReadLine();
                Console.Write("Enter student email: ");
                string sEmail = Console.ReadLine();
                var s = Student.CreateStudent(sName, sEmail);
                students.Add(s);
                Console.WriteLine($" Added Student: {s.Name} (ID: {s.Id})");
            }
            catch (Exception ex)
            {
                Console.WriteLine($" Error adding student: {ex.Message}");
            }
        }
        static void AddInstructor()
        {
            try
            {
                Console.Write("Instructor name: ");
                var name = Console.ReadLine();
                Console.Write("Specialization: ");
                var spec = Console.ReadLine();
                var i = Instructor.CreateInstructor(name, spec);
                instructors.Add(i); Console.WriteLine($" Added Instructor: {i.Name} (ID: {i.Id})");
            }
            catch (Exception ex)
            {
                Console.WriteLine($" Error adding instructor: {ex.Message}");
            }
        }
        static void EditStudent()
        {
            try
            {
                var student = PickStudent("Pick student to edit: ");
                if (student == null) return;

                Console.Write("New name (leave blank to keep current): ");
                var newName = Console.ReadLine();
                if (!string.IsNullOrEmpty(newName)) student.Name = newName;

                Console.Write("New email (leave blank to keep current): ");
                var newEmail = Console.ReadLine();
                if (!string.IsNullOrEmpty(newEmail)) student.Email = newEmail;

                Console.WriteLine($"Student updated: {student.Name} ({student.Email})");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error editing student: {ex.Message}");
            }
        }
        static void RemoveStudent()
        {
            try
            {
                var student = PickStudent("Pick student to remove: ");
                if (student == null) return;

                foreach (var course in student.GetEnrolledCourses())
                {
                    course.RemoveStudent(student);  
                }

                students.Remove(student);
                Console.WriteLine($"Student {student.Name} has been removed from the system.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error removing student: {ex.Message}");
            }
        }
        static void EditInstructor()
        {
            try
            {
                var instructor = PickInstructor("Pick instructor to edit: ");
                if (instructor == null) return;

                Console.Write("New name (leave blank to keep current): ");
                var newName = Console.ReadLine();
                if (!string.IsNullOrEmpty(newName)) instructor.Name = newName;

                Console.Write("New specialization (leave blank to keep current): ");
                var newSpec = Console.ReadLine();
                if (!string.IsNullOrEmpty(newSpec)) instructor.Specialization = newSpec;

                Console.WriteLine($"Instructor updated: {instructor.Name} ({instructor.Specialization})");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error editing instructor: {ex.Message}");
            }
        }
        static void RemoveInstructor()
        {
            try
            {
                var instructor = PickInstructor("Pick instructor to remove: ");
                if (instructor == null) return;

                foreach (var course in instructor.GetCourses())
                {
                    course.UnassignInstructor(instructor);
                }

                instructors.Remove(instructor);
                Console.WriteLine($"Instructor {instructor.Name} has been removed from the system.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error removing instructor: {ex.Message}");
            }
        }


        // ========================= Pickers =========================
        static Student PickStudent(string prompt = "Pick a student by index: ")
        {
            if (!students.Any()) { Console.WriteLine("No students available. you must add one to continue");
                AddStudent();

            }
            for (int i = 0; i < students.Count; i++)
                Console.WriteLine($"{i}. {students[i].Name} ({students[i].Email})");
            Console.Write(prompt);
            if (!int.TryParse(Console.ReadLine(), out int idx) || idx < 0 || idx >= students.Count) return null;
            return students[idx];
        }

        static Instructor PickInstructor(string prompt = "Pick instructor by index: ")
        {
            if (!instructors.Any()) { Console.WriteLine("No instructors available. you must add one first");
                AddInstructor();    
            }
            for (int i = 0; i < instructors.Count; i++)
                Console.WriteLine($"{i}. {instructors[i].Name} ({instructors[i].Specialization})");
            Console.Write(prompt);
            if (!int.TryParse(Console.ReadLine(), out int idx) || idx < 0 || idx >= instructors.Count) return null;
            return instructors[idx];
        }

        static Course PickCourse(string prompt = "Pick course by index: ")
        {
            if (!courses.Any()) { Console.WriteLine("No courses available."); return null; }
            for (int i = 0; i < courses.Count; i++)
                Console.WriteLine($"{i}. {courses[i].Title} (Max {courses[i].MaxDegree})");
            Console.Write(prompt);
            if (!int.TryParse(Console.ReadLine(), out int idx) || idx < 0 || idx >= courses.Count) return null;
            return courses[idx];
        }

        static Exam PickExam()
        {
            var exams = courses.SelectMany(c => c.Exams).ToList();
            if (!exams.Any()) { Console.WriteLine("No exams available."); return null; }
            for (int i = 0; i < exams.Count; i++)
                Console.WriteLine($"{i}. {exams[i].Title} (Course: {exams[i].Course.Title})");
            Console.Write("Pick exam index: ");
            if (!int.TryParse(Console.ReadLine(), out int idx) || idx < 0 || idx >= exams.Count) return null;
            return exams[idx];
        }

        static Exam PickExamFromCourse(Course course)
        {
            var exams = course.Exams.ToList();
            if (!exams.Any()) { Console.WriteLine("No exams in this course."); return null; }
            for (int i = 0; i < exams.Count; i++)
                Console.WriteLine($"{i}. {exams[i].Title} ({exams[i].StartTime} - {exams[i].StartTime + exams[i].Duration})");
            Console.Write("Pick exam index: ");
            if (!int.TryParse(Console.ReadLine(), out int idx) || idx < 0 || idx >= exams.Count) return null;
            return exams[idx];
        }

        static Student PickStudentFromCourse(Course course)
        {
            var studentsInCourse = course.EnrolledStudents.ToList();
            if (!studentsInCourse.Any()) { Console.WriteLine("No students in course."); return null; }
            for (int i = 0; i < studentsInCourse.Count; i++)
                Console.WriteLine($"{i}. {studentsInCourse[i].Name}");
            Console.Write("Pick student index: ");
            if (!int.TryParse(Console.ReadLine(), out int idx) || idx < 0 || idx >= studentsInCourse.Count) return null;
            return studentsInCourse[idx];
        }
    }
}
