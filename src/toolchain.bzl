"""This module implements the language-specific toolchain rule.
"""

GeminiModelInfo = provider(
    doc = "Information about how to use gemini.",
    fields = {
        "model": "Model",
        "api_key": "API Key",
        "random": "Random",
    },
)

def _gemini_toolchain_impl(ctx):
    default = DefaultInfo()
    gemini_model_info = GeminiModelInfo(
        model = ctx.attr.model,
        api_key = ctx.attr.api_key,
        random = ctx.attr.random,
    )

    # Export all the providers inside our ToolchainInfo
    # so the resolved_toolchain rule can grab and re-export them.
    toolchain_info = platform_common.ToolchainInfo(
        gemini_model_info = gemini_model_info,
        default = default,
    )
    return [
        default,
        toolchain_info,
    ]

gemini_toolchain = rule(
    implementation = _gemini_toolchain_impl,
    attrs = {
        "model": attr.string(
            doc = "Model",
            mandatory = False,
        ),
        "api_key": attr.string(
            doc = "API Key",
            mandatory = False,
        ),
        "random": attr.string(),
    },
    doc = """Defines a gemini model""",
)
