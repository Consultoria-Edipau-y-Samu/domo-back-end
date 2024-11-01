# Construir la imagen
sudo docker build -t domo-back-end .

# Ejecutar el contenedor
docker run -d -p 8080:8080 --name domo-back-end domo-back-end
