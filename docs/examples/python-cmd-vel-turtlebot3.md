<div align="center">

# 🕹️ Mover TurtleBot3 publicando en `/cmd_vel`
### Script en Python con una secuencia de movimientos

![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20LTS-orange?style=flat-square&logo=ubuntu)
![ROS2](https://img.shields.io/badge/ROS2-Humble%20Hawksbill-blue?style=flat-square&logo=ros)
![Python](https://img.shields.io/badge/Python-rclpy-yellow?style=flat-square&logo=python)

[← Volver al README principal](../../README.md)

</div>

---

## Tabla de contenidos

- [Requisitos](#requisitos)
- [El tópico `/cmd_vel`](#el-tópico-cmd_vel)
- [Crear el paquete](#crear-el-paquete)
- [Escribir el script de movimiento](#escribir-el-script-de-movimiento)
- [Agregar las dependencias](#agregar-las-dependencias)
- [Compilar y ejecutar](#compilar-y-ejecutar)
- [Solución de problemas comunes](#solución-de-problemas-comunes)
- [Referencias](#referencias)

---

## Requisitos

| Requisito | Detalle |
|---|---|
| 💻 Sistema operativo | Ubuntu **22.04 LTS** (Jammy Jellyfish) |
| 🤖 ROS 2 instalado | [ROS 2 Humble Hawksbill](../installation/ubuntu-deb.md) |
| 📁 Workspace activo | [robot_ws creado y compilado](../workspaces/robot-ws.md) |
| 🐢 Simulación corriendo | [TurtleBot3 en Gazebo](../turtlebot3/turtlebot3-humble.md) |

Antes de continuar, deja la simulación de TurtleBot3 corriendo en una terminal:

```bash
ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py
```

---

## El tópico `/cmd_vel`

Mientras Gazebo está corriendo, el plugin de control del robot se suscribe al tópico `/cmd_vel`, de tipo [`geometry_msgs/msg/Twist`](https://docs.ros.org/en/humble/p/geometry_msgs/interfaces/msg/Twist.html). Este mensaje tiene dos campos relevantes para un robot diferencial como TurtleBot3:

| Campo | Significado |
|---|---|
| `linear.x` | Velocidad lineal hacia adelante (m/s). Negativo = reversa |
| `angular.z` | Velocidad angular sobre el eje Z (rad/s). Positivo = gira a la **izquierda**, negativo = gira a la **derecha** |

Verifica que el tópico esté activo:

```bash
ros2 topic list | grep cmd_vel
ros2 topic info /cmd_vel
```

---

## Crear el paquete

Dentro de la carpeta `src/` del workspace, crea un paquete de Python llamado `move_turtlebot3`:

```bash
cd ~/workspaces/robot_ws/src
ros2 pkg create --build-type ament_python move_turtlebot3
```

---

## Escribir el script de movimiento

Crea el archivo `~/workspaces/robot_ws/src/move_turtlebot3/move_turtlebot3/move_sequence.py`:

```python
import time

import rclpy
from rclpy.node import Node
from geometry_msgs.msg import Twist


class MoveTurtlebot3(Node):

    def __init__(self):
        super().__init__('move_turtlebot3')
        self.publisher_ = self.create_publisher(Twist, 'cmd_vel', 10)

    def move(self, linear_x, angular_z, duration, rate_hz=10):
        """Publica una velocidad constante durante 'duration' segundos."""
        msg = Twist()
        msg.linear.x = linear_x
        msg.angular.z = angular_z

        steps = int(duration * rate_hz)
        for _ in range(steps):
            self.publisher_.publish(msg)
            time.sleep(1.0 / rate_hz)

    def stop(self):
        self.publisher_.publish(Twist())


def main(args=None):
    rclpy.init(args=args)
    node = MoveTurtlebot3()

    # Pausa breve para que el publicador se registre con los subscriptores (DDS discovery)
    time.sleep(1.0)

    node.get_logger().info('Avanzando en línea recta...')
    node.move(linear_x=0.2, angular_z=0.0, duration=3.0)

    node.get_logger().info('Girando a la derecha...')
    node.move(linear_x=0.0, angular_z=-0.5, duration=2.0)

    node.get_logger().info('Deteniendo el robot...')
    node.stop()

    node.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()
```

**Qué hace este script:**

1. Crea un publicador al tópico `cmd_vel` con mensajes `Twist`.
2. Espera 1 segundo para dar tiempo a que el publicador se registre en la red DDS antes de enviar el primer comando (si se publica demasiado rápido, Gazebo puede perder los primeros mensajes).
3. **Avanza en línea recta** publicando `linear.x = 0.2` m/s durante 3 segundos.
4. **Gira a la derecha** publicando `angular.z = -0.5` rad/s (sin velocidad lineal) durante 2 segundos.
5. **Detiene el robot** publicando un `Twist()` vacío (todas las velocidades en cero).

El mensaje se republica a 10 Hz en lugar de enviarse una sola vez, porque algunos controladores de velocidad descartan el comando si no reciben mensajes de forma continua.

> Ajusta `linear_x`, `angular_z` y `duration` según qué tan lejos quieras que avance o qué tan pronunciado sea el giro.

---

## Agregar las dependencias

### `package.xml`

Abre `~/workspaces/robot_ws/src/move_turtlebot3/package.xml` y agrega:

```xml
<depend>rclpy</depend>
<depend>geometry_msgs</depend>
```

### `setup.py`

Abre `~/workspaces/robot_ws/src/move_turtlebot3/setup.py` y agrega el entry point en `console_scripts`:

```python
entry_points={
    'console_scripts': [
        'move_sequence = move_turtlebot3.move_sequence:main',
    ],
},
```

---

## Compilar y ejecutar

```bash
cd ~/workspaces/robot_ws
rosdep install -i --from-path src/move_turtlebot3 --rosdistro humble -y

colcon build --packages-select move_turtlebot3
source install/setup.bash
```

Con la simulación de Gazebo ya corriendo en otra terminal, ejecuta el script:

```bash
ros2 run move_turtlebot3 move_sequence
```

Salida esperada:

```
[INFO] [move_turtlebot3]: Avanzando en línea recta...
[INFO] [move_turtlebot3]: Girando a la derecha...
[INFO] [move_turtlebot3]: Deteniendo el robot...
```

El TurtleBot3 debería avanzar en línea recta, girar a la derecha y detenerse por completo.

---

## Solución de problemas comunes

### El robot no se mueve

Verifica que el tópico `/cmd_vel` tenga al menos un subscriptor (el plugin de Gazebo):

```bash
ros2 topic info /cmd_vel
```

Si `Subscription count` es `0`, la simulación de Gazebo no está corriendo o no cargó el modelo del robot correctamente.

### El robot se mueve pero no se detiene al final

Si interrumpes el script con `CTRL+C` a mitad de un movimiento, el último comando publicado queda "congelado" porque no llega un mensaje de velocidad cero. Publica manualmente un `Twist` vacío para detenerlo:

```bash
ros2 topic pub --once /cmd_vel geometry_msgs/msg/Twist "{linear: {x: 0.0}, angular: {z: 0.0}}"
```

### El giro es demasiado brusco o el robot se sale del camino esperado

Reduce `angular_z` (por ejemplo `-0.3` en lugar de `-0.5`) o aumenta `duration` para un giro más suave y controlado.

---

## Referencias

- [geometry_msgs/msg/Twist — Documentación oficial](https://docs.ros.org/en/humble/p/geometry_msgs/interfaces/msg/Twist.html)
- [Tutorial oficial — Publicador y Suscriptor en Python](python-pub-sub.md)
- [Guía TurtleBot3 con ROS 2 Humble](../turtlebot3/turtlebot3-humble.md)

---

*Probado en Ubuntu 22.04 LTS · ROS 2 Humble Hawksbill · Octubre 2026*

---

<div align="center">

[← Volver a Publicador y Suscriptor en Python](python-pub-sub.md)

</div>
