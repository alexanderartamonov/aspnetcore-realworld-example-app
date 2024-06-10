#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["src/Conduit/Conduit.csproj", "build/"]
RUN dotnet restore "src/Conduit/Conduit.csproj"
COPY . .
WORKDIR "/src/Conduit"
RUN dotnet build "Conduit.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Conduit.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
EXPOSE 5000

ENTRYPOINT ["dotnet", "Conduit.dll"]
