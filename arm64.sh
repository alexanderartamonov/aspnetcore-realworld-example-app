#!/bin/bash
set +x
TRACER_VERSION=$1
echo 'install dotnet tracer' && \
mkdir -p /opt/datadog \
&& mkdir -p /var/log/datadog \
&& curl -LO https://github.com/DataDog/dd-trace-dotnet/releases/download/v${TRACER_VERSION}/datadog-dotnet-apm_${TRACER_VERSION}_arm64.deb \
&& dpkg -i ./datadog-dotnet-apm_${TRACER_VERSION}_arm64.deb \
&& /opt/datadog/createLogPath.sh \
&& rm ./datadog-dotnet-apm_${TRACER_VERSION}_arm64.deb