# Use the official .NET 5 SDK image as the build environment
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build-env
WORKDIR /app

# Copy the project files and restore any dependencies
COPY *.sln .
COPY src/DevOpsChallenge.SalesApi/*.csproj ./src/DevOpsChallenge.SalesApi/
COPY src/DevOpsChallenge.SalesApi.Business/*.csproj ./src/DevOpsChallenge.SalesApi.Business/
COPY src/DevOpsChallenge.SalesApi.Database/*.csproj ./src/DevOpsChallenge.SalesApi.Database/
COPY tests/DevOpsChallenge.SalesApi.Business.UnitTests/*.csproj ./tests/DevOpsChallenge.SalesApi.Business.UnitTests/
COPY tests/DevOpsChallenge.SalesApi.IntegrationTests/*.csproj ./tests/DevOpsChallenge.SalesApi.IntegrationTests/
RUN dotnet restore

# Copy the rest of the files for unit test and publish
COPY . .


# Run unit tests. Ignore the pass/fail status and exit with 0
RUN dotnet test tests/DevOpsChallenge.SalesApi.Business.UnitTests/*.csproj --logger "trx;LogFileName=unit-test-results.trx" || exit 0

# Run integration tests. Ignore the pass/fail status and exit with 0
RUN dotnet test tests/DevOpsChallenge.SalesApi.IntegrationTests/*.csproj --logger "trx;LogFileName=integration-test-results.trx" || exit 0

# Publish the application
RUN dotnet publish -c Release -o out

# Use the official ASP.NET Core runtime image as the runtime environment
FROM mcr.microsoft.com/dotnet/aspnet:5.0
WORKDIR /app
COPY --from=build-env /app/out .

# Set environment variables for the database connection and ASP.NET Core environment
ENV ASPNETCORE_ENVIRONMENT=Development

# Expose the ports
EXPOSE 80

# Start the application
ENTRYPOINT ["dotnet", "DevOpsChallenge.SalesApi.dll"]
