#!/bin/bash
set -eu
TRACER_VERSION=$1
echo "install dotnet tracer ${TRACER_VERSION}"
# mkdir -p /opt/datadog 
# mkdir -p /var/log/datadog 
# curl -LO https://github.com/DataDog/dd-trace-dotnet/releases/download/v${TRACER_VERSION}/datadog-dotnet-apm_${TRACER_VERSION}_amd64.deb
# dpkg -i ./datadog-dotnet-apm_${TRACER_VERSION}_amd64.deb 
# /opt/datadog/createLogPath.sh 
# rm ./datadog-dotnet-apm_${TRACER_VERSION}_amd64.deb