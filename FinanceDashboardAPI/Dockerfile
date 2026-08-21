# ================================
# Stage 1: Build
# ================================
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /src

# Copy project file first
COPY FinanceDashboardAPI.csproj ./

# Restore dependencies
RUN dotnet restore

# Copy source code
COPY . ./

# Build and publish
RUN dotnet publish FinanceDashboardAPI.csproj \
    -c Release \
    -o /app/publish \
    --no-restore


# ================================
# Stage 2: Runtime
# ================================
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final

WORKDIR /app

# Copy published application
COPY --from=build /app/publish .

# Application port
EXPOSE 8080

# Start application
ENTRYPOINT ["dotnet", "FinanceDashboardAPI.dll"]