#!/usr/bin/env bash
curl -Ls 'https://github.com/siderolabs/talos/releases/download/v1.7.6/oracle-arm64.qcow2.xz' | xz -d > oracle-arm64.qcow2
cp image_metadata_arm64.json image_metadata.json
tar -cf oracle-arm64.oci oracle-arm64.qcow2 image_metadata.json
rm -f ./*.qcow2 image_metadata.json