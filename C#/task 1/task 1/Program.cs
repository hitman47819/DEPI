namespace task_1
{
    internal class Program
    {
        static void Main(string[] args)
        {
            int num1 = 0, num2 = 0, value;
            string option = ""; // Initialize as an empty string to enter the loop
            Console.WriteLine("Hello!\r\nInput the first number:");

            // Read the first number
            while (!int.TryParse(Console.ReadLine(), out num1))
            {
                Console.WriteLine("Invalid input. Please enter a valid number:");
            }

            Console.WriteLine("Input the second number:");

            // Read the second number
            while (!int.TryParse(Console.ReadLine(), out num2))
            {
                Console.WriteLine("Invalid input. Please enter a valid number:");
            }


            while (true)
            {
                Console.WriteLine("What do you want to do with those numbers?\r\n[A]dd\r\n[S]ubtract\r\n[M]ultiply\r\n or [C]lose");
                // Read user option
                option = Console.ReadLine().ToLower();
                if (option == "c") {
                    break;
                }
                else if (option == "a")
                {
                    value = num1 + num2;
                    Console.WriteLine($"{num1} + {num2} = {value}");
                }
                else if (option == "s")
                {
                    value = num1 - num2;
                    Console.WriteLine($"{num1} - {num2} = {value}");
                }
                else if (option == "m")
                {
                    value = num1 * num2;
                    Console.WriteLine($"{num1} * {num2} = {value}");
                }
                else
                {
                    Console.WriteLine("Invalid option. Please enter A, S, or M.");
                }
            }

            Console.WriteLine("Press any key to close.");
            Console.ReadKey();  // Wait for the user to press any key before closing
        }
    }
}
