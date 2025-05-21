"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""

load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@rules_gemini//src:defs.bzl", "gemini_tool", "generate_content")
load("@rules_python//python:py_binary.bzl", "py_binary")

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

py_binary(
    name = "cores_py",
    srcs = ["cores.py"],
    main = "cores.py",
)

gemini_tool(
    name = "get_cores",
    description = "Returns the number of processing cores available on the local computer",
    tool = ":cores_py",
)

write_file(
    name = "core_prompt",
    out = "core_prompt.txt",
    content = ["How many cores on on my machine?"],
)

generate_content(
    name = "core_gen",
    out = "core_gen.txt",
    prompt = "core_prompt.txt",
    tools = {
        "get_cores": ":get_cores",
    },
)
