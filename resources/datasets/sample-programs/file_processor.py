"""File processing utilities (demonstrates I/O patterns for analysis)."""

import os


def read_lines(filepath):
    """Read a file and return lines as a list."""
    with open(filepath, "r") as f:
        return f.readlines()


def count_lines(filepath):
    """Count total, blank, and code lines in a file."""
    total = 0
    blank = 0
    comment = 0
    with open(filepath, "r") as f:
        for line in f:
            total += 1
            stripped = line.strip()
            if not stripped:
                blank += 1
            elif stripped.startswith("#"):
                comment += 1
    code = total - blank - comment
    return {"total": total, "blank": blank, "comment": comment, "code": code}


def find_files(directory, extension=".py"):
    """Find all files with a given extension in a directory tree."""
    matches = []
    for root, dirs, files in os.walk(directory):
        for fname in sorted(files):
            if fname.endswith(extension):
                matches.append(os.path.join(root, fname))
    return matches


def grep(filepath, pattern):
    """Search for a pattern in a file, return matching lines with numbers."""
    results = []
    with open(filepath, "r") as f:
        for lineno, line in enumerate(f, 1):
            if pattern in line:
                results.append((lineno, line.rstrip()))
    return results


def word_frequency(filepath):
    """Count word frequencies in a text file."""
    freq = {}
    with open(filepath, "r") as f:
        for line in f:
            for word in line.split():
                cleaned = "".join(c.lower() for c in word if c.isalnum())
                if cleaned:
                    freq[cleaned] = freq.get(cleaned, 0) + 1
    return dict(sorted(freq.items(), key=lambda x: x[1], reverse=True))


if __name__ == "__main__":
    this_file = __file__
    stats = count_lines(this_file)
    print(f"Stats for {this_file}:")
    for key, val in stats.items():
        print(f"  {key}: {val}")
