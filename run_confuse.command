#!/bin/zsh
set -euo pipefail

project_path_confuse="$(cd "$(dirname "$0")" && pwd)"
cd "$project_path_confuse"
exec swift run -c debug
