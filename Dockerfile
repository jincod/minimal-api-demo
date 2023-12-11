FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS builder
WORKDIR /source
COPY /*.props /*.targets ./
# Copy the main source project files
# COPY src/*/*.csproj ./
# RUN for file in $(ls *.csproj); do mkdir -p src/${file%.*}/ && mv $file src/${file%.*}/; done
COPY Api.csproj Api.csproj
RUN dotnet restore -r linux-musl-x64

# Copy across the rest of the source files
COPY . .
RUN dotnet publish ./Api.csproj -c Release -r linux-musl-x64 -o /app/out --no-restore
RUN rm /app/*.dbg /app/*.Development.json

FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-alpine
RUN apk add --no-cache \
    mkpasswd \
    && rm -rf /var/cache/apk/*
WORKDIR /app
COPY --from=builder /app/out .
USER $APP_UID
ENTRYPOINT ["./Api"]
