<div align="center">

# 🐕 Unitree Go1 en Gazebo con ROS 2 Humble
### Simulación del perro robot y control de la marcha por `/cmd_vel`

![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20LTS-orange?style=flat-square&logo=ubuntu)
![ROS2](https://img.shields.io/badge/ROS2-Humble%20Hawksbill-blue?style=flat-square&logo=ros)
![Unitree](https://img.shields.io/badge/Unitree-Go1-black?style=flat-square)
![Gazebo](https://img.shields.io/badge/Simulador-Gazebo%2011-lightgrey?style=flat-square)

[← Volver al README principal](../../README.md)

</div>

---

## Tabla de contenidos

- [Qué vamos a lograr](#qué-vamos-a-lograr)
- [Requisitos](#requisitos)
- [Instalar las dependencias](#instalar-las-dependencias)
- [Clonar y compilar los paquetes](#clonar-y-compilar-los-paquetes)
- [Lanzar la simulación](#lanzar-la-simulación)
- [Poner a caminar al Go1 por tópicos](#poner-a-caminar-al-go1-por-tópicos)
- [Tópicos disponibles](#tópicos-disponibles)
- [Solución de problemas comunes](#solución-de-problemas-comunes)
- [Referencias](#referencias)

---

## Qué vamos a lograr

Levantar al **Unitree Go1** en Gazebo 11, ponerlo de pie y hacerlo caminar publicando mensajes `geometry_msgs/msg/Twist` en `/cmd_vel`, igual que con el [TurtleBot3](../turtlebot3/turtlebot3-humble.md).

A diferencia del TurtleBot3, un robot de patas **no** se mueve solo con un plugin de velocidad: alguien tiene que calcular el movimiento de las 12 articulaciones. En este repositorio esa tarea la hace el nodo `junior_ctrl` del paquete `unitree_guide2` (el controlador *Unitree Guide* portado a ROS 2), que traduce `/cmd_vel` en la marcha del robot.

Usaremos el repositorio de la comunidad [Atharva-05/unitree_ros2_sim](https://github.com/Atharva-05/unitree_ros2_sim), que su autor probó con **ROS 2 Humble en Ubuntu 22.04** y **Gazebo 11**.

> ℹ️ **Sobre los repositorios oficiales de Unitree:** `unitreerobotics/unitree_ros` es un paquete de **ROS 1** y no se puede usar directamente en Humble. Por eso se usa este port a ROS 2.

---

## Requisitos

| Requisito | Detalle |
|---|---|
| 💻 Sistema operativo | Ubuntu **22.04 LTS** (Jammy Jellyfish) |
| 🤖 ROS 2 instalado | [ROS 2 Humble Hawksbill](../installation/ubuntu-deb.md) |
| 📁 Workspace activo | [robot_ws creado y compilado](../workspaces/robot-ws.md) |
| 🎮 Simulador | Gazebo 11 (incluido con `ros-humble-desktop`) |

---

## Instalar las dependencias

Dependencias de ROS 2 (navegación, control y plugins de Gazebo):

```bash
sudo apt update
sudo apt install -y \
  ros-humble-navigation2 ros-humble-nav2-bringup \
  ros-humble-ros2-control ros-humble-ros2-controllers \
  ros-humble-gazebo-ros2-control ros-humble-gazebo-ros-pkgs \
  ros-humble-xacro ros-humble-joint-state-publisher
```

El repositorio también requiere **LCM** (*Lightweight Communications and Marshalling*), que debe compilarse desde código fuente:

```bash
sudo apt install -y build-essential cmake libglib2.0-dev git

cd ~
git clone https://github.com/lcm-proj/lcm.git
cd lcm
mkdir build && cd build
cmake ..
make -j$(nproc)
sudo make install
sudo ldconfig
```

---

## Clonar y compilar los paquetes

```bash
cd ~/workspaces/robot_ws/src
git clone https://github.com/Atharva-05/unitree_ros2_sim.git
```

Instala las dependencias que falten y compila:

```bash
cd ~/workspaces/robot_ws
rosdep install --from-paths src --ignore-src -r -y

colcon build --symlink-install
source install/setup.bash
```

El repositorio contiene estos paquetes:

| Paquete | Función |
|---|---|
| `go1_description` | Modelo URDF del Go1 |
| `go1_gazebo` | Launch files y mundo para Gazebo |
| `go1_navigation` | Interfaz con Nav2 |
| `ros2_unitree_legged_controller` | Controladores de las articulaciones |
| `ros2_unitree_legged_msgs` | Mensajes personalizados |
| `unitree_guide2` | Controlador de la marcha (`junior_ctrl`) |

---

## Lanzar la simulación

Necesitas **dos terminales** (ambas con `source ~/workspaces/robot_ws/install/setup.bash`).

### Terminal 1 — Gazebo y controladores

```bash
ros2 launch go1_gazebo spawn_go1.launch.py
```

Esto abre Gazebo, coloca al robot y carga los controladores de cada articulación. **Espera a ver en la terminal que el último controlador (`RL_calf_controller`) cargó correctamente** antes de continuar.

### Terminal 2 — Controlador de la marcha

```bash
ros2 run unitree_guide2 junior_ctrl
```

Con esta terminal en primer plano, presiona las teclas para cambiar de modo:

| Tecla | Modo | Efecto |
|---|---|---|
| `2` | `fixed_stand` | El robot se levanta y queda de pie |
| `5` | `move_base` | El robot empieza a aceptar comandos de velocidad por `/cmd_vel` |

> ⚠️ El orden importa: primero `2` (de pie) y luego `5`. Si publicas en `/cmd_vel` antes de entrar en `move_base`, el robot no reaccionará.

---

## Poner a caminar al Go1 por tópicos

Con el robot en modo `move_base`, abre una **tercera terminal** y publica velocidades. Para un robot de patas conviene publicar de forma **continua** (`-r 10`, 10 Hz) en lugar de una sola vez:

### Avanzar

```bash
ros2 topic pub -r 10 /cmd_vel geometry_msgs/msg/Twist "{linear: {x: 0.3}, angular: {z: 0.0}}"
```

### Girar sobre su eje

```bash
ros2 topic pub -r 10 /cmd_vel geometry_msgs/msg/Twist "{linear: {x: 0.0}, angular: {z: 0.5}}"
```

### Caminar hacia un lado

```bash
ros2 topic pub -r 10 /cmd_vel geometry_msgs/msg/Twist "{linear: {y: 0.2}}"
```

### Detener

Presiona `CTRL+C` en la terminal que publica y envía un comando en cero:

```bash
ros2 topic pub --once /cmd_vel geometry_msgs/msg/Twist "{linear: {x: 0.0}, angular: {z: 0.0}}"
```

| Campo | Significado |
|---|---|
| `linear.x` | Avance (m/s). Negativo = reversa |
| `linear.y` | Desplazamiento lateral (m/s) — los cuadrúpedos pueden caminar de lado |
| `angular.z` | Giro (rad/s). Positivo = izquierda |

> 💡 Empieza con velocidades bajas (`x: 0.2`). Con valores altos la marcha simulada puede volverse inestable.

También puedes reutilizar el script de la guía [🕹️ Mover TurtleBot3 publicando en `/cmd_vel`](../examples/python-cmd-vel-turtlebot3.md): el código es el mismo, solo cambian las velocidades.

---

## Tópicos disponibles

| Tópico | Tipo | Dirección | Descripción |
|---|---|---|---|
| `/cmd_vel` | `geometry_msgs/msg/Twist` | Suscrito | Comando de velocidad (modo `move_base`) |
| `/odom` | `nav_msgs/msg/Odometry` | Publicado | Odometría (ground truth del simulador) |
| `/scan` | `sensor_msgs/msg/LaserScan` | Publicado | LiDAR 2D simulado |
| `/tf` | `tf2_msgs/msg/TFMessage` | Publicado | `odom` → `base_link` → `base_footprint` |

Verifica que estén activos:

```bash
ros2 topic list
ros2 topic info /cmd_vel
ros2 topic echo /odom --once
```

---

## Solución de problemas comunes

### `junior_ctrl` falla al iniciar

Lo lanzaste demasiado pronto. Espera a que la Terminal 1 muestre que `RL_calf_controller` terminó de cargar y vuelve a ejecutarlo.

### El robot no responde a `/cmd_vel`

1. Confirma que presionaste `2` y luego `5` en la terminal de `junior_ctrl`.
2. Verifica que hay un suscriptor: `ros2 topic info /cmd_vel` (`Subscription count` ≥ 1).
3. Publica con `-r 10` en vez de `--once`.

### Error de compilación por `lcm`

Confirma que LCM quedó instalado (`sudo ldconfig` después de `make install`) y recompila:

```bash
colcon build --symlink-install --cmake-clean-cache
```

### Procesos de Gazebo huérfanos

Si Gazebo no abre o se comporta raro tras un cierre brusco:

```bash
killall -9 gzserver gzclient
```

---

## Referencias

- [Atharva-05/unitree_ros2_sim — Go1 en ROS 2 Humble + Gazebo 11](https://github.com/Atharva-05/unitree_ros2_sim)
- [unitreerobotics/unitree_ros — paquetes oficiales (ROS 1)](https://github.com/unitreerobotics/unitree_ros)
- [LCM — Lightweight Communications and Marshalling](https://lcm-proj.github.io/lcm/)
- [Guía TurtleBot3 con ROS 2 Humble](../turtlebot3/turtlebot3-humble.md)

---

*Basado en el README de `unitree_ros2_sim` (Ubuntu 22.04 · ROS 2 Humble · Gazebo 11). Los pasos de instalación de dependencias (apt, LCM) y compilación no vienen en ese README y deben validarse en tu equipo.*

---

<div align="center">

[← Volver a Mover TurtleBot3 publicando en /cmd_vel](../examples/python-cmd-vel-turtlebot3.md) &nbsp;|&nbsp; [Unitree G1 en Gazebo →](unitree-g1-gazebo.md)

</div>
