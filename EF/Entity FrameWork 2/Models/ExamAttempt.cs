using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Entity_FrameWork_2.Models
{
    public class ExamAttempt
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public DateTime StartTime { get; set; }

        public DateTime? EndTime { get; set; }

        [Column(TypeName = "decimal(10,2)")]
        public decimal? TotalScore { get; set; }

        public bool IsSubmitted { get; set; } = false;
        public bool IsGraded { get; set; } = false;

        public int StudentId { get; set; }
        public int ExamId { get; set; }

        public Student Student { get; set; }
        public Exam Exam { get; set; }
        public ICollection<StudentAnswer> StudentAnswers { get; set; } = new List<StudentAnswer>();

    }
}