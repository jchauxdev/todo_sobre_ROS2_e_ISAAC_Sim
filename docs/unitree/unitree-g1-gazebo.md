<div align="center">

# 🦾 Unitree G1 en Gazebo con ROS 2 Humble
### Humanoide de pie y control de articulaciones por tópicos

![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20LTS-orange?style=flat-square&logo=ubuntu)
![ROS2](https://img.shields.io/badge/ROS2-Humble%20Hawksbill-blue?style=flat-square&logo=ros)
![Unitree](https://img.shields.io/badge/Unitree-G1-black?style=flat-square)
![Gazebo](https://img.shields.io/badge/Simulador-Gazebo%2011-lightgrey?style=flat-square)

[← Volver al README principal](../../README.md)

</div>

---

## Tabla de contenidos

- [Alcance y limitaciones](#alcance-y-limitaciones)
- [Requisitos](#requisitos)
- [Crear el paquete `g1_gazebo`](#crear-el-paquete-g1_gazebo)
- [Descargar el modelo oficial del G1](#descargar-el-modelo-oficial-del-g1)
- [Preparar el URDF para ros2_control](#preparar-el-urdf-para-ros2_control)
- [Launch file](#launch-file)
- [Compilar y lanzar](#compilar-y-lanzar)
- [Mover el G1 por tópicos](#mover-el-g1-por-tópicos)
- [¿Y para que camine?](#y-para-que-camine)
- [Solución de problemas comunes](#solución-de-problemas-comunes)
- [Referencias](#referencias)

---

## Alcance y limitaciones

> ⚠️ **Léelo antes de empezar.** No existe (hasta donde se pudo verificar) un paquete público que haga **caminar** al Unitree G1 en Gazebo con ROS 2 Humble mediante `/cmd_vel`. Los paquetes tipo CHAMP funcionan para cuadrúpedos (como el [Go1](unitree-go1-gazebo.md)), no para humanoides, y `unitree_ros` oficial es de ROS 1.

Esta guía logra lo que sí es realista y reproducible:

| Objetivo | Estado |
|---|---|
| Cargar el modelo oficial del G1 en Gazebo 11 | ✅ |
| Mantenerlo de pie (base fija en el aire, sin caerse) | ✅ |
| Mover cualquiera de sus articulaciones publicando en un tópico | ✅ |
| Caminar con `/cmd_vel` | ❌ Requiere una política de locomoción (ver [¿Y para que camine?](#y-para-que-camine)) |

El resultado es la base sobre la que se conecta después un controlador de marcha.

> ℹ️ Los comandos y el código de esta guía no fueron ejecutados en un equipo con Gazebo al redactarla. Si algo falla, revisa la sección de [solución de problemas](#solución-de-problemas-comunes).

---

## Requisitos

| Requisito | Detalle |
|---|---|
| 💻 Sistema operativo | Ubuntu **22.04 LTS** |
| 🤖 ROS 2 instalado | [ROS 2 Humble Hawksbill](../installation/ubuntu-deb.md) |
| 📁 Workspace activo | [robot_ws creado y compilado](../workspaces/robot-ws.md) |
| 🎮 Simulador | Gazebo 11 |

```bash
sudo apt update
sudo apt install -y \
  ros-humble-gazebo-ros-pkgs ros-humble-gazebo-ros2-control \
  ros-humble-ros2-control ros-humble-ros2-controllers \
  ros-humble-robot-state-publisher ros-humble-xacro
```

---

## Crear el paquete `g1_gazebo`

Un solo paquete contendrá el modelo, el script de preparación y el launch:

```bash
cd ~/workspaces/robot_ws/src
ros2 pkg create --build-type ament_cmake g1_gazebo
mkdir -p g1_gazebo/{urdf,launch,config,scripts}
```

---

## Descargar el modelo oficial del G1

Unitree publica el modelo del G1 en el repositorio `unitree_ros`. Solo necesitamos la carpeta `robots/g1_description` (URDF + mallas):

```bash
cd ~
git clone --depth 1 https://github.com/unitreerobotics/unitree_ros.git
ls unitree_ros/robots/g1_description
```

Revisa el `README.md` de esa carpeta: indica qué variantes existen (por ejemplo `g1_29dof`, `g1_23dof`, `g1_29dof_mode_18`) y cuál está vigente. Elige un archivo `.urdf` y cópialo junto con las mallas dentro del paquete:

```bash
cd ~/workspaces/robot_ws/src/g1_gazebo
cp ~/unitree_ros/robots/g1_description/<archivo_elegido>.urdf urdf/g1_original.urdf
cp -r ~/unitree_ros/robots/g1_description/meshes .
```

> Reemplaza `<archivo_elegido>` por el nombre real. Las rutas de las mallas dentro del URDF suelen tener la forma `package://g1_description/meshes/...`; el script del siguiente paso las reescribe para que apunten a este paquete.

---

## Preparar el URDF para ros2_control

El URDF original no trae interfaces de `ros2_control` ni está anclado al mundo. En vez de editar a mano 29 articulaciones, este script lo hace automáticamente. Crea `scripts/prepare_g1.py`:

```python
#!/usr/bin/env python3
"""Prepara el URDF del G1 para Gazebo + ros2_control.

- Reescribe las rutas package://g1_description -> package://g1_gazebo
- Ancla el link raíz al mundo (el robot queda de pie, suspendido)
- Agrega una interfaz de posición ros2_control por cada articulación móvil
- Genera config/g1_controllers.yaml
"""
import sys
import xml.etree.ElementTree as ET

SRC, DST_URDF, DST_YAML = sys.argv[1], sys.argv[2], sys.argv[3]
HEIGHT = float(sys.argv[4]) if len(sys.argv) > 4 else 0.8

tree = ET.parse(SRC)
robot = tree.getroot()

# 1. Rutas de mallas
for el in robot.iter():
    for k, v in el.attrib.items():
        if 'package://g1_description' in v:
            el.set(k, v.replace('package://g1_description', 'package://g1_gazebo'))

# 2. Link raíz = el que nunca es hijo de una articulación
children = {j.find('child').get('link') for j in robot.findall('joint')}
root_link = next(l.get('name') for l in robot.findall('link')
                 if l.get('name') not in children)

ET.SubElement(robot, 'link', name='world')
anchor = ET.SubElement(robot, 'joint', name='world_anchor', type='fixed')
ET.SubElement(anchor, 'parent', link='world')
ET.SubElement(anchor, 'child', link=root_link)
ET.SubElement(anchor, 'origin', xyz=f'0 0 {HEIGHT}', rpy='0 0 0')

# 3. ros2_control sobre las articulaciones móviles
moving = [j for j in robot.findall('joint')
          if j.get('type') in ('revolute', 'continuous', 'prismatic')]

rc = ET.SubElement(robot, 'ros2_control', name='GazeboSystem', type='system')
hw = ET.SubElement(rc, 'hardware')
ET.SubElement(hw, 'plugin').text = 'gazebo_ros2_control/GazeboSystem'
for j in moving:
    jt = ET.SubElement(rc, 'joint', name=j.get('name'))
    ET.SubElement(jt, 'command_interface', name='position')
    ET.SubElement(jt, 'state_interface', name='position')
    ET.SubElement(jt, 'state_interface', name='velocity')

gz = ET.SubElement(robot, 'gazebo')
plug = ET.SubElement(gz, 'plugin', name='gazebo_ros2_control',
                     filename='libgazebo_ros2_control.so')
ET.SubElement(plug, 'parameters').text = 'CONTROLLERS_YAML'

ET.indent(tree)
tree.write(DST_URDF, encoding='utf-8', xml_declaration=True)

# 4. Archivo de controladores
names = [j.get('name') for j in moving]
with open(DST_YAML, 'w') as f:
    f.write('controller_manager:\n  ros__parameters:\n    update_rate: 100\n')
    f.write('    joint_state_broadcaster:\n')
    f.write('      type: joint_state_broadcaster/JointStateBroadcaster\n')
    f.write('    position_controller:\n')
    f.write('      type: forward_command_controller/ForwardCommandController\n\n')
    f.write('position_controller:\n  ros__parameters:\n    joints:\n')
    for n in names:
        f.write(f'      - {n}\n')
    f.write('    interface_name: position\n')

print(f'Link raíz: {root_link} | articulaciones móviles: {len(names)}')
```

Ejecútalo:

```bash
cd ~/workspaces/robot_ws/src/g1_gazebo
python3 scripts/prepare_g1.py urdf/g1_original.urdf urdf/g1_ros2control.urdf config/g1_controllers.yaml 0.8
```

Debe imprimir el link raíz (normalmente `pelvis`) y el número de articulaciones (29 para la variante `29dof`). Abre `config/g1_controllers.yaml`: el **orden de la lista `joints`** es el orden en que deberás enviar los valores en el tópico.

> El valor `CONTROLLERS_YAML` dentro del URDF generado se sustituye por la ruta real en el launch file (siguiente sección).

---

## Launch file

Crea `launch/g1_gazebo.launch.py`:

```python
import os

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import ExecuteProcess, IncludeLaunchDescription, RegisterEventHandler
from launch.event_handlers import OnProcessExit
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch_ros.actions import Node


def generate_launch_description():
    pkg = get_package_share_directory('g1_gazebo')
    controllers = os.path.join(pkg, 'config', 'g1_controllers.yaml')

    with open(os.path.join(pkg, 'urdf', 'g1_ros2control.urdf')) as f:
        robot_description = f.read().replace('CONTROLLERS_YAML', controllers)

    gazebo = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(os.path.join(
            get_package_share_directory('gazebo_ros'), 'launch', 'gazebo.launch.py')))

    rsp = Node(package='robot_state_publisher', executable='robot_state_publisher',
               parameters=[{'robot_description': robot_description,
                            'use_sim_time': True}])

    spawn = Node(package='gazebo_ros', executable='spawn_entity.py',
                 arguments=['-topic', 'robot_description', '-entity', 'g1'],
                 output='screen')

    load_jsb = ExecuteProcess(
        cmd=['ros2', 'control', 'load_controller', '--set-state', 'active',
             'joint_state_broadcaster'], output='screen')
    load_pos = ExecuteProcess(
        cmd=['ros2', 'control', 'load_controller', '--set-state', 'active',
             'position_controller'], output='screen')

    return LaunchDescription([
        gazebo, rsp, spawn,
        RegisterEventHandler(OnProcessExit(target_action=spawn, on_exit=[load_jsb])),
        RegisterEventHandler(OnProcessExit(target_action=load_jsb, on_exit=[load_pos])),
    ])
```

Y registra las carpetas en el `CMakeLists.txt` del paquete, antes de `ament_package()`:

```cmake
install(DIRECTORY urdf launch config meshes
  DESTINATION share/${PROJECT_NAME})
```

---

## Compilar y lanzar

```bash
cd ~/workspaces/robot_ws
colcon build --packages-select g1_gazebo
source install/setup.bash

ros2 launch g1_gazebo g1_gazebo.launch.py
```

Deberías ver al G1 suspendido en Gazebo. Verifica los controladores en otra terminal:

```bash
ros2 control list_controllers
```

```
joint_state_broadcaster ... active
position_controller     ... active
```

---

## Mover el G1 por tópicos

El `ForwardCommandController` se suscribe a `/position_controller/commands` (`std_msgs/msg/Float64MultiArray`) y espera **un valor en radianes por articulación, en el orden de `g1_controllers.yaml`**.

Mira primero las posiciones actuales y los nombres:

```bash
ros2 topic echo /joint_states --once
```

Para evitar escribir decenas de números a mano, usa un script que parta de la pose actual y mueva solo una articulación. Crea `scripts/move_joint.py`:

```python
#!/usr/bin/env python3
"""Mueve una articulación del G1 de forma senoidal. Uso: move_joint.py <nombre_articulacion>"""
import math
import sys

import rclpy
from rclpy.node import Node
from sensor_msgs.msg import JointState
from std_msgs.msg import Float64MultiArray


class MoveJoint(Node):

    def __init__(self, joint):
        super().__init__('move_g1_joint')
        self.joint = joint
        self.order = []
        self.pose = None
        self.t = 0.0
        self.create_subscription(JointState, '/joint_states', self.on_state, 10)
        self.pub = self.create_publisher(Float64MultiArray, '/position_controller/commands', 10)
        self.create_timer(0.02, self.tick)

    def on_state(self, msg):
        if self.pose is None:
            self.pose = dict(zip(msg.name, msg.position))
            self.order = list(msg.name)
            self.get_logger().info(f'Articulaciones: {self.order}')

    def tick(self):
        if self.pose is None:
            return
        self.t += 0.02
        target = dict(self.pose)
        target[self.joint] += 0.5 * math.sin(self.t)
        self.pub.publish(Float64MultiArray(data=[target[n] for n in self.order]))


def main():
    rclpy.init()
    rclpy.spin(MoveJoint(sys.argv[1]))


if __name__ == '__main__':
    main()
```

> ⚠️ Este script asume que el orden de `/joint_states` coincide con el de `g1_controllers.yaml`. Ambos salen del mismo URDF y suelen coincidir, pero compáralos si el movimiento sale en la articulación equivocada.

Ejecútalo con el nombre de una articulación que aparezca en `/joint_states` (por ejemplo, un hombro o un codo):

```bash
python3 ~/workspaces/robot_ws/src/g1_gazebo/scripts/move_joint.py <nombre_articulacion>
```

También puedes publicar una pose completa a mano, con un `0.0` por articulación (pose neutra). Para la variante de 29 articulaciones:

```bash
ros2 topic pub --once /position_controller/commands std_msgs/msg/Float64MultiArray \
  "{data: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]}"
```

> Si tu variante tiene un número distinto de articulaciones (p. ej. 23), ajusta la cantidad de valores. El controlador rechaza mensajes con tamaño incorrecto.

---

## ¿Y para que camine?

Un humanoide bípedo es inestable: no basta con enviar una velocidad. Hace falta un **controlador de locomoción** que mantenga el equilibrio, normalmente una **política de aprendizaje por refuerzo (RL)** entrenada en simulación. Las opciones realistas son:

| Opción | Descripción |
|---|---|
| **Políticas de Unitree + MuJoCo** | Unitree publica código de simulación (`unitree_mujoco`) y entrenamiento RL para sus robots. Es la vía oficial para ver caminar al G1 en simulación. |
| **NVIDIA Isaac Sim / Isaac Lab** | Soporta el G1 con políticas RL y bridge a ROS 2. Encaja con la guía de [🌐 Isaac Sim](../isaac_sim/isaac-sim-ubuntu24/isaac-sim-6.1.0.md) de este repositorio. |
| **Política propia sobre esta base** | Un nodo que lea `/joint_states` + IMU, ejecute la política (ONNX/TorchScript) y publique en `/position_controller/commands`. Es el siguiente paso natural, pero exige cambiar la base fija por un robot libre con IMU y control PD por torque. |

Para **ver caminar a un robot en Gazebo hoy**, lo más directo es el perro [Go1](unitree-go1-gazebo.md), que sí responde a `/cmd_vel`.

---

## Solución de problemas comunes

### Gazebo abre pero el robot no aparece o aparece sin mallas

Las rutas de las mallas no se resolvieron. Verifica que existan y que el URDF generado apunte a `g1_gazebo`:

```bash
ls ~/workspaces/robot_ws/install/g1_gazebo/share/g1_gazebo/meshes | head
grep -m3 "package://" ~/workspaces/robot_ws/src/g1_gazebo/urdf/g1_ros2control.urdf
```

Si el URDF original usaba otro prefijo (distinto de `package://g1_description`), ajusta la cadena en `prepare_g1.py`.

### `ros2 control list_controllers` no muestra nada

El plugin no cargó. Revisa la terminal del launch: debe aparecer `gazebo_ros2_control` y `controller_manager`. Confirma que `ros-humble-gazebo-ros2-control` está instalado y que el YAML se sustituyó bien en `robot_description`.

### El robot se hunde, tiembla o sale disparado

Un modelo con tantas articulaciones y colisiones complejas puede ser inestable. Prueba con otra altura de anclaje (último argumento de `prepare_g1.py`) y reduce la amplitud del movimiento (`0.5` en `move_joint.py`).

### El tópico `/position_controller/commands` no mueve nada

```bash
ros2 topic info /position_controller/commands
ros2 control list_controllers
```

Si el controlador no está `active`, cárgalo manualmente con `ros2 control load_controller --set-state active position_controller`.

---

## Referencias

- [unitreerobotics/unitree_ros — `robots/g1_description`](https://github.com/unitreerobotics/unitree_ros/tree/master/robots/g1_description)
- [gazebo_ros2_control — documentación](https://control.ros.org/humble/doc/gazebo_ros2_control/doc/index.html)
- [ForwardCommandController — ros2_controllers](https://control.ros.org/humble/doc/ros2_controllers/forward_command_controller/doc/userdoc.html)
- [Guía Unitree Go1 en Gazebo](unitree-go1-gazebo.md)

---

*Redactada para Ubuntu 22.04 · ROS 2 Humble · Gazebo 11 · Noviembre 2026. Código no ejecutado al redactarla: valida en tu equipo y ajusta nombres de archivos y articulaciones según la variante del modelo elegida.*

---

<div align="center">

[← Unitree Go1 en Gazebo](unitree-go1-gazebo.md)

</div>
