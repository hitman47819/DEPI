 using System;

public class Matrix<T>
{
    private readonly T[,] data;

    public int Rows { get; }
    public int Columns { get; }

    public Matrix(int rows, int columns)
    {
        if (rows <= 0 || columns <= 0)
            throw new ArgumentException("Rows and columns must be positive.");

        Rows = rows;
        Columns = columns;
        data = new T[rows, columns];
    }

    public T this[int row, int col]
    {
        get
        {
            if (row < 0 || row >= Rows || col < 0 || col >= Columns)
                throw new IndexOutOfRangeException();
            return data[row, col];
        }
        set
        {
            if (row < 0 || row >= Rows || col < 0 || col >= Columns)
                throw new IndexOutOfRangeException();
            data[row, col] = value;
        }
    }

    public override string ToString()
    {
        var result = "";
        for (int i = 0; i < Rows; i++)
        {
            for (int j = 0; j < Columns; j++)
            {
                result += data[i, j] + "\t";
            }
            result += "\n";
        }
        return result;
    }
}
