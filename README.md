# Rules Gemini

Ready to get started? Copy this repo, then

# Bazel rules for gemini

Didnt stop to ask if it is needed, just wanted to see if it is possible.

Have you ever wanted your bazel build to be as not hermetic and non deterministic as possible?

Now you can call the generate_content Gemini api as a build rule

Features:

- [x] Basic prompting
- [x] Use bazel target as a tool
- [x] Specify args for bazel tool target
- [x] Add files to context
- [ ] Add system prompt (untested)
