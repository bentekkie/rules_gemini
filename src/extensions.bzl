"""Extensions for bzlmod.

Installs a gemini toolchain."""

load(":repositories.bzl", "gemini_register_toolchains")

_DEFAULT_NAME = "gemini"

gemini_toolchain = tag_class(attrs = {
    "name": attr.string(doc = """\
Base name for generated repositories, allowing more than one gemini toolchain to be registered.
Overriding the default is only permitted in the root module.
""", default = _DEFAULT_NAME),
    "model": attr.string(doc = "model string", mandatory = True),
})

def _toolchain_extension(module_ctx):
    registrations = {}
    for mod in module_ctx.modules:
        for toolchain in mod.tags.toolchain:
            if toolchain.name != _DEFAULT_NAME and not mod.is_root:
                fail("""\
                Only the root module may override the default name for the gemini toolchain.
                This prevents conflicting registrations in the global namespace of external repos.
                """)
            if toolchain.name not in registrations.keys():
                registrations[toolchain.name] = []
            registrations[toolchain.name].append(toolchain.model)
    for name, versions in registrations.items():
        versions = {v: 1 for v in versions}.keys()
        if len(versions) > 1:
            # TODO: should be semver-aware, using MVS
            selected = sorted(versions, reverse = True)[0]

            # buildifier: disable=print
            print("NOTE: gemini toolchain {} has multiple versions {}, selected {}".format(name, versions, selected))
        else:
            selected = versions[0]

        gemini_register_toolchains(
            name = name,
            model = selected,
            register = False,
        )

gemini = module_extension(
    implementation = _toolchain_extension,
    tag_classes = {"toolchain": gemini_toolchain},
)
