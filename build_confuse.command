#!/bin/zsh
set -euo pipefail

project_path_confuse="$(cd "$(dirname "$0")" && pwd)"
exec "$project_path_confuse/build_app_confuse.sh"
