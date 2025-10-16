# Bash Scripting Style Guide for Agent OS

## Quote Escaping Rules

### Single Quotes
- Everything inside is literal
- **Cannot escape single quotes inside single quotes**
- Use for fixed strings without variables

```bash
# ✓ Good
echo 'Hello, World!'
grep -q 'gem.*rails' Gemfile

# ✗ Bad - cannot escape single quote inside single quotes
echo 'It\'s wrong'  # Ends string at first '
```

### Double Quotes
- Variables expand: `$var` becomes value
- Can escape quotes with backslash: `\"`
- Use when you need variable interpolation

```bash
# ✓ Good
echo "Hello, $name!"
grep -q "gem [\"']rails[\"']" Gemfile

# ✗ Bad - unescaped quotes
echo "She said "hello""  # Breaks parsing
```

### Character Classes in Quotes
When matching quote characters in grep patterns:

```bash
# ✓ Good - use double quotes
grep -q "gem [\"']rails[\"']" Gemfile

# ✓ Better - simplify pattern
grep -q "gem.*rails" Gemfile

# ✗ Bad - cannot escape in single quotes
grep -q 'gem ["\']rails["\']' Gemfile
```

## Emoji and Special Characters

### In Functions
✓ Safe - emojis work when sent through terminal output:
```bash
print_warning() {
    print_color "$YELLOW" "⚠️  $1"
}
```

### In Inline Strings
✗ Unsafe - emojis break in C/POSIX locales:
```bash
# ✗ Bad
local msg="⚠️ Warning message"

# ✓ Good
local msg="WARNING: Warning message"
```

**Rule**: Emojis only in terminal output functions, never in inline string variables.

## Validation

Always validate shell scripts before committing:

```bash
# Syntax check
bash -n script.sh

# Lint check
shellcheck script.sh
```

## Common ShellCheck Issues

### SC2086 - Quote variables
```bash
# ✗ Bad
grep $pattern $file

# ✓ Good
grep "$pattern" "$file"
```

### SC2046 - Quote command substitution
```bash
# ✗ Bad
for file in $(find . -name "*.sh"); do

# ✓ Good
find . -name "*.sh" | while read -r file; do
```

### SC2145 - Array expansion
```bash
# ✗ Bad
echo "Items: $@"

# ✓ Good
echo "Items: $*"
```

For more information: https://www.shellcheck.net/wiki/
