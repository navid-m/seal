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
- Variables are dynamically typed (integers only currently)
- No declaration needed, just assign: `x=5;`
- Variables default to 0 if not initialized

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

---

## Input/Output

### Output Instructions

| Instruction | Description | Example | Output |
|-------------|-------------|---------|--------|
| `"text"` | Print string with newline | `"Hello";` | `Hello\n` |
| `%var` | Print variable(s) with newline | `%x,y;` | `5\n10\n` |
| `£expr` | Print expression with newline | `£x+5;` | `10\n` |
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
| `$"prompt"` | Read with prompt | `n=$"Enter: ";` |

**Examples:**
```seal
x=$;                      // Read number into x
y=$"Enter a number: ";    // Prompt and read
```

---

## Built-in Functions

### Function Call Syntax

**Syntax:** `£functionName(args)`

### Available Functions

| Function | Description | Example | Output |
|----------|-------------|---------|--------|
| `p(n)` | Check if n is prime | `£p(7);` | `1` (true) |
| `p(n)` | Check if n is prime | `£p(4);` | `0` (false) |

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
```seal
i=1;
@(i<101){
    a=i~3;
    b=i~5;
    f=0;
    @(a==0){
        :"Fizz";
        f=1;
    };
    @(b==0){
        :"Buzz";
        f=1;
    };
    @(f==0){
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
4. **Comparison:** `<`, `>`, `<=`, `>=`, `==`, `!=`

---

## Tips for Code Golf

1. Use `¬` instead of `++` (saves 1 byte)
2. Use `|` instead of `==` (saves 1 byte)
3. Use `:` for printing without newlines
4. Omit semicolons where newlines work
5. Use `@(condition)` for truthiness checks
6. Comparison operators return 1/0, use them directly
7. Variables default to 0, no need to initialize

### Byte-Saving Examples

**Before:**
```seal
x = x + 1;
```

**After:**
```seal
x¬
```

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
