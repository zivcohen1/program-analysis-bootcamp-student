/**
 * Test suite for calculator module.
 *
 * Run with: node test-calculator.js
 *
 * These tests exercise the calculator and expose RUNTIME bugs
 * that static analysis may not catch.
 */

const calc = require("./calculator");

let passed = 0;
let failed = 0;

function test(name, fn) {
    try {
        fn();
        console.log(`  PASS: ${name}`);
        passed++;
    } catch (e) {
        console.log(`  FAIL: ${name}`);
        console.log(`        ${e.message}`);
        failed++;
    }
}

function assertEqual(actual, expected, msg) {
    if (actual !== expected) {
        throw new Error(
            `${msg || "Assertion failed"}: expected ${expected}, got ${actual}`
        );
    }
}

console.log("\n=== Calculator Test Suite ===\n");

// --- Addition Tests ---
console.log("Addition:");
test("add(2, 3) should be 5", () => {
    assertEqual(calc.add(2, 3), 5, "add(2, 3)");
});

test("add(-1, 1) should be 0", () => {
    assertEqual(calc.add(-1, 1), 0, "add(-1, 1)");
});

// --- Subtraction Tests ---
console.log("\nSubtraction:");
test("subtract(5, 3) should be 2", () => {
    assertEqual(calc.subtract(5, 3), 2, "subtract(5, 3)");
});

// --- Multiplication Tests ---
console.log("\nMultiplication:");
test("multiply(4, 5) should be 20", () => {
    assertEqual(calc.multiply(4, 5), 20, "multiply(4, 5)");
});

test("multiply(0, 5) should be 0", () => {
    assertEqual(calc.multiply(0, 5), 0, "multiply(0, 5)");
});

// Bug 6 exposed: type coercion with == instead of ===
test("multiply('3', 4) should be 12", () => {
    assertEqual(calc.multiply("3", 4), 12, "multiply('3', 4)");
});

// --- Division Tests ---
console.log("\nDivision:");
test("divide(10, 2) should be 5", () => {
    assertEqual(calc.divide(10, 2), 5, "divide(10, 2)");
});

// Bug 4 exposed: division by zero
test("divide(10, 0) should throw or return Infinity gracefully", () => {
    const result = calc.divide(10, 0);
    if (!isFinite(result)) {
        throw new Error(
            "Division by zero should be handled, got " + result
        );
    }
});

// --- Calculate (dispatcher) Tests ---
console.log("\nCalculate:");
// Bug 3 exposed: switch fallthrough -- add operation falls through to subtract
test("calculate('add', 10, 5) should be 15", () => {
    assertEqual(calc.calculate("add", 10, 5), 15, "calculate('add', 10, 5)");
});

test("calculate('multiply', 3, 4) should be 12", () => {
    assertEqual(
        calc.calculate("multiply", 3, 4),
        12,
        "calculate('multiply', 3, 4)"
    );
});

// --- Factorial Tests ---
console.log("\nFactorial:");
test("factorial(5) should be 120", () => {
    assertEqual(calc.factorial(5), 120, "factorial(5)");
});

test("factorial(0) should be 1", () => {
    assertEqual(calc.factorial(0), 1, "factorial(0)");
});

// Bug 5 exposed: infinite recursion with negative input
test("factorial(-1) should handle negative input", () => {
    try {
        calc.factorial(-1);
        throw new Error("Should have thrown for negative input");
    } catch (e) {
        if (e.message.includes("Maximum call stack")) {
            throw new Error(
                "Infinite recursion detected -- needs base case for negative numbers"
            );
        }
    }
});

// --- Power Tests ---
console.log("\nPower:");
test("power(2, 3) should be 8", () => {
    assertEqual(calc.power(2, 3), 8, "power(2, 3)");
});

// --- Absolute Value Tests ---
console.log("\nAbsolute Value:");
test("absolute(5) should be 5", () => {
    assertEqual(calc.absolute(5), 5, "absolute(5)");
});

// Bug 8 exposed: constant condition always negates
test("absolute(-3) should be 3", () => {
    assertEqual(calc.absolute(-3), 3, "absolute(-3)");
});

// --- Summary ---
console.log(`\n=== Results: ${passed} passed, ${failed} failed ===\n`);

if (failed > 0) {
    console.log(
        "Some tests failed! Use these failures to identify runtime bugs."
    );
    console.log(
        "Compare with ESLint findings to see which bugs each approach catches.\n"
    );
}
