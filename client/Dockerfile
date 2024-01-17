FROM node:21-alpine3.19

WORKDIR /app

COPY package*.json /app

RUN npm install

COPY . /app/

RUN npm run build

ENV PORT 3000

ENV HOST 0.0.0.0 

EXPOSE 3000 

CMD ["npm", "start"]

