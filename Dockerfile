FROM node:8-alpine

WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY ./ ./

EXPOSE 8000
ENTRYPOINT [ "yarn" ]
CMD ["serve"]
