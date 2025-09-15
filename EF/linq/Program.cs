using System;
using System.Linq;
using System.Collections.Generic;
using LibraryManagementSystem;     
using LINQ_DATA;                  

namespace LINQ_Practice
{
    class Program
    {
        static void Main()
        {
            var books = LibraryData.Books;
            var authors = LibraryData.Authors;
            var members = LibraryData.Members;
            var loans = LibraryData.Loans;

            var availableBooks = books.Where(b => b.IsAvailable);
            availableBooks.ToConsoleTable("Available Books");

            var allTitles = books.Select(b => b.Title);
            allTitles.ToConsoleTable("Titles", "All Book Titles");

            var programmingBooks = books.Where(b => b.Genre == "Programming");
            programmingBooks.ToConsoleTable("Programming Books");

            var booksSorted = books.OrderBy(b => b.Title);
            booksSorted.ToConsoleTable("Books Sorted by Title");

            var expensiveBooks = books.Where(b => b.Price > 30);
            expensiveBooks.ToConsoleTable("Expensive Books > $30");

            var uniqueGenres = books.Select(b => b.Genre).Distinct();
            uniqueGenres.ToConsoleTable("Genre", "Unique Genres");

            var countByGenre = books
                .GroupBy(b => b.Genre)
                .Select(g => new { Genre = g.Key, Count = g.Count() });
            countByGenre.ToConsoleTable("Books Count by Genre");

            var recentBooks = books.Where(b => b.PublishedYear > 2010);
            recentBooks.ToConsoleTable("Books Published After 2010");

            var firstFive = books.Take(5);
            firstFive.ToConsoleTable("First 5 Books");

            bool anyOver50 = books.Any(b => b.Price > 50);
            Console.WriteLine($"\nAny book priced over $50? {anyOver50}\n");

            var bookAuthors = books.Join(authors,
                                         b => b.AuthorId,
                                         a => a.Id,
                                         (b, a) => new { b.Title, AuthorName = a.Name, b.Genre });
            bookAuthors.ToConsoleTable("Book / Author / Genre");

            var avgPriceGenre = books
                .GroupBy(b => b.Genre)
                .Select(g => new { Genre = g.Key, AveragePrice = g.Average(b => b.Price) });
            avgPriceGenre.ToConsoleTable("Average Price by Genre");

            var mostExpensive = books
                .OrderByDescending(b => b.Price)
                .First();
            new[] { mostExpensive }.ToConsoleTable("Most Expensive Book");

            var byDecade = books
                .GroupBy(b => (b.PublishedYear / 10) * 10) 
                .Select(g => new
                {
                    Decade = $"{g.Key}s",
                    Books = string.Join(", ", g.Select(b => b.Title))
                });
            byDecade.ToConsoleTable("Books Grouped by Decade");

            var activeLoanMembers = members
                .Where(m => loans.Any(l => l.MemberId == m.Id && l.ReturnDate == null));
            activeLoanMembers.ToConsoleTable("Members with Active Loans");

            var borrowedMultiple = loans
                .GroupBy(l => l.BookId)
                .Where(g => g.Count() > 1)
                .Join(books, g => g.Key, b => b.Id,
                      (g, b) => new { b.Title, LoanCount = g.Count() });
            borrowedMultiple.ToConsoleTable("Books Borrowed More Than Once");

            var overdue = loans
                .Where(l => l.ReturnDate == null && l.DueDate < DateTime.Now)
                .Join(books, l => l.BookId, b => b.Id,
                      (l, b) => new { b.Title, l.DueDate });
            overdue.ToConsoleTable("Overdue Books");

            var authorBookCounts = authors
                .GroupJoin(books,
                           a => a.Id,
                           b => b.AuthorId,
                           (a, g) => new { a.Name, Count = g.Count() })
                .OrderByDescending(x => x.Count);
            authorBookCounts.ToConsoleTable("Author Book Counts");

            var priceRanges = books
                .GroupBy(b =>
                    b.Price < 20 ? "Cheap (<20)" :
                    b.Price <= 40 ? "Medium (20-40)" : "Expensive (>40)")
                .Select(g => new { Range = g.Key, Count = g.Count() });
            priceRanges.ToConsoleTable("Price Range Analysis");

            var memberStats = members
                .Select(m => new
                {
                    m.FullName,
                    TotalLoans = loans.Count(l => l.MemberId == m.Id),
                    ActiveLoans = loans.Count(l => l.MemberId == m.Id && l.ReturnDate == null),
                    AverageDaysBorrowed = loans
                        .Where(l => l.MemberId == m.Id && l.ReturnDate != null)
                        .Select(l => (l.ReturnDate.Value - l.LoanDate).TotalDays)
                        .DefaultIfEmpty(0)
                        .Average()
                });
            memberStats.ToConsoleTable("Member Loan Statistics");

            Console.WriteLine("\n--- All LINQ Queries Executed ---");
        }
    }
}
