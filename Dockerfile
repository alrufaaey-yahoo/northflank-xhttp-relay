FROM node:18-alpine

RUN mkdir -p /app
WORKDIR /app

COPY package.json .
COPY index.js .

EXPOSE 3000

CMD ["node", "index.js"]
