![GitHub Repo stars](https://img.shields.io/github/stars/Sakurababycat/VncViewerForHarmonyNext)
![GitHub watchers](https://img.shields.io/github/watchers/Sakurababycat/VncViewerForHarmonyNext)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# Simple VncViewer For Harmony os next

<div style="text-align: center;">
  <img src="./application/src/main/resources/base/media/startIcon.png" alt="Logo" width="400">
</div>

English, [简体中文](README.md)

## Table of Contents

- [Simple VncViewer For Harmony os next](#simple-vncviewer-for-harmony-os-next)
    - [Table of Contents](#table-of-contents)
    - [Introduction](#introduction)
    - [Build](#build)
        - [Clone the Project](#clone-the-project)
        - [Build and Install](#build-and-install)
    - [Installation](#installation)
    - [To-Do](#to-do)
    - [Acknowledgments](#acknowledgments)

## Introduction

A native HarmonyOS application developed using LibVncServer with NAPI and ArkTS, featuring basic connection and remote
control functionalities.
![login](https://github.com/Sakurababycat/pictureRepo/blob/master/simpleVnc/simplevnc_md1.png)
![main](https://github.com/Sakurababycat/pictureRepo/blob/master/simpleVnc/simplevnc_md2.png)

## Build

###### Clone the Project

```bash
   git clone https://github.com/Sakurababycat/VncViewerForHarmonyNext.git simple_vnc
   cd simple_vnc
   git submodule init
   git submodule update
 ```

###### Build and Install

- Open the project in Huawei DevEco Studio
- Configure the signing
- Run the application

## Installation

- TODO: Application requires signing, look for a manual signing method.

## To-Do

- [x] Basic functionality
- [ ] Unexpected disconnection handling
- [x] Mouse scroll events
- [ ] Custom key mappings
- [ ] Clipboard
- [ ] File transfer
- [ ] Use native rendering framework to improve performance
- [ ] Secure connection ...

## Acknowledgments

|                     Nickname                     | Contribution |
|:------------------------------------------------:|--------------|
| [LibVNC](https://github.com/LibVNC/libvncserver) | LibVncServer |
