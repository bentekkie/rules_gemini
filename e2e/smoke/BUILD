"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""

load("@aspect_rules_py//py:defs.bzl", "py_binary")
load("@rules_gemini//src:defs.bzl", "generate_content")

# Replace with a usage of your rule/macro
generate_content(
    name = "test",
    out = "dog.py",
    end_delimiter = "```",
    prompt = "prompt.txt",
    start_delimiter = "```python",
)

py_binary(
    name = "dog",
    srcs = ["dog.py"],
)
