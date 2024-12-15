# Use an official Python runtime as a parent image
FROM python:3.12-slim-bookworm
COPY --from=ghcr.io/astral-sh/uv:0.5.9 /uv /bin/uv

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# Install system dependencies required for OCRmyPDF
RUN apt-get update && apt-get install -y \
    # OCRmyPDF core dependencies
    ghostscript \
    tesseract-ocr \
    # Additional language packs - add more if needed
    tesseract-ocr-eng \
    tesseract-ocr-deu \
    # PDF processing dependencies
    unpaper \
    pngquant \
    # Build dependencies
    gcc \
    g++ \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first to leverage Docker cache
COPY pyproject.toml .

# Install Python dependencies
RUN uv sync --frozen

# Copy the webservice code
COPY misc/webservice.py .

# Expose the port the app runs on
EXPOSE 5000

# Command to run the application
CMD ["uv", "run", "webservice.py"] 
