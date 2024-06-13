#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
WORKDIR /app
EXPOSE 5000
ENV DEBIAN_FRONTEND noninteractive
RUN uname -m
ARG TRACER_VERSION
RUN apt-get -y update \
&& apt-get install -y curl

RUN echo 'install dotnet tracer' && \
    mkdir -p /opt/datadog \
    && mkdir -p /var/log/datadog \
    && curl -LO https://github.com/DataDog/dd-trace-dotnet/releases/download/v${TRACER_VERSION}/datadog-dotnet-apm_${TRACER_VERSION}_arm64.deb \
    && dpkg -i ./datadog-dotnet-apm_${TRACER_VERSION}_arm64.deb \
    && /opt/datadog/createLogPath.sh \
    && rm ./datadog-dotnet-apm_${TRACER_VERSION}_arm64.deb

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .

RUN dotnet restore "/src/src/Conduit/Conduit.csproj"
RUN dotnet build "/src/src/Conduit/Conduit.csproj" -c Release -o /app/build
FROM build AS publish
ARG asmver
RUN dotnet publish "/src/src/Conduit/Conduit.csproj" -c Release -o /app/publish -p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Conduit.dll"]
