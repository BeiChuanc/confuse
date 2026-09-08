#!/bin/zsh
set -euo pipefail

project_path_confuse="$(cd "$(dirname "$0")" && pwd)"
cd "$project_path_confuse"

swift build -c release
bin_path_confuse="$(swift build -c release --show-bin-path)"
executable_path_confuse="${bin_path_confuse}/ConfuseDesktop_confuse"
resource_bundle_path_confuse="$(find "$bin_path_confuse" -maxdepth 1 -type d -name '*.bundle' -print -quit)"
application_path_confuse="$project_path_confuse/dist/Confuse.app"
mapping_directory_confuse="$project_path_confuse/dist/JSON"
monitoring_directory_confuse="$project_path_confuse/dist/AppMonitorData"

if [[ ! -x "$executable_path_confuse" ]]; then
    echo "未生成 Release 可执行文件。"
    exit 1
fi
if [[ ! -d "$resource_bundle_path_confuse" ]]; then
    echo "未生成资源包。"
    exit 1
fi

rm -rf "$application_path_confuse"
mkdir -p "$application_path_confuse/Contents/MacOS" "$application_path_confuse/Contents/Resources"
mkdir -p "$mapping_directory_confuse"
mkdir -p "$monitoring_directory_confuse/keys" "$monitoring_directory_confuse/logs" "$monitoring_directory_confuse/backups"
chmod 700 "$monitoring_directory_confuse" "$monitoring_directory_confuse/keys" "$monitoring_directory_confuse/logs" "$monitoring_directory_confuse/backups"
cp "$executable_path_confuse" "$application_path_confuse/Contents/MacOS/ConfuseDesktop_confuse"
cp -R "$resource_bundle_path_confuse" "$application_path_confuse/Contents/Resources/"
cp "$project_path_confuse/Sources/ConfuseDesktop_confuse/Resources/Confuse_confuse.icns" "$application_path_confuse/Contents/Resources/Confuse_confuse.icns"
cp "$project_path_confuse/Info_confuse.plist" "$application_path_confuse/Contents/Info.plist"

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 1.0.0" "$application_path_confuse/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleVersion string 1" "$application_path_confuse/Contents/Info.plist" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion 1" "$application_path_confuse/Contents/Info.plist"
codesign --force --deep --sign - "$application_path_confuse"

echo "已生成应用：$application_path_confuse"
echo "已准备映射目录：$mapping_directory_confuse"
echo "已准备监控目录：$monitoring_directory_confuse"
