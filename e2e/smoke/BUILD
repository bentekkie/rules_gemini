"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""

load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@rules_gemini//src:defs.bzl", "gemini_tool", "gemini_tool_arg", "generate_content")
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

py_binary(
    name = "add_py",
    srcs = ["add.py"],
    main = "add.py",
)

gemini_tool_arg(
    name = "add_arg",
    description = "number to add",
    type = "NUMBER",
)

gemini_tool(
    name = "add",
    description = "Adds two numbers together and returns the result",
    parameters = {
        "first": ":add_arg",
        "second": ":add_arg",
    },
    tool = ":add_py",
)

write_file(
    name = "add_prompt",
    out = "add_prompt.txt",
    content = ["Solve the addition in the provided file"],
)

write_file(
    name = "addition",
    out = "addition.txt",
    content = ["7+3"],
)

generate_content(
    name = "add_gen",
    srcs = ["addition.txt"],
    out = "add_gen.txt",
    prompt = "add_prompt.txt",
    tools = {
        "add": ":add",
    },
)
