﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entity_FrameWork_2.Models
{
    public class TrueFalseQuestion : Question
    {
        [Required]
        public bool CorrectAnswer { get; set; }
    }
}
