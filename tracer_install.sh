#!/bin/bash
set -eu
TRACER_VERSION=$1
TARGETARCH=$2
echo "install dotnet tracer ${TRACER_VERSION} for ${TARGETARCH}" \
&& mkdir -p /opt/datadog \
&& mkdir -p /var/log/datadog \
&& curl -o /app https://github.com/DataDog/dd-trace-dotnet/releases/download/v${TRACER_VERSION}/datadog-dotnet-apm_${TRACER_VERSION}_arm64.deb \
&& dpkg -i /app/datadog-dotnet-apm_${TRACER_VERSION}_${TARGETARCH}.deb \
&& /opt/datadog/createLogPath.sh \
&& rm /app/datadog-dotnet-apm_${TRACER_VERSION}_${TARGETARCH}.deb