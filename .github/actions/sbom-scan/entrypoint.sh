#!/bin/bash

syft requirements.txt -o cyclonedx-json=shom.json 
grype sbom.json --by-cve --fail-on critical
