# 使用官方 Python 镜像
FROM python:3.10-slim

# 设置工作目录
WORKDIR /app

# 安装 Git 和构建依赖

RUN python -m mlx_lm.lora -h

# 对合并后的模型进行量化加速
RUN python -m mlx_lm.lora --model models/Qwen1.5-32B-Chat --data data/ --train --iters 1000 --batch-size 16 --lora-layers 12
RUN python -m mlx_lm.fuse --model models/Qwen1.5-32B-Chat --save-path models/Qwen1.5-32B-Chat-FT --adapter-path models/Qwen1.5-32B-Chat-Adapters

RUN ls

# 暴露所需的端口
EXPOSE 10000

# 启动 Flask 应用
CMD ["python3", "main/app.py"]
