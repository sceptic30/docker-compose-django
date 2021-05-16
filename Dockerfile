# For more information, please refer to https://aka.ms/vscode-docker-python
FROM admintuts/python:3.9.5-buster-slim
USER root
EXPOSE 8000

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY ./app /app
COPY requirements.txt /app

# Install pip requirements
RUN python -m pip install -r requirements.txt \
    && chown python:python -R /app \
    && chmod 770 -R /app \
    && chmod 755 -R /app/app/static

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
#RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
#USER appuser
#The image admintuts/python:3.9.5-buster-slim already using a custom made user named "python" so we skipping this step

# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
# File wsgi.py was not found in subfolder: 'django'. Please enter the Python path to wsgi file.
USER python
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app.wsgi"]