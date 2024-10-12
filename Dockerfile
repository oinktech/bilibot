# 使用官方 Python 镜像
FROM python:3.10-slim

# 设置工作目录
WORKDIR /app

# 安装 Git 和 supervisord 以及构建依赖
RUN apt-get update && \
    apt-get install -y git supervisor build-essential libasound-dev gcc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 克隆项目
RUN git clone -b patch-1 https://github.com/oinktech/bilibot.git .

# 确保 requirements.txt 文件存在
RUN ls -l && echo "Contents of requirements.txt:" && cat requirements.txt

# 安装项目依赖
RUN pip install --no-cache-dir -r requirements.txt


# 对合并后的模型进行量化加速
RUN python tools/compress_model.py

# 创建 supervisord 配置文件
RUN echo "[supervisord]" > /etc/supervisor/conf.d/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "[program:chatbot]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=python chat.py" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "[program:webui]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=python webui.py" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "[program:app]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=python app.py" >> /etc/supervisor/conf.d/supervisord.conf

# 暴露所需的端口
EXPOSE 9880 9881 10000

# 启动 supervisord
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
