# 使用官方 Python 镜像
FROM python:3.10-slim

# 设置工作目录
WORKDIR /app

# 安装 Git 和 supervisord
RUN apt-get update && apt-get install -y git supervisor && apt-get clean



# 克隆项目
RUN git clone -b patch-1 https://github.com/oinktech/bilibot.git .

RUN cd patch-1

# 安装项目依赖
RUN pip install --no-cache-dir -r requirements.txt



# 模型微调训练
RUN python -m mlx_lm.lora --model models/Qwen1.5-32B-Chat --data data/ --train --iters 1000 --batch-size 16 --lora-layers 12

# 合并微调后的模型
RUN python -m mlx_lm.fuse --model models/Qwen1.5-32B-Chat --save-path models/Qwen1.5-32B-Chat-FT --adapter-path models/Qwen1.5-32B-Chat-Adapters

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
