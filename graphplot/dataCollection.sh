#!/bin/bash
# 这行是"shebang"，告诉系统使用哪个解释器来执行脚本
# #!/bin/bash 表示使用 Bash shell 来执行这个脚本

# 定义输出文件名
outputFile="energy_volume_magnetization.txt"
# 创建一个名为 outputFile 的变量，并将字符串赋值给它
# 这个变量将存储我们要创建的输出文件的名称

> "$outputFile"
# 这是一个重定向操作
# > 表示"输出重定向"，它会创建一个空文件（如果文件不存在）或清空已有文件
# "$outputFile" 表示使用变量 outputFile 的值作为文件名
# 整体意思是：创建一个名为 energy_volume_magnetization.txt 的空文件

# 添加标题行到输出文件
echo -e "Directory\t\tEnergy\t\tVolume\t\tMagnetization(z)" >> "$outputFile"
# echo 命令用于输出文本
# -e 选项允许 echo 解释转义字符（如 \t 表示制表符）
# "Directory\t\tEnergy..." 是要输出的文本，其中 \t 表示制表符，用于对齐
# >> 表示"追加重定向"，将输出添加到文件末尾（而不是覆盖）
# "$outputFile" 是我们要追加到的文件名

# 开始循环处理目录
for dir in $(find . -maxdepth 1 -type d | sort -n); do
# for 循环：对每个找到的目录执行循环体内的命令
# find . -maxdepth 1 -type d 查找当前目录下的所有子目录（不包含更深层的目录）
# | sort -n 将 find 的结果通过管道传递给 sort 命令，按数字顺序排序
# do 表示循环体的开始

    # 检查目录名是否为"./saveScripts"或当前目录"."，如果是则跳过
    if [ "$dir" != "./saveScripts" ] && [ "$dir" != "." ]; then
    # if 条件语句：检查两个条件是否都成立
    # [ ] 是测试条件语法
    # "$dir" != "./saveScripts" 检查目录名不是 "./saveScripts"
    # && 表示"并且"
    # "$dir" != "." 检查目录名不是当前目录 "."
    # then 表示条件成立时要执行的代码开始

        # 提取目录的基本名称（去掉路径部分）
        dir_name=$(basename "$dir")
        # basename 命令提取路径中的最后一部分（目录名或文件名）
        # $(command) 是命令替换语法，表示执行命令并用结果替换
        # 这里将 basename "$dir" 的结果赋值给变量 dir_name

        # 检查该目录下是否存在OUTCAR文件
        if [[ -f "$dir/OUTCAR" ]]; then
        # [[ ]] 是增强型测试条件语法
        # -f 检查后面跟的路径是否是一个普通文件
        # "$dir/OUTCAR" 是文件的完整路径

            # 提取能量值
            energy=$(awk '/energy without/ {
                if (match($0, /\-+[0-9]+(\.[0-9]+)?/)) {
                    last_line=substr($0, RSTART, RLENGTH)
                }
            } END {print last_line}' "$dir/OUTCAR")
            # 使用 awk 工具处理文本
            # '/energy without/' 是模式匹配，查找包含"energy without"的行
            # match() 函数使用正则表达式匹配数字（包括负号和小数点）
            # substr() 函数提取匹配到的子字符串
            # END 块在处理完所有行后执行，打印最后匹配到的能量值
            # "$dir/OUTCAR" 是要处理的文件路径
            # 整个 awk 命令的结果被赋值给 energy 变量

            # 提取体积值
            volume=$(awk '/volume of cell/ {vol = $NF} END {printf "%.6f", vol+0}' "$dir/OUTCAR")
            # 另一个 awk 命令
            # '/volume of cell/' 查找包含"volume of cell"的行
            # $NF 表示当前行的最后一个字段
            # END 块中格式化输出为6位小数
            # 结果赋值给 volume 变量

            # 提取磁矩(z)值
            magnetization=$(awk '
            /^ magnetization \(z\)/ {
                found = 1
                next
            }
            found && /^tot/ {
                total_mag = $NF
                found = 0
            }
            END {
                printf "%.6f", total_mag+0
            }' "$dir/OUTCAR")
            # 更复杂的 awk 命令，用于提取磁矩部分
            # /^ magnetization \(z\)/ 匹配以"magnetization (z)"开头的行
            # found = 1 设置标志表示找到了磁矩部分
            # next 跳过当前行，继续处理下一行
            # found && /^tot/ 当找到磁矩部分且当前行以"tot"开头时
            # $NF 获取最后一个字段（总磁矩值）
            # found = 0 重置标志
            # END 块中格式化输出为6位小数

            # 将提取的数据写入输出文件
            printf "%-20s %-15s %-15s %-15s\n" "$dir_name" "$energy" "$volume" "$magnetization" >> "$outputFile"
            # printf 命令用于格式化输出
            # %-20s 表示左对齐的字符串，宽度为20字符
            # %-15s 表示左对齐的字符串，宽度为15字符
            # \n 表示换行
            # "$dir_name", "$energy" 等是要输出的变量值
            # >> "$outputFile" 将格式化后的输出追加到文件

        else
            # 如果OUTCAR文件不存在，打印警告信息
            echo "Warning: OUTCAR not found in $dir" >&2
            # echo 输出警告信息
            # >&2 表示将输出重定向到标准错误流（屏幕显示，但不同于标准输出）
        fi
        # fi 结束内部的 if 语句

    fi
    # fi 结束外部的 if 语句

done
# done 结束 for 循环

# 格式化输出文件（移除可能的前缀）
sed -i 's/^[\/]*//' "$outputFile"
# sed 是流编辑器，用于文本转换
# -i 选项表示直接修改文件（而不是输出到屏幕）
# 's/^[\/]*//' 是替换命令
# s/pattern/replacement/ 表示将匹配 pattern 的文本替换为 replacement
# ^[\/]* 匹配行首的零个或多个斜杠字符
# 替换为空，即删除行首的斜杠

sed -i 's/^[^a-zA-Z]*//' "$outputFile"
# 另一个 sed 命令
# 's/^[^a-zA-Z]*//' 匹配行首的零个或多个非字母字符，并删除它们
# [^a-zA-Z] 表示不是字母的字符
