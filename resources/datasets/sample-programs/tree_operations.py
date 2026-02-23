"""Binary tree operations."""


class TreeNode:
    def __init__(self, val, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right


def insert_bst(root, val):
    """Insert a value into a BST."""
    if root is None:
        return TreeNode(val)
    if val < root.val:
        root.left = insert_bst(root.left, val)
    elif val > root.val:
        root.right = insert_bst(root.right, val)
    return root


def search_bst(root, val):
    """Search for a value in a BST."""
    if root is None:
        return False
    if val == root.val:
        return True
    if val < root.val:
        return search_bst(root.left, val)
    return search_bst(root.right, val)


def inorder(root):
    """In-order traversal (sorted order for BST)."""
    if root is None:
        return []
    return inorder(root.left) + [root.val] + inorder(root.right)


def preorder(root):
    """Pre-order traversal."""
    if root is None:
        return []
    return [root.val] + preorder(root.left) + preorder(root.right)


def postorder(root):
    """Post-order traversal."""
    if root is None:
        return []
    return postorder(root.left) + postorder(root.right) + [root.val]


def height(root):
    """Compute the height of the tree."""
    if root is None:
        return -1
    return 1 + max(height(root.left), height(root.right))


def is_balanced(root):
    """Check if the tree is height-balanced."""
    if root is None:
        return True
    left_h = height(root.left)
    right_h = height(root.right)
    if abs(left_h - right_h) > 1:
        return False
    return is_balanced(root.left) and is_balanced(root.right)


def level_order(root):
    """Level-order (BFS) traversal."""
    if root is None:
        return []
    from collections import deque
    queue = deque([root])
    result = []
    while queue:
        node = queue.popleft()
        result.append(node.val)
        if node.left:
            queue.append(node.left)
        if node.right:
            queue.append(node.right)
    return result


if __name__ == "__main__":
    root = None
    for val in [5, 3, 7, 1, 4, 6, 8]:
        root = insert_bst(root, val)
    print(f"In-order:    {inorder(root)}")
    print(f"Pre-order:   {preorder(root)}")
    print(f"Level-order: {level_order(root)}")
    print(f"Height: {height(root)}, Balanced: {is_balanced(root)}")
