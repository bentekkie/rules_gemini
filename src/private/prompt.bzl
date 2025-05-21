"""Provided generate_content"""

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
        "description": "Description of the tool",
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
    if not _VALID_TYPES.contains(ctx.attr.type):
        fail("Invalid type")
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
        "type": attr.string(),
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
    return [DefaultInfo(), GeminiToolInfo(
        tool = ctx.attr.tool,
        declaration = {
            "name": ctx.attr.name,
            "description": ctx.attr.description,
            "parameters": {
                "type": "object",
                "properties": {
                    k: v[GeminiToolArgInfo].json
                    for k, v in ctx.attr.args.items()
                },
                "required": list(ctx.attr.args.keys()),
            },
        },
    )]

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
        "args": attr.label_list(
            providers = [GeminiToolArgInfo],
        ),
    },
    executable = False,
    test = False,
)

def _generate_content_implementation(ctx):
    info = ctx.toolchains["//src:toolchain_type"].gemini_model_info
    tools = [ctx.attr.tools[t] for t in ctx.attr.tools]
    args = ctx.actions.args()
    if ctx.attr.start_delimiter:
        args.add("--start_delimiter", ctx.attr.start_delimiter)
    if ctx.attr.end_delimiter:
        args.add("--end_delimiter", ctx.attr.end_delimiter)
    args.add("--output_file", ctx.outputs.out.path)
    args.add("--model", info.model)
    args.add("--prompt_file", ctx.file.prompt.path)
    inputs = []
    inputs.extend(ctx.files.prompt)
    for src in ctx.files.srcs:
        args.add("--src_file", src)
        inputs.append(src)
    if ctx.file.system_prompt:
        args.add("--system_prompt", ctx.file.system_prompt)
        inputs.append(ctx.file.system_prompt)

    if ctx.attr.tools:
        tool_config_file = ctx.actions.declare_file(ctx.attr.name + ".toolconfig.json")
        tool_config = {}
        for t in ctx.attr.tools:
            tool_config[t] = {
                "executable": ctx.attr.tools[t][GeminiToolInfo].tool,
                "declaration": ctx.attr.tools[t][GeminiToolInfo].declaration,
            }
            tools.append(ctx.attr.tools[t][GeminiToolInfo].tool)
        ctx.actions.write_file(tool_config_file, json.dumps(tool_config))
        args.add("--tool_config_file", tool_config_file)
        inputs.append(tool_config_file)

    ctx.actions.run(
        executable = ctx.executable._generate_content_bin,
        arguments = [args],
        inputs = inputs,
        tools = tools,
        outputs = [ctx.outputs.out],
        env = {
            "GOOGLE_API_KEY": info.api_key,
        },
        execution_requirements = {
            "no-cache": "1",
            "requires-network": "1",
        },
    )

    return [DefaultInfo(
    )]

generate_content = rule(
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
        ),
        "start_delimiter": attr.string(),
        "end_delimiter": attr.string(),
        "out": attr.output(),
        "_generate_content_bin": attr.label(
            default = Label("//src/private:generate_content"),
            executable = True,
            allow_files = True,
            cfg = "exec",
        ),
    },
    executable = False,
    test = False,
    toolchains = ["//src:toolchain_type"],
)
