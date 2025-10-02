using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Entity_FrameWork_2.Models
{
    public class StudentAnswer
    {
        [Key]
        public int Id { get; set; }

        [Required, MaxLength(2000)]
        public string AnswerText { get; set; }

        public char? SelectedOption { get; set; }
        public bool? BooleanAnswer { get; set; }

        [Column(TypeName = "decimal(10,2)")]
        public decimal? MarksObtained { get; set; }

        [Required]
        public DateTime SubmittedAt { get; set; }

        public int ExamAttemptId { get; set; }
        public int QuestionId { get; set; }

        public ExamAttempt ExamAttempt { get; set; }
        public Question Question { get; set; }
    }
}