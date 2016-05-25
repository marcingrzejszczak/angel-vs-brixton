#!/usr/bin/env bash

source common.sh || source scripts/common.sh || echo "No common.sh script found..."

set -e

cat <<EOF
This Bash file will show you the scenario in which Eureka Server is in Brixton version and the Client is Angel.
We will use a Brixton Eureka Tester app to use a load balanced RestTemplate to find the "client" application.

We will do it in the following way:

01) Run eureka-brixton-server
02) Wait for the app (eureka-brixton-server) to boot (port: 8761)
03) Run eureka-brixton-client
04) Wait for the app (eureka-brixton-client) to boot (port: 7778)
05) Wait for the app (eureka-brixton-client) to register in Eureka Server
06) Run eureka-brixton-tester
07) Wait for the app (eureka-brixton-tester) to boot (port: 9876)
08) Wait for the app (eureka-brixton-tester) to register in Eureka Server
09) Call localhost:9876/check to make the app find the eureka-brixton-client
10) Kill eureka-brixton-client
11) Run eureka-angel-client
12) Wait for the app (eureka-angel-client) to boot (port: 7777)
13) Wait for the app (eureka-angel-client) to register in Eureka Server
14) Call localhost:9876/check to make the app find the eureka-angel-client

EOF

echo -e "Ensure that all the apps are built!\n"
build_all_apps

java_jar eureka-brixton-server
wait_for_app_to_boot_on_port 8761

java_jar eureka-brixton-client
wait_for_app_to_boot_on_port 7778
check_app_presence_in_discovery CLIENT

java_jar eureka-brixton-tester
wait_for_app_to_boot_on_port 9876
check_app_presence_in_discovery TESTER

send_test_request 9876
echo -e "\n\nThe Brixton Eureka Client successfully responded to the call"
kill_app eureka-brixton-client

java_jar eureka-angel-client
wait_for_app_to_boot_on_port 7777
check_app_presence_in_discovery CLIENT

send_test_request 9876
echo -e "\n\nThe Angel Eureka Client successfully responded to the call"