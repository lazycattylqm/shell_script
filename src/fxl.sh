#!/usr/bin/env bash#!/bin/bash

# 获取命令行参数
inputfile=$1
outputfile=$2
shift 2
keywords=$@

# 如果输出文件已存在，删除它
if [ -f $outputfile ]; then
  rm $outputfile
fi

# 第一个功能：替换关键字行中的尖括号为方括号
for keyword in $keywords; do
  awk -v keyword=$keyword '/XI/ {module = $0} module ~ keyword {gsub(/</, "["); gsub(/>/, "]")} {print}' $inputfile >> $outputfile
done

# 第二个功能：删除以 ".subckt" 开头到以 ".ENDS" 开头的行
awk '!/\.SUBCKT/,/\.ENDS/' $outputfile > temp.txt && mv temp.txt $outputfile

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