"""String utility functions."""


def is_palindrome(s):
    """Check if a string is a palindrome (ignoring case and spaces)."""
    cleaned = "".join(c.lower() for c in s if c.isalnum())
    return cleaned == cleaned[::-1]


def longest_common_substring(s1, s2):
    """Find the longest common substring between two strings."""
    if not s1 or not s2:
        return ""
    m, n = len(s1), len(s2)
    dp = [[0] * (n + 1) for _ in range(m + 1)]
    max_len = 0
    end_idx = 0
    for i in range(1, m + 1):
        for j in range(1, n + 1):
            if s1[i - 1] == s2[j - 1]:
                dp[i][j] = dp[i - 1][j - 1] + 1
                if dp[i][j] > max_len:
                    max_len = dp[i][j]
                    end_idx = i
    return s1[end_idx - max_len:end_idx]


def count_words(text):
    """Count word frequencies in text."""
    words = text.lower().split()
    freq = {}
    for word in words:
        cleaned = "".join(c for c in word if c.isalnum())
        if cleaned:
            freq[cleaned] = freq.get(cleaned, 0) + 1
    return freq


def caesar_cipher(text, shift):
    """Apply Caesar cipher with the given shift."""
    result = []
    for char in text:
        if char.isalpha():
            base = ord("A") if char.isupper() else ord("a")
            shifted = (ord(char) - base + shift) % 26 + base
            result.append(chr(shifted))
        else:
            result.append(char)
    return "".join(result)


def run_length_encode(s):
    """Run-length encode a string."""
    if not s:
        return ""
    result = []
    count = 1
    for i in range(1, len(s)):
        if s[i] == s[i - 1]:
            count += 1
        else:
            result.append(f"{s[i-1]}{count}" if count > 1 else s[i - 1])
            count = 1
    result.append(f"{s[-1]}{count}" if count > 1 else s[-1])
    return "".join(result)


if __name__ == "__main__":
    print(f"'racecar' palindrome: {is_palindrome('racecar')}")
    print(f"LCS('abcdef', 'zbcdf'): '{longest_common_substring('abcdef', 'zbcdf')}'")
    print(f"Caesar('Hello', 3): '{caesar_cipher('Hello', 3)}'")
