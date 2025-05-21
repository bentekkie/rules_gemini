<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public API re-exports

<a id="gemini_tool"></a>

## gemini_tool

<pre>
load("@rules_gemini//src:defs.bzl", "gemini_tool")

gemini_tool(<a href="#gemini_tool-name">name</a>, <a href="#gemini_tool-description">description</a>, <a href="#gemini_tool-parameters">parameters</a>, <a href="#gemini_tool-tool">tool</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="gemini_tool-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="gemini_tool-description"></a>description |  -   | String | optional |  `""`  |
| <a id="gemini_tool-parameters"></a>parameters |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="gemini_tool-tool"></a>tool |  input source files   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


<a id="gemini_tool_arg"></a>

## gemini_tool_arg

<pre>
load("@rules_gemini//src:defs.bzl", "gemini_tool_arg")

gemini_tool_arg(<a href="#gemini_tool_arg-name">name</a>, <a href="#gemini_tool_arg-description">description</a>, <a href="#gemini_tool_arg-items">items</a>, <a href="#gemini_tool_arg-nullable">nullable</a>, <a href="#gemini_tool_arg-properties">properties</a>, <a href="#gemini_tool_arg-required">required</a>, <a href="#gemini_tool_arg-type">type</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="gemini_tool_arg-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="gemini_tool_arg-description"></a>description |  -   | String | optional |  `""`  |
| <a id="gemini_tool_arg-items"></a>items |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="gemini_tool_arg-nullable"></a>nullable |  -   | Boolean | optional |  `False`  |
| <a id="gemini_tool_arg-properties"></a>properties |  -   | Dictionary: String -> Label | optional |  `{}`  |
| <a id="gemini_tool_arg-required"></a>required |  -   | List of strings | optional |  `[]`  |
| <a id="gemini_tool_arg-type"></a>type |  -   | String | optional |  `""`  |


<a id="generate_content"></a>

## generate_content

<pre>
load("@rules_gemini//src:defs.bzl", "generate_content")

generate_content(<a href="#generate_content-name">name</a>, <a href="#generate_content-srcs">srcs</a>, <a href="#generate_content-out">out</a>, <a href="#generate_content-end_delimiter">end_delimiter</a>, <a href="#generate_content-prompt">prompt</a>, <a href="#generate_content-start_delimiter">start_delimiter</a>, <a href="#generate_content-system_prompt">system_prompt</a>, <a href="#generate_content-tools">tools</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="generate_content-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="generate_content-srcs"></a>srcs |  input source files   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="generate_content-out"></a>out |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="generate_content-end_delimiter"></a>end_delimiter |  -   | String | optional |  `""`  |
| <a id="generate_content-prompt"></a>prompt |  input source files   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="generate_content-start_delimiter"></a>start_delimiter |  -   | String | optional |  `""`  |
| <a id="generate_content-system_prompt"></a>system_prompt |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="generate_content-tools"></a>tools |  -   | Dictionary: String -> Label | optional |  `{}`  |


