<div align="center">

# 🤖 TurtleBot3 con ROS 2 Humble
### Instalación, configuración y simulación en Gazebo

![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20LTS-orange?style=flat-square&logo=ubuntu)
![ROS2](https://img.shields.io/badge/ROS2-Humble%20Hawksbill-blue?style=flat-square&logo=ros)
![TurtleBot3](https://img.shields.io/badge/TurtleBot3-Waffle%20Pi-green?style=flat-square)
![Gazebo](https://img.shields.io/badge/Simulador-Gazebo%2011-lightgrey?style=flat-square)

[← Volver al README principal](../../README.md)

</div>

---

## Tabla de contenidos

- [Requisitos](#requisitos)
- [Instalación de TurtleBot3](#instalación-de-turtlebot3)
- [Configuración del entorno](#configuración-del-entorno)
- [Lanzar la simulación en Gazebo](#lanzar-la-simulación-en-gazebo)
- [Controlar el robot con el teclado](#controlar-el-robot-con-el-teclado)
- [Mover el robot publicando directamente en `/cmd_vel`](#mover-el-robot-publicando-directamente-en-cmd_vel)
- [Visualizar el robot en RViz2](#visualizar-el-robot-en-rviz2)
- [Compilar desde código fuente (recomendado)](#compilar-desde-código-fuente-recomendado)
- [Solución de problemas comunes](#solución-de-problemas-comunes)

---

## Requisitos

| Requisito | Detalle |
|---|---|
| 💻 Sistema operativo | Ubuntu **22.04 LTS** (Jammy Jellyfish) |
| 🤖 ROS 2 instalado | [ROS 2 Humble Hawksbill](../installation/ubuntu-deb.md) |
| 📁 Workspace activo | [robot_ws creado y compilado](../workspace/robot-ws.md) |
| 🎮 Simulador | Gazebo 11 (incluido con `ros-humble-desktop`) |

Verifica que Gazebo está disponible:

```bash
gazebo --version
```

---

## Instalación de TurtleBot3

Instala los paquetes oficiales de TurtleBot3 para ROS 2 Humble desde el repositorio de apt:

```bash
# Paquetes principales del robot
sudo apt install ros-humble-turtlebot3 -y

# Paquetes de simulación (mundos y modelos para Gazebo)
sudo apt install ros-humble-turtlebot3-simulations -y
```

Verifica que los paquetes quedaron instalados:

```bash
ros2 pkg list | grep turtlebot3
```

Deberías ver una lista como esta:

```
turtlebot3_bringup
turtlebot3_cartographer
turtlebot3_description
turtlebot3_example
turtlebot3_gazebo
turtlebot3_navigation2
turtlebot3_node
turtlebot3_teleop
```

---

## Configuración del entorno

Agrega las variables de entorno necesarias al `~/.bashrc`:

```bash
# Modelo del robot (opciones: burger, waffle, waffle_pi)
echo "export TURTLEBOT3_MODEL=waffle_pi" >> ~/.bashrc

# Path de modelos para Gazebo
echo "export GAZEBO_MODEL_PATH=/usr/share/gazebo-11/models:$GAZEBO_MODEL_PATH" >> ~/.bashrc

# Path de modelos de TurtleBot3
echo "export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:/opt/ros/humble/share/turtlebot3_gazebo/models" >> ~/.bashrc

# Aplicar cambios
source ~/.bashrc
```

Verifica que las variables quedaron activas:

```bash
echo $TURTLEBOT3_MODEL
echo $GAZEBO_MODEL_PATH
```

Salida esperada:

```
waffle_pi
/usr/share/gazebo-11/models:/opt/ros/humble/share/turtlebot3_gazebo/models
```

### Modelos disponibles

| Modelo | Descripción |
|---|---|
| `burger` | Robot diferencial pequeño con LiDAR 360° |
| `waffle` | Robot más grande con cámara RGB-D Intel RealSense |
| `waffle_pi` | Igual que waffle pero con cámara Raspberry Pi |

> Para cambiar de modelo, edita la línea `TURTLEBOT3_MODEL` en el `~/.bashrc` y ejecuta `source ~/.bashrc`.

---

## Lanzar la simulación en Gazebo

TurtleBot3 incluye varios mundos preconfigurados. Abre una terminal y ejecuta uno de los siguientes:

### Mundo TurtleBot3 World (por defecto)

```bash
ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py
```

### Mundo vacío

```bash
ros2 launch turtlebot3_gazebo empty_world.launch.py
```

### Mundo House

```bash
ros2 launch turtlebot3_gazebo turtlebot3_house.launch.py
```

### Pasar el mundo explícitamente

Si todos los launch files abren el mismo mundo (bug conocido del paquete apt), pasa el archivo `.world` de forma explícita:

```bash
# TurtleBot3 World
ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py \
  world:=$(ros2 pkg prefix turtlebot3_gazebo)/share/turtlebot3_gazebo/worlds/turtlebot3_world.world

# House
ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py \
  world:=$(ros2 pkg prefix turtlebot3_gazebo)/share/turtlebot3_gazebo/worlds/turtlebot3_house.world

# Mundo vacío
ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py \
  world:=$(ros2 pkg prefix turtlebot3_gazebo)/share/turtlebot3_gazebo/worlds/empty_world.world
```

Ver todos los mundos disponibles:

```bash
ls $(ros2 pkg prefix turtlebot3_gazebo)/share/turtlebot3_gazebo/worlds/
```

---

## Controlar el robot con el teclado

Con la simulación corriendo, abre una **segunda terminal** y ejecuta:

```bash
ros2 run turtlebot3_teleop teleop_keyboard
```

Controles:

```
        w
   a    s    d
        x

w / x : aumentar / reducir velocidad lineal
a / d : aumentar / reducir velocidad angular
s     : detener el robot
CTRL+C: salir
```

---

## Mover el robot publicando directamente en `/cmd_vel`

También puedes mover el robot sin el teleoperador, publicando un único mensaje directamente al tópico `/cmd_vel` desde la terminal:

```bash
ros2 topic pub --once /cmd_vel geometry_msgs/msg/Twist "{linear: {x: 1.0}, angular: {z: 0.5}}"
```

- `--once` envía el mensaje una sola vez (el robot mantiene esa velocidad hasta recibir un nuevo comando).
- `linear.x` controla la velocidad lineal hacia adelante (m/s).
- `angular.z` controla la velocidad angular (rad/s): positivo gira a la izquierda, negativo a la derecha.

Para detener el robot, publica un mensaje con todas las velocidades en cero:

```bash
ros2 topic pub --once /cmd_vel geometry_msgs/msg/Twist "{linear: {x: 0.0}, angular: {z: 0.0}}"
```

> Para una secuencia de movimientos más elaborada (avanzar, girar y detenerse) controlada desde un script en Python, ver la guía [🕹️ Mover TurtleBot3 publicando en `/cmd_vel`](../examples/python-cmd-vel-turtlebot3.md).

---

## Visualizar el robot en RViz2

Con la simulación corriendo, abre una **segunda terminal** y lanza RViz2 con la configuración ya preparada para TurtleBot3:

```bash
ros2 launch turtlebot3_bringup rviz2.launch.py
```

Esto abre RViz2 con los displays típicos ya cargados (modelo del robot, escaneo LiDAR, TF, mapa si hay uno disponible), sin necesidad de configurarlos manualmente.

> Si RViz2 se abre pero no muestra el robot, verifica que el `Fixed Frame` esté configurado como `odom` o `base_link` y que el tópico `/scan` esté publicando datos (`ros2 topic list`).

---

## Compilar desde código fuente (recomendado)

El paquete instalado vía `apt` puede tener bugs (como mundos que no cambian). La solución más estable es compilar desde el repositorio oficial de ROBOTIS:

```bash
cd ~/workspaces/robot_ws/src

# Clonar el repositorio oficial en la rama humble
git clone -b humble https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git
git clone -b humble https://github.com/ROBOTIS-GIT/turtlebot3.git
```

Instala las dependencias y compila:

```bash
cd ~/workspaces/robot_ws/

rosdep install --from-paths src --ignore-src -r -y

colcon build --packages-select turtlebot3_gazebo turtlebot3_description \
  turtlebot3_teleop turtlebot3_bringup

source install/setup.bash
```

Luego lanza normalmente:

```bash
ros2 launch turtlebot3_gazebo turtlebot3_house.launch.py
```

---

## Solución de problemas comunes

### Todos los launch files abren el mismo mundo

**Causa:** el paquete instalado vía `apt` tiene un bug donde los launch files ignoran el argumento `world`.

**Solución 1 — pasar el world explícitamente:**

```bash
ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py \
  world:=$(ros2 pkg prefix turtlebot3_gazebo)/share/turtlebot3_gazebo/worlds/turtlebot3_house.world
```

**Solución 2 — compilar desde código fuente** (ver sección anterior).

---

### Gazebo abre pero el robot no aparece en la escena

**Causa:** `GAZEBO_MODEL_PATH` no incluye los modelos de TurtleBot3.

Verifica el path:

```bash
ls /opt/ros/humble/share/turtlebot3_gazebo/models
```

Si el directorio existe pero el robot no carga, agrega el path manualmente y recarga:

```bash
export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:/opt/ros/humble/share/turtlebot3_gazebo/models
source ~/.bashrc
```

Si el directorio no existe, reinstala el paquete:

```bash
sudo apt install ros-humble-turtlebot3-simulations --reinstall
```

---

### Error: `TURTLEBOT3_MODEL is not set`

La variable de entorno no está cargada. Ejecuta:

```bash
export TURTLEBOT3_MODEL=waffle_pi
```

Y verifica que la línea `export TURTLEBOT3_MODEL=waffle_pi` existe en tu `~/.bashrc`:

```bash
grep TURTLEBOT3 ~/.bashrc
```

---

### Gazebo se cierra inesperadamente al lanzar

Puede ser un problema de recursos gráficos. Intenta lanzar en modo sin renderizado o revisa los logs:

```bash
# Ver el log de Gazebo
cat ~/.gazebo/gzserver.log | tail -30
```

Si usas una máquina virtual, asegúrate de tener **aceleración 3D habilitada** en la configuración de la VM.

---

### `ros2 run turtlebot3_teleop teleop_keyboard` no mueve el robot

Verifica que el nodo del robot está activo:

```bash
ros2 node list
ros2 topic list | grep cmd_vel
```

El tópico `/cmd_vel` debe aparecer en la lista. Si no está, la simulación no levantó correctamente — reinicia Gazebo.

---

## Referencias

- [Documentación oficial TurtleBot3](https://emanual.robotis.com/docs/en/platform/turtlebot3/overview/)
- [Repositorio ROBOTIS — turtlebot3](https://github.com/ROBOTIS-GIT/turtlebot3)
- [Repositorio ROBOTIS — turtlebot3_simulations](https://github.com/ROBOTIS-GIT/turtlebot3_simulations)
- [ROS 2 Humble — guía de navegación con TurtleBot3](https://emanual.robotis.com/docs/en/platform/turtlebot3/ros2_setup/)

---

*Probado en Ubuntu 22.04 LTS · ROS 2 Humble Hawksbill · Gazebo 11 · Septiembre 2026*

---

<div align="center">

[← Volver a Creación del Workspace](../workspace/robot-ws.md) &nbsp;|&nbsp; [Publicador y Suscriptor en Python →](../examples/python-pub-sub.md)

</div>
