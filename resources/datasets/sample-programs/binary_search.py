"""Binary search implementations."""


def binary_search(arr, target):
    """Search for target in a sorted array. Returns index or -1."""
    low, high = 0, len(arr) - 1
    while low <= high:
        mid = (low + high) // 2
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            low = mid + 1
        else:
            high = mid - 1
    return -1


def binary_search_recursive(arr, target, low=0, high=None):
    """Recursive binary search."""
    if high is None:
        high = len(arr) - 1
    if low > high:
        return -1
    mid = (low + high) // 2
    if arr[mid] == target:
        return mid
    elif arr[mid] < target:
        return binary_search_recursive(arr, target, mid + 1, high)
    else:
        return binary_search_recursive(arr, target, low, mid - 1)


def binary_search_leftmost(arr, target):
    """Find the leftmost occurrence of target."""
    low, high = 0, len(arr)
    while low < high:
        mid = (low + high) // 2
        if arr[mid] < target:
            low = mid + 1
        else:
            high = mid
    if low < len(arr) and arr[low] == target:
        return low
    return -1


if __name__ == "__main__":
    data = [1, 3, 5, 7, 9, 11, 13, 15]
    print(f"Search for 7: index {binary_search(data, 7)}")
    print(f"Search for 4: index {binary_search(data, 4)}")
