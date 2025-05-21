"""Provided generate_content"""

load("@rules_python//python:py_binary.bzl", "py_binary")

GeminiStateInfo = provider(
    doc = "Description of provider GeminiState",
    fields = {
        "chat": "list of objects of the form {'role':..., parts: [...]}",
    },
)

GeminiToolInfo = provider(
    doc = "Description of provider GeminiTool",
    fields = {
        "tool": "Tool label",
        "target": "Target label",
        "declaration": "Declaration of the tool",
    },
)

GeminiToolArgInfo = provider(
    doc = "Description of provider GeminiToolArg",
    fields = {
        "json": "JSON for adding to the api",
    },
)

_VALID_TYPES = [
    "STRING",
    "INTEGER",
    "BOOLEAN",
    "NUMBER",
    "ARRAY",
    "OBJECT",
]

def _gemini_tool_arg_implementation(ctx):
    json = {
        "description": ctx.attr.description,
        "type": ctx.attr.type,
    }
    if ctx.attr.type == "OBJECT" and ctx.attr.required:
        json["required"] = ctx.attr.required
    if ctx.attr.nullable:
        json["nullable"] = True
    if ctx.attr.type == "ARRAY" and ctx.attr.items:
        json["items"] = ctx.attr.items[GeminiToolArgInfo].json
    if ctx.attr.type == "OBJECT" and ctx.attr.properties:
        json["properties"] = {
            k: v[GeminiToolArgInfo].json
            for k, v in ctx.attr.properties.items()
        }
    return [DefaultInfo(), GeminiToolArgInfo(
        json = json,
    )]

gemini_tool_arg = rule(
    implementation = _gemini_tool_arg_implementation,
    attrs = {
        "description": attr.string(),
        "type": attr.string(values = _VALID_TYPES),
        "required": attr.string_list(),
        "nullable": attr.bool(),
        "items": attr.label(
            providers = [GeminiToolArgInfo],
        ),
        "properties": attr.string_keyed_label_dict(
            providers = [GeminiToolArgInfo],
        ),
    },
    executable = False,
    test = False,
)

def _gemini_tool_implementation(ctx):
    declaration = {
        "name": ctx.attr.name,
        "description": ctx.attr.description,
    }
    if ctx.attr.parameters:
        declaration["parameters"] = {
            "type": "object",
            "properties": {
                k: v[GeminiToolArgInfo].json
                for k, v in ctx.attr.parameters.items()
            },
            "required": list(ctx.attr.parameters.keys()),
        }

    runfiles = ctx.runfiles()
    runfiles = runfiles.merge(ctx.attr.tool.default_runfiles)
    ctx.actions.symlink(output = ctx.outputs.executable, target_file = ctx.attr.tool.files_to_run.executable, is_executable = True)

    return [
        DefaultInfo(
            executable = ctx.outputs.executable,
            runfiles = runfiles,
        ),
        GeminiToolInfo(
            target = ctx.attr.tool,
            tool = ctx.attr.tool.files_to_run.executable,
            declaration = declaration,
        ),
    ]

gemini_tool = rule(
    implementation = _gemini_tool_implementation,
    attrs = {
        "tool": attr.label(
            allow_files = True,
            doc = "input source files",
            executable = True,
            cfg = "exec",
        ),
        "description": attr.string(),
        "parameters": attr.string_keyed_label_dict(
            providers = [GeminiToolArgInfo],
        ),
    },
    executable = True,
    test = False,
)

def _generate_content_implementation(ctx):
    info = ctx.toolchains["//src:toolchain_type"].gemini_model_info
    args = ctx.actions.args()
    if ctx.attr.start_delimiter:
        args.add("--start_delimiter", ctx.attr.start_delimiter)
    if ctx.attr.end_delimiter:
        args.add("--end_delimiter", ctx.attr.end_delimiter)
    args.add("--output_file", ctx.outputs.out.path)
    args.add("--model", info.model)
    args.add("--random", info.random)
    args.add("--prompt_file", ctx.file.prompt.path)
    inputs = []
    inputs.extend(ctx.files.prompt)
    for src in ctx.files.srcs:
        args.add("--src_file", src)
        inputs.append(src)
    if ctx.file.system_prompt:
        args.add("--system_prompt", ctx.file.system_prompt)
        inputs.append(ctx.file.system_prompt)

    tools = []
    if ctx.attr.tools:
        tool_config_file = ctx.actions.declare_file(ctx.attr.name + ".toolconfig.json")
        tool_config = {}
        for t in ctx.attr.tools:
            tool_label = ctx.attr.tools[t]
            tool_info = tool_label[GeminiToolInfo]
            tool_config[t] = {
                "executable": tool_label.files_to_run.executable.path,
                "declaration": tool_info.declaration,
            }
            tools.append(tool_label.files_to_run.executable)
            tools.append(tool_label.default_runfiles.files)
        ctx.actions.write(tool_config_file, json.encode(tool_config))
        args.add("--tool_config_file", tool_config_file)
        inputs.append(tool_config_file)

    ctx.actions.run(
        executable = ctx.executable.generate_content_bin,
        arguments = [args],
        inputs = inputs,
        tools = tools + [ctx.executable.generate_content_bin],
        outputs = [ctx.outputs.out],
        mnemonic = "GenerateContent",
        progress_message = "Populating %{output} with ✨...",
        env = {
            "GOOGLE_API_KEY": info.api_key,
        },
        execution_requirements = {
            "no-cache": "1",
            "requires-network": "1",
        },
    )

    return [DefaultInfo()]

_generate_content = rule(
    implementation = _generate_content_implementation,
    attrs = {
        "prompt": attr.label(
            allow_single_file = True,
            doc = "input source files",
        ),
        "system_prompt": attr.label(
            allow_single_file = True,
        ),
        "srcs": attr.label_list(
            allow_files = True,
            doc = "input source files",
        ),
        "tools": attr.string_keyed_label_dict(
            providers = [GeminiToolInfo],
            cfg = "exec",
        ),
        "start_delimiter": attr.string(),
        "end_delimiter": attr.string(),
        "out": attr.output(),
        "generate_content_bin": attr.label(
            default = Label("//src/private:generate_content"),
            executable = True,
            cfg = "exec",
        ),
    },
    executable = False,
    test = False,
    toolchains = ["//src:toolchain_type"],
)

def generate_content(name, tools = None, **kwargs):
    """Wrapper around generate_content

    Args:
        name: name of the target
        tools: dict of tools
        **kwargs: other arguments
    """
    data = []
    if tools:
        data = [t for _, t in tools.items()]

    py_binary(
        name = name + "_generate_content",
        srcs = [Label("//src/private:generate_content.py")],
        main = Label("//src/private:generate_content.py"),
        deps = [
            Label("@pypi//google_genai"),
        ],
        data = data,
    )

    _generate_content(
        name = name,
        generate_content_bin = name + "_generate_content",
        tools = tools,
        **kwargs
    )
