FROM node:18
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install -g npm@10.2.5
RUN npm install
RUN npm install experss
COPY . .
EXPOSE 3000
CMD ["node", "src/index.js", "--no-deamon"]
