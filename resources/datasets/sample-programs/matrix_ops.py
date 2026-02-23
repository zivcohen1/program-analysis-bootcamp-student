"""Matrix operations without external libraries."""


def create_matrix(rows, cols, fill=0):
    """Create a matrix filled with a default value."""
    return [[fill] * cols for _ in range(rows)]


def matrix_multiply(a, b):
    """Multiply two matrices."""
    rows_a, cols_a = len(a), len(a[0])
    rows_b, cols_b = len(b), len(b[0])
    if cols_a != rows_b:
        raise ValueError(f"Incompatible dimensions: {cols_a} vs {rows_b}")
    result = create_matrix(rows_a, cols_b)
    for i in range(rows_a):
        for j in range(cols_b):
            for k in range(cols_a):
                result[i][j] += a[i][k] * b[k][j]
    return result


def matrix_transpose(m):
    """Transpose a matrix."""
    rows, cols = len(m), len(m[0])
    return [[m[i][j] for i in range(rows)] for j in range(cols)]


def matrix_add(a, b):
    """Add two matrices."""
    rows, cols = len(a), len(a[0])
    if len(b) != rows or len(b[0]) != cols:
        raise ValueError("Matrices must have the same dimensions")
    return [[a[i][j] + b[i][j] for j in range(cols)] for i in range(rows)]


def identity_matrix(n):
    """Create an n x n identity matrix."""
    m = create_matrix(n, n)
    for i in range(n):
        m[i][i] = 1
    return m


def determinant(m):
    """Compute the determinant of a square matrix."""
    n = len(m)
    if n == 1:
        return m[0][0]
    if n == 2:
        return m[0][0] * m[1][1] - m[0][1] * m[1][0]
    det = 0
    for j in range(n):
        minor = [row[:j] + row[j + 1:] for row in m[1:]]
        cofactor = ((-1) ** j) * m[0][j] * determinant(minor)
        det += cofactor
    return det


def print_matrix(m):
    """Pretty print a matrix."""
    for row in m:
        print("  ".join(f"{val:6.2f}" for val in row))


if __name__ == "__main__":
    a = [[1, 2], [3, 4]]
    b = [[5, 6], [7, 8]]
    print("A * B =")
    print_matrix(matrix_multiply(a, b))
    print(f"\ndet(A) = {determinant(a)}")
