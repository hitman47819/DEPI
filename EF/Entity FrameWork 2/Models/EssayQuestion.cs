using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entity_FrameWork_2.Models
{
    public class EssayQuestion:Question
    {
        public int? MaxWordCount { get; set; }

        [MaxLength(1000)]
        public string? GradingCriteria { get; set; }
    }
}
