# Dockerfile
FROM --platform=linux/amd64 public.ecr.aws/lambda/python:3.9

# Copy requirements.txt
COPY requirements.txt ${LAMBDA_TASK_ROOT}

# Install the specified packages
RUN pip install -r requirements.txt

# Copy function code
COPY ./app ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler
CMD [ "main.handler" ]