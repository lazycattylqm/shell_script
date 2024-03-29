import argparse
import os
import re


def process_file(input_file, output_file, keywords):
  # 判断文件路径是否为绝对路径，如果不是，则转换为绝对路径
  if not os.path.isabs(input_file):
    input_file = os.path.join(os.getcwd(), input_file)
  if not os.path.isabs(output_file):
    output_file = os.path.join(os.getcwd(), output_file)

  # 如果输出文件已存在，删除它
  if os.path.exists(output_file):
    os.remove(output_file)

  with open(input_file, 'r') as f_in, open(output_file, 'w') as f_out:
    lines = f_in.readlines()
    module_name = None
    for line in lines:
      if line.startswith('XI'):
        module_name = re.search(r'/\s*(\w+)\s*', line)
        if module_name:
          module_name = module_name.group(1)
      if module_name and module_name in keywords:
        key_values = re.findall(r'(\w+<.*?>)=(\w+<.*?>)', line)
        for key_value in key_values:
          key, value = key_value
          new_value = value.replace('<', '[').replace('>', ']')
          line = line.replace(value, new_value)
      f_out.write(line)

  # 第二个功能：删除以 ".subckt" 开头到以 ".ENDS" 开头的行
  with open(output_file, 'r') as f:
    lines = f.readlines()
  with open(output_file, 'w') as f:
    in_subckt = False
    for line in lines:
      if line.strip().upper().startswith('.SUBCKT'):
        in_subckt = True
      if not in_subckt:
        f.write(line)
      if line.strip().upper().startswith('.ENDS'):
        in_subckt = False

if __name__ == "__main__":
  parser = argparse.ArgumentParser(description='Process some files.')
  parser.add_argument('inputfile', help='The input file to be processed')
  parser.add_argument('outputfile', help='The output file to write the result')
  parser.add_argument('keywords', nargs='+', help='The keywords to be used')
  args = parser.parse_args()

  process_file(args.inputfile, args.outputfile, args.keywords)