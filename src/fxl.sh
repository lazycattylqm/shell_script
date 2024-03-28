#!/usr/bin/env bash

# 获取文件路径和关键字参数
file_path=$1
shift
keywords=("$@")

echo $file_path

echo $keywords

# 初始化变量
in_module=false
current_module=""

# 读取文件
while IFS= read -r line
do
  # 检查是否是一个新的模块
  if [[ $line =~ ^XI[[:space:]]*/[[:space:]]*(.*)$ ]]; then
    current_module=${BASH_REMATCH[1]}
    in_module=false
    for keyword in "${keywords[@]}"; do
      if [[ $current_module == $keyword ]]; then
        in_module=true
        break
      fi
    done
  elif $in_module; then
    # 如果在模块内，查找并替换文本
    if [[ $line =~ (.*=)(<.*>)(.*) ]]; then
      left=${BASH_REMATCH[1]}
      middle=${BASH_REMATCH[2]//</[}
      middle=${middle//>/]}
      right=${BASH_REMATCH[3]}
      line="$left$middle$right"
    fi
    
  fi
  echo "$line" >> output.txt
done < "$file_path"