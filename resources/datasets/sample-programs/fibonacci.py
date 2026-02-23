"""Fibonacci sequence implementations."""


def fibonacci_recursive(n):
    """Compute the nth Fibonacci number recursively."""
    if n <= 0:
        return 0
    if n == 1:
        return 1
    return fibonacci_recursive(n - 1) + fibonacci_recursive(n - 2)


def fibonacci_iterative(n):
    """Compute the nth Fibonacci number iteratively."""
    if n <= 0:
        return 0
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b


def fibonacci_memoized(n, memo=None):
    """Compute the nth Fibonacci number with memoization."""
    if memo is None:
        memo = {}
    if n in memo:
        return memo[n]
    if n <= 0:
        return 0
    if n == 1:
        return 1
    memo[n] = fibonacci_memoized(n - 1, memo) + fibonacci_memoized(n - 2, memo)
    return memo[n]


def fibonacci_generator(limit):
    """Generate Fibonacci numbers up to a limit."""
    a, b = 0, 1
    while a < limit:
        yield a
        a, b = b, a + b


if __name__ == "__main__":
    for i in range(10):
        print(f"F({i}) = {fibonacci_iterative(i)}")
