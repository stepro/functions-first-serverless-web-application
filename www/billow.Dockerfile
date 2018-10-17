FROM node AS build
WORKDIR /src
COPY . .
RUN npm install
RUN npm run generate

FROM scratch
COPY billow.yaml .
COPY --from=build /src/dist /pkg
