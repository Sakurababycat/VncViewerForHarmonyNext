![GitHub Repo stars](https://img.shields.io/github/stars/Sakurababycat/VncViewerForHarmonyNext)
![GitHub watchers](https://img.shields.io/github/watchers/Sakurababycat/VncViewerForHarmonyNext)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# Simple VncViewer For Harmony os next

<div style="text-align: center;">
  <img src="./application/src/main/resources/base/media/startIcon.png" alt="Logo" width="400">
</div>

[English](README_en.md), 简体中文

## 目录

- [Simple VncViewer For Harmony os next](#simple-vncviewer-for-harmony-os-next)
    - [目录](#目录)
    - [简介](#简介)
    - [构建](#构建)
        - [克隆项目](#克隆项目)
        - [构建安装](#构建安装)
    - [安装](#安装)
    - [待办](#待办)
    - [鸣谢](#鸣谢)

## 简介

基于LibVncServer使用napi与arkts开发的原生鸿蒙应用，具备基本的连接与远程控制功能。
![登录界面](https://github.com/Sakurababycat/pictureRepo/blob/master/simpleVnc/simplevnc_md1.png)
![主界面](https://github.com/Sakurababycat/pictureRepo/blob/master/simpleVnc/simplevnc_md2.png)

## 构建

###### 克隆项目

 ```bash
   git clone https://github.com/Sakurababycat/VncViewerForHarmonyNext.git simple_vnc
   cd simple_vnc
   git submodule init
   git submodule update
 ```

###### 构建安装

- 使用华为DevEco studio打开项目
- 配置签名
- 运行

## 安装

- TODO:安装应用需要签名，寻找手动签名的方法

## 待办

- [x] 基础功能
- [ ] 意外断联处理
- [ ] 鼠标滚轮事件
- [ ] 自定义按键映射
- [ ] 剪切板
- [ ] 文件传输
- [ ] 使用原生渲染框架提升性能
- [ ] 安全连接
  ...

## 鸣谢

|                     Nickname                     | Contribution |
|:------------------------------------------------:|--------------|
| [LibVNC](https://github.com/LibVNC/libvncserver) | LibVncServer |
