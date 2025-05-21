"Public API re-exports"

load(
    "//src/private:prompt.bzl",
    _gemini_tool = "gemini_tool",
    _gemini_tool_arg = "gemini_tool_arg",
    _generate_content = "generate_content",
)

generate_content = _generate_content
gemini_tool_arg = _gemini_tool_arg
gemini_tool = _gemini_tool
