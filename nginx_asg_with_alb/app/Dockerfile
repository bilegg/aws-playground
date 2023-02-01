FROM node:current-alpine3.16
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm i
COPY . .
EXPOSE 80
CMD [ "node", "app.js" ]