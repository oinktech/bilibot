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

# 确保 requirements.txt 文件存在
RUN ls -l && echo "Contents of requirements.txt:" && cat requirements.txt

# 安装项目依赖
RUN pip install --no-cache-dir -r requirements.txt

# 安装 PyTorch 和相关库
RUN pip install torch torchvision torchaudio

# 创建一个 models 文件夹并将克隆的模型储存到该文件夹
RUN mkdir -p models && \
    git clone https://huggingface.co/Qwen/Qwen1.5-32B-Chat models/Qwen1.5-32B-Chat


# 打印文件列表以确认所有文件和目录
RUN ls -la

# 暴露所需的端口
EXPOSE 10000

# 启动 Flask 应用
CMD ["python3", "main/app.py"]
