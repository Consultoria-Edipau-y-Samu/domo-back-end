# Construir la imagen
sudo docker build -t domo-back-end .

# Ejecutar el contenedor
sudo docker run -d -p 8080:8080 --name domo-back-end domo-back-end

# Muestra los logs del contenedor en tiempo real
sudo docker logs -f domo-back-end

#Ejecuta el contenedor con las credenciales de AWS
sudo docker run -d -p 8080:8080 \
    -v ~/.aws:/root/.aws \
    --name domo-back-end domo-back-end