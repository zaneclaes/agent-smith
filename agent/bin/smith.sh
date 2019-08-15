#!/bin/bash
# set -euo pipefail
echo "[Smith] starting..."

# echo "[Smith] checking that Unity is running"
running=$(ps -ef | grep "/opt/Unity/Editor/Unity" | grep -v "grep")
# echo "[Smith] Running? ${running}"

if [[ ! -z "$running" ]]; then
  echo "[Smith] [Warning] Unity is already running."
  # exit 0
fi

src_dir="$1"
out_dir="$2"
smith_dir="/smith"

if [[ ! -d "$src_dir" ]]; then
  echo "[Smith] the first argument ($src_dir) must be the unity dir"
  exit 1
fi

if [[ ! -d "$out_dir" ]]; then
  echo "[Smith] the first argument ($out_dir) must be an output dir"
  exit 1
fi

echo "[Smith] copying project from ${src_dir} to ${smith_dir}..."
rsync -r --delete \
  --exclude Library --exclude Temp --exclude bin \
  "${src_dir}/" "${smith_dir}"
rm -rf "${smith_dir}/bin" || true
mkdir -p "${smith_dir}/bin"

cd "${smith_dir}"
method="${3:-Build}"
exe="Agent.Smith.${method}"
target="${4}"
semver="${5:-}"
sha="${6:-}"
lf="bin/${target}-${method}.log"
rf="/smith/bin/${target}-report.json"
rm -rf "$lf" || true

echo "[Smith] ${method}(${target}) SemVer ${semver} BuildSha ${sha}"
xvfb-run --auto-servernum --server-args='-screen 0 640x480x24' /opt/Unity/Editor/Unity \
  -nographics -batchmode -quit \
  -projectPath ./ -logFile "$lf" \
  -androidSdkRoot /root/Android -JdkPath /usr/lib/jvm/java-8-oracle \
  -executeMethod "${exe}" -Target "${target}" -SemVer "${semver}" -BuildSha "${sha}"

if [[ ! -f  "$rf" ]]; then
  echo "[Smith] no report file at $rf; logs:"
  cat "$lf"
  exit 1
fi

cat "$rf" | jq -r
result=$(cat "$rf" | jq -r .result)

files=$(ls ${smith_dir}/bin/)
echo "[Smith] copying output to ${out_dir}:"
echo "${files}"
rsync -r "${smith_dir}/bin/" "${out_dir}"

if [[ $result = "Succeeded" ]]; then
  echo "[Smith] Succeeded!"
else
  echo "[Smith] Failed: $result"
  exit 1
fi
