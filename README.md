<div align="center">

# 🤖 Transferencia de Información sobre ROS2 e NVIDIA Isaac SIM

![ROS2](https://img.shields.io/badge/ROS2-Humble%20Hawksbill-blue?style=for-the-badge&logo=ros)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20LTS-orange?style=for-the-badge&logo=ubuntu)
![LTS](https://img.shields.io/badge/Soporte-LTS%20hasta%202027-green?style=for-the-badge)
![License](https://img.shields.io/badge/Licencia-Apache%202.0-lightgrey?style=for-the-badge)

**Repositorio para recopilar toda la información relacionada con ROS2, su aplicación en Simulación con Gazebo / Isaac Sim y el control de robots reales a la medida.**

</div>

---

## ¿Qué es ROS 2?

**ROS 2** (*Robot Operating System 2*) es un framework de código abierto para el desarrollo de software para robótica. Provee herramientas, bibliotecas y convenciones que simplifican la tarea de crear comportamientos complejos y robustos en robots de todo tipo.

La distribución de ROS2 con la que vamos a trabajar es con **ROS 2 Humble Hawksbill**, la cual es una distribución **LTS (Long Term Support)** con soporte oficial hasta **mayo de 2027**, siendo la versión recomendada para proyectos en producción sobre Ubuntu 22.04 (Jammy Jellyfish).

---

## 🌐 ¿Qué es NVIDIA Isaac Sim?

**Isaac Sim** es la plataforma de simulación robótica de NVIDIA, construida sobre Omniverse. Permite crear entornos fotorrealistas con física precisa (PhysX), generar datos sintéticos para entrenar modelos de percepción y probar robots antes de llevarlos a hardware real, con soporte nativo para **ROS 2** a través de su bridge integrado.

A diferencia de Gazebo, Isaac Sim requiere una **GPU NVIDIA RTX** y está orientado a simulaciones de alta fidelidad (renderizado con trazado de rayos, sensores simulados con ruido realista, generación de datasets). Es la opción recomendada cuando el proyecto necesita visión por computadora, aprendizaje por refuerzo o gemelos digitales.

El primer paso para empezar a usarlo es instalar **Isaac Sim 6.1.0 en Ubuntu 24.04**, cubierto en la guía [🌐 Instalación de Isaac Sim 6.1.0](docs/isaac_sim/isaac-sim-ubuntu24/isaac-sim-6.1.0.md).

---

## 📁 Contenido

Este repositorio está organizado en guías independientes. Cada una cubre un aspecto específico del ecosistema ROS 2.

### 💻 Preparación del sistema (Host)

Antes de instalar ROS 2, tu equipo debe contar con Ubuntu funcionando como sistema operativo. Si partes de un PC con Windows, esta guía te lleva paso a paso por la configuración de un arranque múltiple sin perder tu instalación actual:

| Guía | Descripción | Plataforma |
|---|---|---|
| [🖥️ Triple Boot: Windows 11 + Ubuntu 24.04 + Ubuntu 22.04](docs/installation_linux/installationlinux.md) | Configuración de arranque múltiple preservando Windows Boot Manager, en hardware AMD Ryzen 7 5700G / NVMe | PC / Laptop (amd64) |

### 🛠️ NVIDIA SDK Manager

| Guía | Descripción | Plataforma |
|---|---|---|
| [🟢 SDK Manager NVIDIA — Jetson Orin NX](docs/sdk-manager/jetson-orin-sdk-manager.md) | Uso del SDK Manager de NVIDIA para flashear y configurar la Jetson Orin NX | Jetson Orin NX |

### 🔧 Instalación

| Guía | Descripción | Plataforma |
|---|---|---|
| [📥 Instalación ROS2 Humble Hawksbill en Ubuntu 22.04 (paquetes deb)](docs/installation/ROS2_Humble_Instalacion.md) | Método oficial y recomendado usando `apt`. Incluye instalación Desktop, Base y herramientas de desarrollo | Ubuntu 22.04 |

<!--
| [🟢 Instalación en Jetson Orin NX (JetPack 6)](docs/installation/jetson-orin-nx.md) | Instalación vía imagen SD Card y SDK Manager para la Jetson Orin NX 16 GB | Jetson Orin NX |
-->

### 🧪 Verificación y primeros pasos

| Guía | Descripción |
|---|---|
| [✅ Verificar la instalación](docs/verification/talker-listener.md) | Ejemplo talker-listener en C++ y Python para validar la instalación |
<!--
| [🔍 Solución de problemas](docs/troubleshooting/common-issues.md) | Errores frecuentes y cómo resolverlos |
-->

### ⚙️ Configuración del Espacio de trabajo (Workspace)

| Guía | Descripción |
|---|---|
| [🗂️ Creación del workspace `robot_ws`](docs/workspaces/robot-ws.md) | Estructura, compilación con `colcon` y configuración en `.bashrc` |
<!--
| [📡 Configuración de RMW](docs/configuration/rmw-setup.md) | Cambiar el middleware (Fast DDS, Cyclone DDS, Zenoh) |
-->

### 🐢 TurtleBot3

| Guía | Descripción |
|---|---|
| [🤖 TurtleBot3 con ROS 2 Humble](docs/turtlebot3/turtlebot3-humble.md) | Instalación, configuración y simulación en Gazebo con TurtleBot3 Waffle Pi |

### 🌐 NVIDIA Isaac Sim

| Guía | Descripción | Plataforma |
|---|---|---|
| [🌐 Instalación de Isaac Sim 6.1.0](docs/isaac_sim/isaac-sim-ubuntu24/isaac-sim-6.1.0.md) | Primer paso: instalación, verificación de compatibilidad y primer arranque de Isaac Sim | Ubuntu 24.04 (workstation con GPU NVIDIA RTX) |

---

## 📋 Requisitos previos

Antes de comenzar asegúrese de cumplir con los siguientes requisitos:

- **Sistema operativo:** Ubuntu 22.04 LTS (Jammy Jellyfish) — 64 bits
- **Arquitectura:** `amd64` (PC/laptop) o `arm64` (Jetson, Raspberry Pi)
- **Acceso a internet** para descargar paquetes
- **Permisos `sudo`** en el sistema
- **Espacio en disco:** mínimo 5 GB libres (Desktop install)

> ⚠️ ROS 2 Humble **no** es compatible con Ubuntu 20.04 via paquetes `apt`. Para Ubuntu 20.04 se debe instalar desde fuente o usar Docker.

---

## 🔗 Referencias oficiales

- 📖 [Documentación oficial ROS 2 Humble](https://docs.ros.org/en/humble/)
- 📦 [Página de instalación Ubuntu (deb)](https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debs.html)
- 🐛 [Repositorio ros2/ros2 en GitHub](https://github.com/ros2/ros2)
- 💬 [Foro de la comunidad ROS](https://discourse.ros.org/)
- 🆘 [ROS Answers (Q&A)](https://answers.ros.org/)
- 📊 [Estado de los paquetes amd64](http://repo.ros2.org/status_page/ros_humble_default.html)
- 📊 [Estado de los paquetes arm64](http://repo.ros2.org/status_page/ros_humble_ujv8.html)

---

## 🗂️ Contenido Legado — ROS 1

> ⚠️ Esta sección documenta instalaciones sobre hardware y distribuciones de ROS **anteriores** al stack principal de este repositorio (ROS 2 Humble / Ubuntu 22.04). Se conserva como referencia para plataformas que no soportan ROS 2 de forma nativa.

| Guía | Distribución | Plataforma |
|---|---|---|
| [💾 Grabado de imagen SD con Balena Etcher en Jetson Nano](docs/ros1/jetson-nano-sd-balena-etcher.md) | — | NVIDIA Jetson Nano Developer Kit |
| [🐢 Instalación ROS Melodic Morenia en Jetson Nano Developer Kit](docs/ros1/jetson-nano-ros-melodic.md) | **ROS 1 Melodic** (EOL 2023) | NVIDIA Jetson Nano Developer Kit (JetPack 4.x / Ubuntu 18.04) |

---

## 📄 Licencia

Este repositorio está bajo la licencia **Apache 2.0**. Consulta el archivo [LICENSE](LICENSE) para más detalles.

La documentación de ROS 2 referenciada es propiedad de [Open Robotics](https://www.openrobotics.org/) bajo licencia Creative Commons Attribution 4.0.

---

<div align="center">

Hecho por **Julián René Cháux Cedeño** para la comunidad ROS hispanohablante

</div>
