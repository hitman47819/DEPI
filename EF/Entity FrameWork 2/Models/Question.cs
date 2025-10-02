﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entity_FrameWork_2.Models
{
    public enum QuestionType
    {
        MultipleChoice,
        TrueFalse,
        Essay
    }
    public abstract class Question
    {
        public int Id { get; set; }
        [Required, MaxLength(1000)]
        public string QuestionText { get; set; }
        [Required, Column(TypeName = "decimal(10,2)")]
        public decimal Marks { get; set; }
        [Required]
        public QuestionType QuestionType { get; set; }
        [Required]
        public DateTime CreatedDate { get; set; }

        public int ExamId { get; set; }
        public Exam Exam { get; set; }
        public ICollection<StudentAnswer> StudentAnswers { get; set; } = new List<StudentAnswer>();
    }

}
