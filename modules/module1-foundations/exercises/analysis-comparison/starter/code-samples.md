# Code Samples for Analysis Classification

Review each code snippet below. For each one, identify:
1. **Issue type** (what's wrong or risky)
2. **Objective** (Correctness / Security / Performance)
3. **Detection method** (Static / Dynamic / Both)

Record your answers in `classification-template.md`.

---

## Snippet 1: Python
```python
def get_user(user_id):
    query = "SELECT * FROM users WHERE id = " + user_id
    return db.execute(query)
```

## Snippet 2: JavaScript
```javascript
function greet(name) {
    return "Hello, " + name;
    console.log("Greeting sent");
}
```

## Snippet 3: Python
```python
def average(numbers):
    total = sum(numbers)
    return total / len(numbers)
```

## Snippet 4: C
```c
void copy_string(char *dest, const char *src) {
    while (*src) {
        *dest++ = *src++;
    }
}
```

## Snippet 5: JavaScript
```javascript
function processItems(items) {
    for (let i = 0; i <= items.length; i++) {
        console.log(items[i].name);
    }
}
```

## Snippet 6: Python
```python
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)
```

## Snippet 7: Java
```java
public String readFile(String filename) {
    FileInputStream fis = new FileInputStream(filename);
    // ... read contents ...
    return contents;
    // fis is never closed
}
```

## Snippet 8: Python
```python
import os
def delete_file(user_input):
    os.system("rm " + user_input)
```

## Snippet 9: JavaScript
```javascript
let cache = {};
function getData(key) {
    if (!cache[key]) {
        cache[key] = expensiveLookup(key);
    }
    return cache[key];
}
// cache is never cleared -- grows indefinitely
```

## Snippet 10: Python
```python
def process(data):
    result = []
    for item in data:
        if item > 0:
            result.append(item)
    return result
    result.clear()
```

## Snippet 11: Java
```java
public void transfer(Account from, Account to, double amount) {
    from.withdraw(amount);
    // What if this line throws an exception?
    to.deposit(amount);
}
```

## Snippet 12: Python
```python
def search(items, target):
    for i in range(len(items)):
        for j in range(len(items)):
            if items[i] == target:
                return i
    return -1
```

## Snippet 13: JavaScript
```javascript
document.getElementById("output").innerHTML = userInput;
```

## Snippet 14: Python
```python
def divide_all(numbers, divisor):
    results = []
    for n in numbers:
        results.append(n / divisor)
    return results
```

## Snippet 15: C
```c
int* create_array() {
    int arr[10] = {0};
    return arr;  // returning pointer to local variable
}
```
