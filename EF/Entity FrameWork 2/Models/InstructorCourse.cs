using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entity_FrameWork_2.Models
{
    public class InstructorCourse
    {
        public int InstructorId { get; set; }
        public int CourseId { get; set; }

        [Required]
        public DateTime AssignedDate { get; set; }

        public bool IsActive { get; set; } = true;

        public Instructor Instructor { get; set; }
        public Course Course { get; set; }
    }
}
