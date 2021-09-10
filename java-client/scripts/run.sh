#!/bin/sh

set -eu

mvn clean package -DskipTests exec:java -Dexec.mainClass="org.cloudfoundry.eirini.App"
