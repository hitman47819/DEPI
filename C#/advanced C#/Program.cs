class Program
{
    static async Task Main(string[] args)
    {
        // ================= PhoneBook =================
        SafeRunner.RunSafe("PhoneBook Demo", () =>
        {
            PhoneBook phoneBook = new PhoneBook();

            phoneBook.AddContact("Ali", "01001234567");
            phoneBook.AddContact("Sara", "01017654321");

            if (phoneBook.TryGetNumber("Ali", out string? aliNumber))
                Console.WriteLine($"Ali's number: {aliNumber}");


            phoneBook.UpdateContact("Ali", "01009876543");
            Console.WriteLine($"Updated Ali's number: {phoneBook["Ali"]}");
            Console.WriteLine($"Lookup Sara: {phoneBook["Sara"]}");
        });

        // ================= WeeklySchedule =================
        SafeRunner.RunSafe("Weekly Schedule Demo", () =>
        {
            WeeklySchedule schedule = new WeeklySchedule();

            schedule.AddTask(DayOfWeek.Monday, "Study C#");
            schedule.AddTask(DayOfWeek.Monday, "Go to Gym");
            schedule.AddTask(DayOfWeek.Tuesday, "Project Meeting");

            Console.WriteLine("Tasks on Monday:");
            foreach (var task in schedule.GetTasks(DayOfWeek.Monday))
                Console.WriteLine($"- {task}");

            schedule.UpdateTask(DayOfWeek.Monday, "Go to Gym", "Swimming");

            schedule.RemoveTask(DayOfWeek.Tuesday, "Project Meeting");

            Console.WriteLine("\nUsing indexer to read first Monday task:");
            Console.WriteLine(schedule[DayOfWeek.Monday, 0]);

            schedule[DayOfWeek.Monday, 0] = "Read Design Patterns";

            schedule.ClearTasks(DayOfWeek.Monday);
        });
        // ================= Timer =================
        SafeRunner.RunSafe("Timer Demo", () =>
        {
            SimpleTimer timer = new SimpleTimer(10);



            timer.Start();

            Thread.Sleep(12000);
        });
        //================= stack ================
        SafeRunner.RunSafe("Stack Demo", () =>
        {
            var stack = new Stack<int>();

            Console.WriteLine("Pushing elements...");
            stack.Push(10);
            stack.Push(20);
            stack.Push(30);

            stack.Print(); // يطبع 30, 20, 10

            Console.WriteLine($"Peek: {stack.Peek()}"); // 30
            Console.WriteLine($"Pop: {stack.Pop()}");   // 30

            stack.Print(); // يطبع 20, 10

            Console.WriteLine($"Count: {stack.Count}");
            Console.WriteLine($"Is Empty? {stack.IsEmpty}");

            Console.WriteLine("Clearing stack...");
            stack.Clear();
            Console.WriteLine($"Is Empty after clear? {stack.IsEmpty}");
        });
        // ================= Pair =================
        SafeRunner.RunSafe("Pair Demo", () =>
        {
            // Pair of int and string
            Pair<int, string> idName = new Pair<int, string>(1, "Ali");
            Console.WriteLine(idName);

            // Pair of string and string
            Pair<string, string> countryCapital = new Pair<string, string>("Egypt", "Cairo");
            Console.WriteLine(countryCapital);
        });
        // ================= cache ===============
        SafeRunner.RunSafe("Cache Demo", () =>
            {
                var cache = new Cache<string, string>();

                cache.Add("user1", "Alice", TimeSpan.FromSeconds(5));
                cache.Add("user2", "Bob", TimeSpan.FromSeconds(10));

                if (cache.TryGetValue("user1", out var user1))
                    Console.WriteLine($"user1: {user1}");

                Console.WriteLine($"Cache['user2']: {cache["user2"]}");

                cache.AddOrUpdate("user1", "Alice Updated", TimeSpan.FromSeconds(5));
                Console.WriteLine($"Updated user1: {cache["user1"]}");

                Console.WriteLine("Waiting 3 seconds...");
                System.Threading.Thread.Sleep(3000);

                if (!cache.TryGetValue("user1", out _))
                    Console.WriteLine("user1 has expired from cache.");

                Console.WriteLine($"Cache count after expiration: {cache.Count}");
            });
        // ================ collection==============
        SafeRunner.RunSafe("ConvertList Demo", () =>
               {
                   List<int> numbers = new() { 1, 2, 3, 4 };
                   List<string> strings = numbers.ConvertList(n => $"Num-{n}");

                   Console.WriteLine("Converted List:");
                   foreach (var s in strings)
                       Console.WriteLine(s);
               });
        SafeRunner.RunSafe("AverageNullable Demo", () =>
            {
                List<int?> nullableNumbers = new() { 10, null, 20, 30, null };
                double avg = nullableNumbers.AverageNullable();
                Console.WriteLine($"Average of numbers (ignoring nulls): {avg}");
            });
        //=============repositry=================
        SafeRunner.RunSafe("Repository Demo", () =>
            {
                var repo = new Repository<EntityPair>();

                repo.Add(new EntityPair(1, "One"));
                repo.Add(new EntityPair(2, "Two"));

                Console.WriteLine("All items:");
                foreach (var item in repo.GetAll())
                    Console.WriteLine(item);

                var first = repo.GetById(1);
                Console.WriteLine($"GetById(1): {first}");

                repo.Update(new EntityPair(1, "Updated One"));
                Console.WriteLine("After update:");
                foreach (var item in repo.GetAll())
                    Console.WriteLine(item);

                repo.Remove(2);
                Console.WriteLine("After remove:");
                foreach (var item in repo.GetAll())
                    Console.WriteLine(item);
            });
        //=============== ContactManager  ==============
        SafeRunner.RunSafe("Contact Manager Demo", () =>
        {
            ContactManager manager = new ContactManager();

            manager.AddContact(new Contact(1, "Ali", "ali@example.com"));
            manager.AddContact(new Contact(2, "Sara", "sara@example.com"));
            manager.AddContact(new Contact(3, "Sami", "sami@example.com"));

            Console.WriteLine("All Contacts:");
            foreach (var c in manager.GetAllContacts())
                Console.WriteLine(c);

            Console.WriteLine("\nUpdate Ali's Email:");
            var ali = manager.GetContactById(1);
            if (ali != null)
            {
                ali.Email = "ali.new@example.com";
                manager.UpdateContact(ali);
            }
            Console.WriteLine(manager[1]);

            Console.WriteLine("\nSearch for 'Sa':");
            foreach (var c in manager.SearchByName("Sa"))
                Console.WriteLine(c);

            Console.WriteLine("\nRemove Sami:");
            manager.RemoveContact(3);
            foreach (var c in manager.GetAllContacts())
                Console.WriteLine(c);
        });
        // ================ shopping cart================
        SafeRunner.RunSafe("Shopping Cart Demo", () =>
           {
               ShoppingCart cart = new ShoppingCart();

               cart.AddItem("Book", 2);
               cart.AddItem("Pen");
               cart.AddItem("Notebook", 3);

               Console.WriteLine("Cart Items:");
               foreach (var kvp in cart.GetItems())
                   Console.WriteLine($"{kvp.Key}: {kvp.Value}");

               cart.ApplyDiscount("Notebook");

               decimal total = cart.GetTotalPrice(item =>
               {
                   return item switch
                   {
                       "Book" => 15m,
                       "Pen" => 2m,
                       "Notebook" => 5m,
                       _ => 0m
                   };
               });
               Console.WriteLine($"Total Price: {total:C}");

               cart.RemoveItem("Pen");
               Console.WriteLine("After removing Pen:");
               foreach (var kvp in cart.GetItems())
                   Console.WriteLine($"{kvp.Key}: {kvp.Value}");
           });
        // ================= Person =================
        SafeRunner.RunSafe("Person Demo", () =>
        {
            Person p1 = new Person("Ali", "Hassan", "Mohamed", new DateTime(1995, 5, 20));
            Person p2 = new Person("Sara", "Ahmed");
            Console.WriteLine(p1);
            Console.WriteLine($"Age: {p1.GetAge()?.ToString() ?? "Unknown"}");

            Console.WriteLine(p2);
            Console.WriteLine($"Age: {p2.GetAge()?.ToString() ?? "Unknown"}");

            p2.MiddleName = "Fatma";
            p2.DateOfBirth = new DateTime(2000, 1, 15);

            Console.WriteLine("\nAfter updating Sara:");
            Console.WriteLine(p2);
            Console.WriteLine($"Age: {p2.GetAge()?.ToString() ?? "Unknown"}");
        });
        //================== int extension ==================
        SafeRunner.RunSafe("Int Extensions Demo", () =>
        {
            int number = 29;
            Console.WriteLine($"Number: {number}");
            Console.WriteLine($"Is Even: {number.IsEven()}");
            Console.WriteLine($"Is Odd: {number.IsOdd()}");
            Console.WriteLine($"Is Prime: {number.isPrime()}");
            Console.WriteLine($"To Roman: {number.ToRoman()}");
            Console.WriteLine($"Factorial: {number.Factorial()}");

            number = 10;
            Console.WriteLine($"\nNumber: {number}");
            Console.WriteLine($"Is Even: {number.IsEven()}");
            Console.WriteLine($"Is Odd: {number.IsOdd()}");
            Console.WriteLine($"Is Prime: {number.isPrime()}");
            Console.WriteLine($"To Roman: {number.ToRoman()}");
            Console.WriteLine($"Factorial: {number.Factorial()}");


        });
        //================== DateTime extension ==================
        SafeRunner.RunSafe("DateTimeExtensions Demo", () =>
            {
                DateTime today = DateTime.Today;
                Console.WriteLine($"Today: {today:yyyy-MM-dd}");
                Console.WriteLine($"Is weekend? {today.IsWeekend()}");
                Console.WriteLine($"Start of month: {today.StartOfMonth():yyyy-MM-dd}");
                Console.WriteLine($"End of month: {today.EndOfMonth():yyyy-MM-dd}");
                Console.WriteLine($"Start of week: {today.StartOfWeek():yyyy-MM-dd}");
                Console.WriteLine($"End of week: {today.EndOfWeek():yyyy-MM-dd}");
                Console.WriteLine($"Age if born 2000-01-15: {new DateTime(2000, 1, 15).Age()}");
                Console.WriteLine($"Add 5 business days: {today.AddBusinessDays(5):yyyy-MM-dd}");
            });
        //================== matrix =================
        SafeRunner.RunSafe("Matrix Demo", () =>
            {
                Matrix<int> matrix = new Matrix<int>(3, 3);

                int counter = 1;
                for (int i = 0; i < 3; i++)
                {
                    for (int j = 0; j < 3; j++)
                    {
                        matrix[i, j] = counter++;
                    }
                }

                Console.WriteLine("Matrix contents:");
                Console.WriteLine(matrix);

                matrix[1, 1] = 99;
                Console.WriteLine("After updating [1,1]:");
                Console.WriteLine(matrix);
            });
        //==================  notifier =================
        SafeRunner.RunSafe("Notification System Demo", () =>
            {
                NotificationSystem notifier = new NotificationSystem();

                notifier.RegisterChannel(msg => Console.WriteLine($"Console: {msg}"));
                notifier.RegisterChannel(msg => Console.WriteLine($"SMS: {msg}"));
                notifier.RegisterChannel(msg => Console.WriteLine($"Email: {msg}"));

                Console.WriteLine("Sending first message...");
                notifier.Send("Hello! This is a test notification.");

                notifier.UnregisterChannel(msg => Console.WriteLine($"SMS: {msg}"));

                Console.WriteLine("\nSending second message after removing SMS channel...");
                notifier.Send("Second notification after unregistering SMS.");

                int count = notifier.SendWithStatus("Notification with status feedback");
                Console.WriteLine($"\nTotal channels that received the message successfully: {count}");
            });
        //================== plugin system =================
        SafeRunner.RunSafe("Plugin System Demo", () =>
            {
                var pluginSystem = new PluginSystem<int>();

                pluginSystem.RegisterRule(x => Console.WriteLine($"Rule 1: double = {x * 2}"));
                pluginSystem.RegisterRule(x => Console.WriteLine($"Rule 2: squared = {x * x}"));

                pluginSystem.ExecuteRules(5);
            });
        //================== Data Pipeline =================
        SafeRunner.RunSafe("Data Processing Pipeline Demo", () =>
            {
                var pipeline = new DataPipeline<int>();

                pipeline.AddStep(nums => nums);
                pipeline.AddStep(nums => nums.Where(n => n % 2 == 0));
                pipeline.AddStep(nums => nums.Select(n => n * n));

                List<int> numbers = new() { 1, 2, 3, 4, 5, 6 };
                var processed = pipeline.Execute(numbers);

                Console.WriteLine("Pipeline output:");
                foreach (var n in processed)
                    Console.WriteLine(n);
            });

        //================== Calculator with Delegates =================
        SafeRunner.RunSafe("Calculator Delegates Demo", () =>
             {
                 Calculator.Operation add = (a, b) => a + b;
                 Calculator.Operation subtract = (a, b) => a - b;
                 Calculator.Operation multiply = (a, b) => a * b;
                 Calculator.Operation divide = (a, b) =>
                 {
                     if (b == 0) throw new DivideByZeroException("Cannot divide by zero");
                     return a / b;
                 };

                 Calculator.Operation operations = add;
                 operations += multiply;

                 double x = 10, y = 5;
                 Console.WriteLine($"Add: {add(x, y)}");
                 Console.WriteLine($"Subtract: {subtract(x, y)}");
                 Console.WriteLine($"Multiply: {multiply(x, y)}");
                 Console.WriteLine($"Divide: {divide(x, y)}");

                 double result = operations(x, y);
                 Console.WriteLine($"Result (last operation value): {result}");

                 operations += divide;
                 result = operations(x, y);
                 Console.WriteLine($"Result after adding divide: {result}");
             });
        // =================== Lambda Expressions  =================
        SafeRunner.RunSafe("Lambda Expressions Demo", () =>
            {
                List<int> grades = new() { 90, 75, 82, 68, 95, 88 };

                var highGrades = grades.Where(g => g > 80);
                Console.WriteLine("High grades (>80):");
                foreach (var g in highGrades)
                    Console.WriteLine(g);

                var curvedGrades = grades.Select(g => g + 5);
                Console.WriteLine("\nCurved grades (+5):");
                foreach (var g in curvedGrades)
                    Console.WriteLine(g);

                var average = grades.Average();
                Console.WriteLine($"\nAverage grade: {average}");
            });
        // =================== Validation Framework   =================
        SafeRunner.RunSafe("Validation Framework Demo", () =>
        {
            var stringValidator = new Validator<string>();
            stringValidator.AddRule(s => !string.IsNullOrWhiteSpace(s), "String cannot be empty");
            stringValidator.AddRule(s => s.Length >= 5, "String must be at least 5 characters long");

            string testValue = "Hello";
            stringValidator.Validate(testValue);
            Console.WriteLine($"'{testValue}' passed validation.");

            string invalidValue = "abc";

            stringValidator.Validate(invalidValue);

        });
        // ================= Thread-safe Counter =================
        SafeRunner.RunSafe("Thread-safe Counter Demo", () =>
        {
            ThreadSafeCounter counter = new ThreadSafeCounter();

            Thread[] threads = new Thread[10];

            for (int i = 0; i < 5; i++)
            {
                threads[i] = new Thread(() =>
                {
                    for (int j = 0; j < 1000; j++)
                        counter.Increment();
                });
            }
            Console.WriteLine($"thread counter value: {counter.Count}");

            for (int i = 5; i < 10; i++)
            {
                threads[i] = new Thread(() =>
                {
                    for (int j = 0; j < 1000; j++)
                        counter.Decrement();
                });
            }

            foreach (var t in threads) t.Start();
            foreach (var t in threads) t.Join();

            Console.WriteLine($"Final counter value: {counter.Count}");
        });
        // ================= Async File Operations =================
        await SafeRunner.RunSafeAsync("Async File Operations Demo", async () =>
        {
            await AsyncFileOps.ReadFileAsync("test.txt");
            await AsyncFileOps.WriteFileAsync("output.txt", "Hello Async!");
        });

        // ================= Async Downloader =================
        await SafeRunner.RunSafeAsync("Async Downloader Demo", async () =>
        {
            string[] urls = { "https://example.com/file1", "https://example.com/file2" };
            await AsyncDownloader.DownloadFilesAsync(urls);
        });

        // ================= Async Email Sender =================
        await SafeRunner.RunSafeAsync("Async Email Sender Demo", async () =>
        {
            string[] emails = { "a@example.com", "b@example.com" };
            await AsyncEmailSender.SendEmailsAsync(emails, "Subject", "Hello from async!");
        });
        //=========== trabsactuib =================
        SafeRunner.RunSafe("Transaction Rollback Demo", () =>
        {
            var tm = new TransactionManager();
            int value = 10;

            tm.Execute(
                action: () =>
                {
                    Console.WriteLine($"Performing operation, value = {value}");
                    value += 5;
                    throw new Exception("Oops! Something went wrong");
                },
                rollback: () =>
                {
                    value -= 5;
                    Console.WriteLine($"Rolled back, value = {value}");
                }
            );
        });
        //============ background worker =================
        SafeRunner.RunSafe("Async Background Worker Demo", () =>
        {
            var worker = new AsyncWorker();
            worker.Start();

            Thread.Sleep(4000); 
            worker.Stop();
        });

        // ================= End =================
    }
}
