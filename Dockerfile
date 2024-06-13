#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM --platform=arm64 089465505731.dkr.ecr.ap-southeast-1.amazonaws.com/dotnet8:aspnetcore AS base
WORKDIR /app
EXPOSE 5000
ENV DEBIAN_FRONTEND noninteractive
RUN uname -m
ARG TRACER_VERSION
RUN apt-get -y update

RUN echo 'install dotnet tracer' && \
    mkdir -p /opt/datadog \
    && mkdir -p /var/log/datadog \
    && curl -LO https://github.com/DataDog/dd-trace-dotnet/releases/download/v${TRACER_VERSION}/datadog-dotnet-apm_${TRACER_VERSION}_arm64.deb \
    && dpkg -i ./datadog-dotnet-apm_${TRACER_VERSION}_arm64.deb \
    && /opt/datadog/createLogPath.sh \
    && rm ./datadog-dotnet-apm_${TRACER_VERSION}_arm64.deb

FROM --platform=arm64 089465505731.dkr.ecr.ap-southeast-1.amazonaws.com/dotnet8:sdk AS build
WORKDIR /src
COPY . .
WORKDIR /src
RUN dotnet restore "src/Conduit/Conduit.csproj"
RUN dotnet build "src/Conduit/Conduit.csproj" -c Release -o /app/build
FROM build AS publish
ARG asmver
RUN dotnet publish "src/Conduit/Conduit.csproj" -c Release -o /app/publish -p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Conduit.dll"]
