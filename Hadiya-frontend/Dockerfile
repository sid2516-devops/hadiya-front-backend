FROM node:18 AS build
WORKDIR /app
RUN npm install -g @angular/cli
COPY package.json package-lock.json ./
RUN npm install
RUN npm install ng
COPY . . 
RUN npm run build

FROM nginx:latest
RUN rm -rf /usr/share/nginx/html/*

#copy files from build 

COPY --from=build /app/dist/* /usr/share/nginx/html/
EXPOSE 80
