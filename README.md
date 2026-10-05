<h1>
<p align="center">
<a href="https://github.com/GnomeShift/OpenVPN-pipeline" target="_blank" rel="noopener noreferrer">OpenVPN-pipeline</a>
</p>
</h1>

# 🌐 Overview
Pipeline for OpenVPN Docker images builds.

[![OpenVPN image build](https://img.shields.io/github/actions/workflow/status/GnomeShift/OpenVPN-pipeline/build-openvpn.yml?logo=github&label=Build%20OpenVPN)](https://github.com/GnomeShift/OpenVPN-pipeline/actions/workflows/build-openvpn.yml)
[![Docker image size](https://img.shields.io/docker/image-size/gnomeshift/openvpn-test?logo=docker)](https://hub.docker.com/r/gnomeshift/openvpn-test)
[![License](https://img.shields.io/github/license/GnomeShift/OpenVPN-pipeline?color=%239944ee)](https://github.com/GnomeShift/OpenVPN-pipeline/blob/master/LICENSE)

## 🌟 Features
- Latest OpenVPN version autodetect.
- Based on [kylemanna/openvpn](https://hub.docker.com/r/kylemanna/openvpn/).
- Multi-arch (linux/amd64, linux/arm64).
- Manual start via GitHub Actions.

## 🚀 Quick start
1. Add secret `DOCKERHUB_PASSWORD` and variable `DOCKERHUB_LOGIN` on the `Settings` -> `Secrets and variables` -> `Actions` tab.
2. Start pipeline via GitHub Actions.
3. Specify build params (optional):
   - Docker image name (default: openvpn).
4. Click on `Run workflow` button.
5. Done! You can view build summary on the pipeline page.

<p align="center">
   <i>© GnomeShift 2026 - present</i><br>
   <i>Licensed under <a href="https://github.com/GnomeShift/OpenVPN-pipeline/blob/HEAD/LICENSE">MIT</a></i><br><br>
   <i>Credits:</i><br>
   <i><a href="https://github.com/OpenVPN/openvpn/blob/master/COPYRIGHT.GPL">OpenVPN</a> licensed under GPL-2.0</i><br>
   <i><a href="https://github.com/kylemanna/docker-openvpn/blob/master/LICENSE">docker-openvpn</a> licensed under MIT</i>
</p>
