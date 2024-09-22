#!/usr/bin/env python3
#
# Convert Alfred snippets to Raycast format for: https://www.raycast.com/astronight/snippetsurfer
#
# Author: Werner Robitza <werner.robitza@gmail.com>
# License: MIT

import argparse
import json
import os
from pathlib import Path

import yaml


def process_folder(folder_path):
    snippets = []
    for file in os.listdir(folder_path):
        if file.endswith(".json"):
            with open(os.path.join(folder_path, file), "r") as f:
                try:
                    data = json.load(f)
                    snippet = data["alfredsnippet"]
                    new_snippet = {
                        "title": snippet["name"],
                        "content": snippet["snippet"],
                    }
                    if "keyword" in snippet and snippet["keyword"]:
                        # this is not supported yet but may be in the future
                        new_snippet["keyword"] = snippet["keyword"]
                    snippets.append(new_snippet)
                except json.JSONDecodeError:
                    print(f"Error decoding JSON in file: {file}")
                except KeyError:
                    print(f"Missing expected keys in file: {file}")

    return snippets


def write_yaml(snippets, output_file):
    with open(output_file, "w") as f:
        yaml.dump({"snippets": snippets}, f, default_flow_style=False, sort_keys=False)


def main():
    parser = argparse.ArgumentParser(
        description="Convert Alfred snippets to Raycast format"
    )
    parser.add_argument(
        "-i",
        "--input_folder",
        type=str,
        help="Input folder to search for Alfred snippets",
        default="~/Library/CloudStorage/Dropbox/Alfred/Alfred.alfredpreferences/snippets",
    )
    parser.add_argument(
        "-o",
        "--output_folder",
        type=str,
        help="Output folder to save Raycast snippets",
        default="~/Desktop",
    )
    args = parser.parse_args()

    input_folder = Path(args.input_folder).expanduser()
    output_folder = Path(args.output_folder).expanduser()

    for folder in os.listdir(input_folder):
        folder_path = input_folder / folder
        if os.path.isdir(folder_path):
            snippets = process_folder(folder_path)
            if snippets:
                output_file = output_folder / f"{folder}.yaml"
                write_yaml(snippets, output_file)
                print(f"Created {output_file}")


if __name__ == "__main__":
    main()
