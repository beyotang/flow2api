FROM python:3.11-slim

WORKDIR /app

# 使用清华镜像源加速 apt (Debian bookworm)
RUN sed -i 's|deb.debian.org|mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list.d/debian.sources \
    && sed -i 's|security.debian.org|mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list.d/debian.sources

# 安装 Playwright 所需的系统依赖
RUN apt-get update && apt-get install -y \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libpango-1.0-0 \
    libcairo2 \
    && rm -rf /var/lib/apt/lists/*

# 安装 Python 依赖（使用清华 PyPI 镜像）
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    -i https://pypi.tuna.tsinghua.edu.cn/simple/ \
    --trusted-host pypi.tuna.tsinghua.edu.cn

# 设置 Playwright 下载镜像（使用 npmmirror）
ENV PLAYWRIGHT_DOWNLOAD_HOST=https://registry.npmmirror.com/-/binary/playwright

# 安装 Playwright 浏览器
RUN playwright install chromium

COPY . .

# Zeabur 会动态设置 PORT 环境变量，默认 8000
ENV PORT=8000

# 暴露端口（Zeabur 会自动处理）
EXPOSE ${PORT}

# ✅ 关键修改：使用 uvicorn 直接启动，监听 0.0.0.0 和 $PORT
CMD uvicorn src.main:app --host 0.0.0.0 --port ${PORT}
