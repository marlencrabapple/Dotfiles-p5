#!/usr/bin/env bash
[[ "${DEBUG:-0}" -eq 1 ]] && set -x
 
for in in "$@"; do
  cjxl --lossless_jpeg=1 -e 10 "$in" "$in.jxl"
 
  fs=($(du -h "$in"{.jxl,}))
 
  echo -e "\n  In: ${fs[*]:2:2}"
  echo -e "  Out: ${fs[*]:0:2}\n"
  rm -v "$in"
done
