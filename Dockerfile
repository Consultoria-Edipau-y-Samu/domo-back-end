# Usa una imagen base oficial de Python
FROM python:3.9-slim

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos de la carpeta 'app' al contenedor
COPY ./app /app

# Copia el archivo requirements.txt y luego instala las dependencias
COPY requirements.txt /app
RUN pip install --no-cache-dir -r /app/requirements.txt

# Expone el puerto 8080 para FastAPI
EXPOSE 8080

# Especifica el comando para ejecutar FastAPI con Uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
