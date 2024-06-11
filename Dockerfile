# Etapa de construcción
FROM node:18-alpine AS build

# Establece el directorio de trabajo en el contenedor
WORKDIR /app

# Instala git para clonar el repositorio
RUN apk add --no-cache git

# Clona el repositorio directamente en el directorio de trabajo
RUN git clone https://github.com/JoeArtisan/earthquake-web.git .

# Instala las dependencias del proyecto
RUN npm install

# Compila la aplicación para producción
RUN npm run build

# Etapa de producción
FROM nginx:stable-alpine

# Copia los archivos construidos desde la etapa de construcción
COPY --from=build /app/dist /usr/share/nginx/html

# Exponer el puerto en el que Nginx servirá la aplicación
EXPOSE 80

# Comando para ejecutar Nginx en modo foreground
CMD ["nginx", "-g", "daemon off;"]
