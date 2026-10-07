<div align="center">

# 🤖 Verificación de la Instalación de ROS2 Humble
### Ejemplo Publicador (Talker) - Suscriptor (Listener)

![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20LTS-orange?style=flat-square&logo=ubuntu)
![ROS2](https://img.shields.io/badge/ROS2-Humble%20Hawksbill-blue?style=flat-square&logo=ros)
![Arch](https://img.shields.io/badge/Arch-amd64%20%7C%20arm64-lightgrey?style=flat-square)

[← Volver al README principal](../../README.md)

</div>

---

## Verificar la instalación

### Ejemplo Talker-Listener

Este ejemplo verifica que tanto la API de **C++** como la de **Python** funcionen correctamente.

**Terminal 1** — Inicia el publicador (talker) en C++:

```bash
source /opt/ros/humble/setup.bash
ros2 run demo_nodes_cpp talker
```

Deberías ver una salida similar a:

```
[INFO] [talker]: Publishing: 'Hello World: 1'
[INFO] [talker]: Publishing: 'Hello World: 2'
[INFO] [talker]: Publishing: 'Hello World: 3'
```

**Terminal 2** — Inicia el suscriptor (listener) en Python:

```bash
source /opt/ros/humble/setup.bash
ros2 run demo_nodes_py listener
```

Deberías ver:

```
[INFO] [listener]: I heard: [Hello World: 1]
[INFO] [listener]: I heard: [Hello World: 2]
[INFO] [listener]: I heard: [Hello World: 3]
```

Si ambos terminales muestran los mensajes correctamente, **¡la instalación es exitosa!** 🎉

> ⚠️ El ejemplo `demo_nodes_cpp` y `demo_nodes_py` solo está disponible en la instalación **Desktop**. Si instalaste `ros-humble-ros-base`, puedes verificar ejecutando `ros2 --help`.

---

<div align="center">

[← Volver 📥 Instalación ROS2 Humble Hawksbill en Ubuntu 22.04 (paquetes deb)](../../docs/installation/ubuntu-deb.md) &nbsp;|&nbsp; [Creación del workspace `robot_ws` →](../../docs/workspaces/robot-ws.md)


</div>
