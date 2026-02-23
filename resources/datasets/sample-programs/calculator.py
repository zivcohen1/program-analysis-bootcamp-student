"""Simple calculator with expression parsing."""

import operator


OPERATORS = {
    "+": operator.add,
    "-": operator.sub,
    "*": operator.mul,
    "/": operator.truediv,
}


def tokenize(expression):
    """Split an expression string into tokens."""
    tokens = []
    current = ""
    for char in expression:
        if char in "+-*/()":
            if current:
                tokens.append(current.strip())
                current = ""
            tokens.append(char)
        elif char.isspace():
            if current:
                tokens.append(current.strip())
                current = ""
        else:
            current += char
    if current:
        tokens.append(current.strip())
    return tokens


def evaluate_simple(expression):
    """Evaluate a simple binary expression (no precedence)."""
    tokens = tokenize(expression)
    if len(tokens) != 3:
        raise ValueError(f"Expected 'a op b', got {len(tokens)} tokens")
    left = float(tokens[0])
    op = tokens[1]
    right = float(tokens[2])
    if op not in OPERATORS:
        raise ValueError(f"Unknown operator: {op}")
    if op == "/" and right == 0:
        raise ZeroDivisionError("Division by zero")
    return OPERATORS[op](left, right)


def evaluate_rpn(tokens):
    """Evaluate a list of tokens in Reverse Polish Notation."""
    stack = []
    for token in tokens:
        if token in OPERATORS:
            if len(stack) < 2:
                raise ValueError("Insufficient operands")
            b = stack.pop()
            a = stack.pop()
            if token == "/" and b == 0:
                raise ZeroDivisionError("Division by zero")
            stack.append(OPERATORS[token](a, b))
        else:
            stack.append(float(token))
    if len(stack) != 1:
        raise ValueError("Invalid expression")
    return stack[0]


if __name__ == "__main__":
    print(f"3 + 4 = {evaluate_simple('3 + 4')}")
    print(f"RPN '3 4 + 2 *' = {evaluate_rpn(['3', '4', '+', '2', '*'])}")
