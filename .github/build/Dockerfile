FROM mcr.microsoft.com/powershell:6.1.0-ubuntu-18.04

RUN apt-get update && apt-get install -y git

COPY entrypoint.ps1 /entrypoint.ps1
ENTRYPOINT ["pwsh", "/entrypoint.ps1"]
