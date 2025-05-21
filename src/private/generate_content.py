from google import genai
from google.genai.types import (
    GenerateContentConfig,
    Tool,
    FunctionDeclaration,
    Content,
    Part,
    FunctionResponse,
    UserContent,
    PartUnionDict,
    ContentListUnion,
)
from argparse import ArgumentParser
from json import load, loads
from subprocess import check_output
from typing import NamedTuple, Sequence


class ToolInfo(NamedTuple):
    executable: str
    declaration: FunctionDeclaration


if __name__ == "__main__":
    parser = ArgumentParser()

    parser.add_argument("--model", type=str)
    parser.add_argument("--src_file", type=str, action='append')
    parser.add_argument("--prompt_file", type=str)
    parser.add_argument("--system_prompt_file", type=str)
    parser.add_argument("--output_file", type=str)
    parser.add_argument("--tool_config_file", type=str)
    parser.add_argument("--start_delimiter", type=str)
    parser.add_argument("--end_delimiter", type=str)
    parser.add_argument("--random", type=str)


    args = parser.parse_args()

    with open(args.prompt_file, "rb") as f:
        prompt = f.read()

    if args.system_prompt_file:
        with open(args.system_prompt_file, "r") as f:
            system_prompt = f.read()

    tool_config: dict[str, dict] = {}

    if args.tool_config_file:
        with open(args.tool_config_file, "r") as f:
            tool_config = load(f)

    tools: list[Tool] = []
    for name, info in tool_config.items():
        tools.append(Tool(function_declarations=[info["declaration"]]))

    config = GenerateContentConfig(tools=tools)
    if args.system_prompt_file:
        with open(args.system_prompt_file, "r") as f:
            config.system_instruction = f.read()

    client = genai.Client()

    parts : Sequence[PartUnionDict] = []
    if args.src_file:
        for file in args.src_file:
            parts.append(client.files.upload(file=file))
    parts.append(Part.from_bytes(data=prompt, mime_type="text/plain"))
    contents: ContentListUnion = [UserContent(parts)]
    while True:
        resp = client.models.generate_content(
            model=args.model,
            contents=contents,
            config=config,
        )
        if (
            not resp.candidates
            or not resp.candidates[0]
            or not resp.candidates[0].content
        ):
            exit(1)
        content = resp.candidates[0].content
        contents.append(content)
        if not content.parts:
            exit(1)
        function_responses = []
        text = ""
        for part in content.parts:
            if part.function_call and part.function_call.name in tool_config:
                tool = tool_config[part.function_call.name]
                cmd = [tool["executable"]]
                if part.function_call.args:
                    cmd.extend(f"--{k}={v}" for k, v in part.function_call.args.items())
                output = check_output(cmd)
                response = loads(output)
                if not isinstance(response, dict):
                    response = {"response": response}
                function_responses.append(
                    Part(
                        function_response=FunctionResponse(
                            name=part.function_call.name,
                            id=part.function_call.id,
                            response=response,
                        )
                    )
                )
            elif part.text:
                text += part.text
        if function_responses:
            contents.append(
                Content(
                    role="user",
                    parts=function_responses,
                )
            )
            continue
        break
    with open(args.output_file, "w") as f:
        if args.start_delimiter:
            start = text.find(args.start_delimiter)
            if start != -1:
                text = text[start + len(args.start_delimiter) :]
        if args.end_delimiter:
            end = text.rfind(args.end_delimiter)
            if end != -1:
                text = text[:end]
        f.write(text)
