<div align="center">

# 🐍 Publicador y Suscriptor en Python
### Ejemplo oficial de las Client Libraries de ROS 2

![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20LTS-orange?style=flat-square&logo=ubuntu)
![ROS2](https://img.shields.io/badge/ROS2-Humble%20Hawksbill-blue?style=flat-square&logo=ros)
![Python](https://img.shields.io/badge/Python-rclpy-yellow?style=flat-square&logo=python)

[← Volver al README principal](../../README.md)

</div>

---

## Tabla de contenidos

- [Requisitos](#requisitos)
- [Crear el paquete](#crear-el-paquete)
- [Escribir el nodo publicador](#escribir-el-nodo-publicador)
- [Escribir el nodo suscriptor](#escribir-el-nodo-suscriptor)
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
| 🐍 Librería cliente | `rclpy` (incluida con `ros-humble-desktop`) |

Este ejemplo recrea el tutorial oficial *"Writing a simple publisher and subscriber (Python)"* de la documentación de ROS 2, adaptado a la ruta del workspace `robot_ws` usada en este repositorio.

---

## Crear el paquete

Dentro de la carpeta `src/` del workspace, crea un paquete de Python llamado `py_pubsub`:

```bash
cd ~/workspaces/robot_ws/src
ros2 pkg create --build-type ament_python py_pubsub
```

Esto genera la siguiente estructura:

```
py_pubsub/
├── package.xml
├── setup.py
├── setup.cfg
├── resource/
│   └── py_pubsub
└── py_pubsub/
    └── __init__.py
```

---

## Escribir el nodo publicador

Crea el archivo `~/workspaces/robot_ws/src/py_pubsub/py_pubsub/publisher_member_function.py`:

```python
import rclpy
from rclpy.node import Node

from std_msgs.msg import String


class MinimalPublisher(Node):

    def __init__(self):
        super().__init__('minimal_publisher')
        self.publisher_ = self.create_publisher(String, 'topic', 10)
        timer_period = 0.5  # segundos
        self.timer = self.create_timer(timer_period, self.timer_callback)
        self.i = 0

    def timer_callback(self):
        msg = String()
        msg.data = 'Hello World: %d' % self.i
        self.publisher_.publish(msg)
        self.get_logger().info('Publishing: "%s"' % msg.data)
        self.i += 1


def main(args=None):
    rclpy.init(args=args)

    minimal_publisher = MinimalPublisher()

    rclpy.spin(minimal_publisher)

    minimal_publisher.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()
```

**Qué hace este nodo:**

- Crea un publicador (`create_publisher`) para mensajes `String` en el tópico `topic`, con una cola (`queue size`) de 10.
- Un timer (`create_timer`) dispara el callback `timer_callback` cada 0.5 segundos.
- Cada llamada publica un mensaje incremental `"Hello World: N"` y lo registra con `get_logger().info()`.

---

## Escribir el nodo suscriptor

Crea el archivo `~/workspaces/robot_ws/src/py_pubsub/py_pubsub/subscriber_member_function.py`:

```python
import rclpy
from rclpy.node import Node

from std_msgs.msg import String


class MinimalSubscriber(Node):

    def __init__(self):
        super().__init__('minimal_subscriber')
        self.subscription = self.create_subscription(
            String,
            'topic',
            self.listener_callback,
            10)
        self.subscription  # evita la advertencia de variable sin uso

    def listener_callback(self, msg):
        self.get_logger().info('I heard: "%s"' % msg.data)


def main(args=None):
    rclpy.init(args=args)

    minimal_subscriber = MinimalSubscriber()

    rclpy.spin(minimal_subscriber)

    minimal_subscriber.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()
```

**Qué hace este nodo:**

- Crea una suscripción (`create_subscription`) al mismo tópico `topic`, con el mismo tipo de mensaje `String`.
- Cada vez que llega un mensaje, se ejecuta `listener_callback`, que imprime el contenido recibido.

---

## Agregar las dependencias

### `package.xml`

Abre `~/workspaces/robot_ws/src/py_pubsub/package.xml` y agrega las dependencias después de la línea `ament_python`:

```xml
<depend>rclpy</depend>
<depend>std_msgs</depend>
```

### `setup.py`

Abre `~/workspaces/robot_ws/src/py_pubsub/setup.py` y completa los metadatos (`maintainer`, `maintainer_email`, `description`, `license`), y agrega los `entry_points` para que `ros2 run` pueda ejecutar los nodos:

```python
entry_points={
    'console_scripts': [
        'talker = py_pubsub.publisher_member_function:main',
        'listener = py_pubsub.subscriber_member_function:main',
    ],
},
```

---

## Compilar y ejecutar

Instala las dependencias y compila solo el paquete `py_pubsub`:

```bash
cd ~/workspaces/robot_ws
rosdep install -i --from-path src/py_pubsub --rosdistro humble -y

colcon build --packages-select py_pubsub
source install/setup.bash
```

**Terminal 1** — ejecuta el publicador:

```bash
ros2 run py_pubsub talker
```

Salida esperada:

```
[INFO] [minimal_publisher]: Publishing: "Hello World: 0"
[INFO] [minimal_publisher]: Publishing: "Hello World: 1"
[INFO] [minimal_publisher]: Publishing: "Hello World: 2"
```

**Terminal 2** — ejecuta el suscriptor:

```bash
ros2 run py_pubsub listener
```

Salida esperada:

```
[INFO] [minimal_subscriber]: I heard: "Hello World: 0"
[INFO] [minimal_subscriber]: I heard: "Hello World: 1"
[INFO] [minimal_subscriber]: I heard: "Hello World: 2"
```

Detén ambos nodos con `CTRL+C`.

---

## Solución de problemas comunes

### `ros2 run py_pubsub talker` → `Package 'py_pubsub' not found`

El workspace no está cargado en la terminal actual. Ejecuta:

```bash
source ~/workspaces/robot_ws/install/setup.bash
```

### El listener no recibe nada

Verifica que el tópico esté activo y que ambas terminales usen el mismo `ROS_DOMAIN_ID`:

```bash
ros2 topic list
ros2 topic info /topic
```

### Error al compilar: `ModuleNotFoundError: No module named 'std_msgs'`

Falta correr `rosdep install` o el entorno base de ROS 2 no está cargado:

```bash
source /opt/ros/humble/setup.bash
rosdep install -i --from-path src/py_pubsub --rosdistro humble -y
```

### `rosdep install` falla con paquetes de otros proyectos del workspace (ej. `warehouse_ros_mongo`)

Si `src/` tiene otros paquetes además de `py_pubsub` (por ejemplo, paquetes de un brazo robótico con MoveIt), ejecutar `rosdep install --from-path src` escaneará **todos** los paquetes del workspace, no solo el tuyo. Si alguno depende de un paquete sin binario `.deb` disponible para Humble (como `ros-humble-warehouse-ros-mongo`), la instalación fallará aunque no tenga nada que ver con `py_pubsub`.

**Solución:** apunta `--from-path` directamente a la carpeta del paquete en lugar de a todo `src/`:

```bash
rosdep install -i --from-path src/py_pubsub --rosdistro humble -y
```

---

## Referencias

- [Writing a simple publisher and subscriber (Python) — Documentación oficial ROS 2](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Writing-A-Simple-Py-Publisher-And-Subscriber.html)
- [rclpy API Reference](https://docs.ros2.org/latest/api/rclpy/)
- [std_msgs — Documentación de tipos de mensaje](https://docs.ros.org/en/humble/p/std_msgs/)

---

*Probado en Ubuntu 22.04 LTS · ROS 2 Humble Hawksbill · Octubre 2026*

---

<div align="center">

[← Volver a TurtleBot3 con ROS 2 Humble](../turtlebot3/turtlebot3-humble.md)

</div>
