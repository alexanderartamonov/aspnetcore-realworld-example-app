#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
ARG TRACER_VERSION
ARG DEBIAN_FRONTEND=noninteractive
RUN useradd build \
&& apt-get -y update \
&& apt-get -y install \
curl \
apt-transport-https \
libvshadow-utils \
libssl-dev \
tzdata \
libicu-dev \
&& rm -rf  /var/log/apt* /var/log/apt.*;

RUN echo 'install dotnet tracer' && \
    mkdir -p /opt/datadog \
    && mkdir -p /var/log/datadog \
    && curl -LO https://github.com/DataDog/dd-trace-dotnet/releases/download/v${TRACER_VERSION}/datadog-dotnet-apm_${TRACER_VERSION}_arm64.deb \
    && dpkg -i ./datadog-dotnet-apm_${TRACER_VERSION}_arm64.deb \
    && /opt/datadog/createLogPath.sh \
    && rm ./datadog-dotnet-apm_${TRACER_VERSION}_arm64.deb
    
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["src/Conduit/Conduit.csproj", "build/"]
COPY ["nuget.config", "/"]
RUN dotnet restore "Conduit/Conduit.csproj"
COPY . .
WORKDIR "/src/Conduit"
RUN dotnet build "Conduit.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Conduit.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
RUN ls -la /app/publish
EXPOSE 5000
ENTRYPOINT ["dotnet", "Conduit.dll"]
