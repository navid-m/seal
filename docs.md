# Seal Programming Language Documentation

## Table of Contents
- [Basic Syntax](#basic-syntax)
- [Operators Reference](#operators-reference)
- [Control Flow](#control-flow)
- [Input/Output](#inputoutput)
- [Built-in Functions](#built-in-functions)
- [Examples](#examples)

---

## Basic Syntax

### Variables
- Variables can store integers or strings
- No declaration needed, just assign: `x=5;` or `name="Alice";`
- Variables default to 0 if not initialized
- String concatenation with `+`: `greeting="Hello, "+name;`

### Statements
- Statements end with `;` or newline
- Multiple statements can be on one line

---

## Operators Reference

### Arithmetic Operators

| Operator | Description | Example | Result |
|----------|-------------|---------|--------|
| `+` | Addition | `5+3` | `8` |
| `-` | Subtraction | `5-3` | `2` |
| `*` | Multiplication | `5*3` | `15` |
| `/` | Integer Division | `7/2` | `3` |
| `~` | Modulo | `7~3` | `1` |

### Comparison Operators

| Operator | Description | Example | Result |
|----------|-------------|---------|--------|
| `==` or `|` | Equal to | `5==5` or `5|5` | `1` (true) |
| `!=` | Not equal to | `5!=3` | `1` (true) |
| `<` | Less than | `3<5` | `1` (true) |
| `>` | Greater than | `5>3` | `1` (true) |
| `<=` | Less than or equal | `3<=3` | `1` (true) |
| `>=` | Greater than or equal | `5>=3` | `1` (true) |

**Note:** Comparison operators return `1` for true, `0` for false.

### Unary Operators

| Operator | Description | Example | Result |
|----------|-------------|---------|--------|
| `!` | Logical NOT (negation) | `!0` | `1` (true) |
| `!` | Logical NOT | `!5` | `0` (false) |

**Note:** `!` returns `1` if operand is `0`, otherwise returns `0`.

### Ternary Operator

| Operator | Description | Example | Result |
|----------|-------------|---------|--------|
| `?:` | Conditional expression | `5>3?1:0` | `1` |
| `?:` | Nested ternary | `x|0?"yes":"no"` | `"yes"` or `"no"` |

**Syntax:** `condition ? valueIfTrue : valueIfFalse`

The ternary operator evaluates the condition. If non-zero (true), it returns the first value; otherwise, it returns the second value.

**Examples:**
```seal
£5>3?10:20;        // Prints: 10
£2>5?10:20;        // Prints: 20
x=5;
£x|5?"equal":"not equal";  // Prints: equal
```

**Nested ternaries:**
```seal
£x>10?"big":x>5?"medium":"small";
```

### Assignment Operators

| Operator | Description | Example | Equivalent |
|----------|-------------|---------|------------|
| `=` | Assignment | `x=5` | - |
| `+=` | Add and assign | `x+=3` | `x=x+3` |
| `-=` | Subtract and assign | `x-=3` | `x=x-3` |
| `*=` | Multiply and assign | `x*=3` | `x=x*3` |
| `/=` | Divide and assign | `x/=3` | `x=x/3` |

### Increment/Decrement Operators

| Operator | Description | Example | Equivalent |
|----------|-------------|---------|------------|
| `¬` | Increment (postfix) | `x¬` | `x=x+1` |
| `++` | Increment (postfix) | `x++` | `x=x+1` |
| `--` | Decrement (postfix) | `x--` | `x=x-1` |

**Note:** `¬` is the shorter alternative to `++` for code golf.

**Code Golf Tips:**
- Use `` ` `` (backtick) instead of `£` for printing - it's 1 byte shorter
- Use `¬` instead of `++` for incrementing

---

## Control Flow

### While Loops

**Syntax:** `@(condition){statements}`

Loops while the condition is non-zero (truthy).

**Examples:**
```seal
@(i<10){
    £i;
    i¬;
}
```

```seal
x=5;
@(x){
    %x;
    x--;
}
```

**Note:** Any non-zero value is considered true. Zero is false.

### Repeat Loops

**Syntax:** `rN{statements}` or `r<expression>{statements}`

Repeats the block exactly N times. Inside the loop, `_` contains the current iteration number (1-indexed).

**Examples:**
```seal
r5{"Hello";}      // Prints "Hello" 5 times
```

```seal
r10{£_;}          // Prints 1 2 3 4 5 6 7 8 9 10
```

```seal
n=3;
r n*2{£_;}        // Repeats n*2 times, _ goes from 1 to n*2
```

**Note:** 
- The count is evaluated once before the loop starts
- `_` starts at 1 and increments to N
- `_` is a regular variable that can be read or modified

### Thread Spawning

**Syntax:** `t{statements}`

Spawns a new thread to execute the statements concurrently.

**Examples:**
```seal
t{:\"A\";s(1);:\"B\";}t{:\"C\";s(2);:\"D\";}"";
// Spawns two threads that run concurrently
```

**Note:** Threads execute asynchronously. Use `s(n)` to control timing.

---

## Input/Output

### Output Instructions

| Instruction | Description | Example | Output |
|-------------|-------------|---------|--------|
| `"text"` | Print string with newline | `"Hello";` | `Hello\n` |
| `%var` | Print variable(s) with newline | `%x,y;` | `5\n10\n` |
| `` `expr`` or `£expr` | Print expression with newline | `` `x+5;`` or `£x+5;` | `10\n` |
| `:expr` | Print without newline | `:"Hi";` | `Hi` |

**Examples:**
```seal
"Hello, world";           // Prints: Hello, world

x=42;
%x;                       // Prints: 42

£5+3;                     // Prints: 8

:"Hello";
:"World";
"";                       // Prints: HelloWorld
```

### Input Instructions

| Instruction | Description | Example |
|-------------|-------------|---------|
| `$` | Read integer from stdin | `x=$;` |
| `$"prompt"` | Read integer with prompt | `n=$"Enter: ";` |
| `\` | Read string from stdin | `name=\;` |
| `\"prompt"` | Read string with prompt | `name=\"Enter name: ";` |

**Examples:**
```seal
x=$;                      // Read number into x
y=$"Enter a number: ";    // Prompt and read
name=\;                    // Read string into name
name=\"Enter name: ";        // Prompt and read string
```
---

## Built-in Functions

### Function Call Syntax

**Syntax:** `£functionName(args)`

### Available Functions

| Function | Description | Example | Returns |
|----------|-------------|---------|---------|
| `p(n)` | Check if n is prime | `£p(7);` | `1` (true) or `0` (false) |
| `s(n)` | Sleep for n seconds | `s(2);` | `0` |

**Example:**
```seal
n=$"Enter number: ";
@(£p(n)){
    "Prime!";
}
```

---

## Examples

### Hello World
```seal
"Hello, world";
```

### Count to 10
```seal
i=1;
@(i<=10){
    %i;
    i¬;
}
```

### FizzBuzz (1-100)

**With repeat loop (51 bytes):**
```seal
r100{£!_~15?"FizzBuzz":!_~3?"Fizz":!_~5?"Buzz":_;}
```

**With negation operator (59 bytes):**
```seal
i=1;@(i<101){£!i~15?"FizzBuzz":!i~3?"Fizz":!i~5?"Buzz":i;i¬;}
```

**With ternary operator (65 bytes):**
```seal
i=1;@(i<101){£i~15|0?"FizzBuzz":i~3|0?"Fizz":i~5|0?"Buzz":i;i¬;}
```

**Without ternary operator:**
```seal
i=1;
@(i<101){
    a=i~3;
    b=i~5;
    f=0;
    @(a|0){
        :"Fizz";
        f=1;
    };
    @(b|0){
        :"Buzz";
        f=1;
    };
    @(f|0){
        £i;
        "";
    };
    i¬;
}
```

### Prime Checker
```seal
n=$"Enter a number: ";
@(£p(n)){
    "Prime!";
}
@(£p(n)==0){
    "Not prime";
}
```

### Sum of Last 3 Odd Numbers (CodeGolf Problem)
```seal
n=$;
@(n){
    n¬;
    s=n*n*3/2-9;
    £s;
    n=$;
}
```

### Calculator
```seal
a=$"First number: ";
b=$"Second number: ";
:"Sum: ";
£a+b;
:"Product: ";
£a*b;
```

---

## Operator Precedence

From highest to lowest:

1. **Parentheses:** `()`
2. **Multiplicative:** `*`, `/`, `~`
3. **Additive:** `+`, `-`
4. **Unary:** `!`
5. **Comparison:** `<`, `>`, `<=`, `>=`, `==`, `!=`
6. **Ternary:** `?:`

---

## Tips for Code Golf

1. Use `¬` instead of `++` (saves 1 byte)
2. Use `|` instead of `==` (saves 1 byte)
3. Use `!` instead of `|0` for zero checks (saves 1 byte)
4. Use ternary `?:` for conditional logic instead of loops
5. Use `:` for printing without newlines
6. Omit semicolons where newlines work
7. Use `@(condition)` for truthiness checks
8. Comparison operators return 1/0, use them directly

**Before:**
```seal
if (x == 0) {
    print(y);
}
```

**After:**
```seal
@(x==0)£y
```

---

## Language Quirks

1. **No strings in variables:** Strings can only be printed directly
2. **Integer-only:** All variables are integers
3. **Truthiness:** 0 is false, everything else is true
4. **No else:** Use separate `@()` blocks for if/else logic
5. **Print always adds newline** (except `:`)

---

## File Extension

Seal programs use the `.sl` extension.

---

## Running Programs

```bash
seal programName # Runs programName.sl
```

---

## Version

Seal v2.1.0

---

## License

GPL-3.0 - Navid M (C) 2025
