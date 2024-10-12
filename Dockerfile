# 使用官方 Python 镜像
FROM python:3.10

# 设置工作目录
WORKDIR /app

# 安装 Git 和构建依赖
RUN apt-get update && \
    apt-get install -y git build-essential libasound-dev gcc libffi-dev libgomp1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 克隆项目
RUN git clone -b patch-1 https://github.com/oinktech/bilibot.git .

# 安装项目依赖
RUN pip install --no-cache-dir -r requirements.txt

# 安装 PyTorch 和相关库
RUN pip install torch torchvision torchaudio

# 创建模型和数据目录
RUN mkdir -p models && mkdir -p data

# 克隆模型
RUN git clone https://huggingface.co/Qwen/Qwen1.5-32B-Chat models/Qwen1.5-32B-Chat

# 对合并后的模型进行量化加速
# 降低迭代次数和批处理大小，避免内存问题
RUN python -m mlx_lm.lora --model models/Qwen1.5-32B-Chat --data data/ --train --iters 100 --batch-size 4 --num-layers 6 --fine-tune-type lora

# 融合模型
RUN python -m mlx_lm.fuse --model models/Qwen1.5-32B-Chat --save-path models/Qwen1.5-32B-Chat-FT --adapter-path models/Qwen1.5-32B-Chat-Adapters

# 暴露所需的端口
EXPOSE 10000

# 启动 Flask 应用
CMD ["python3", "main/app.py"]
