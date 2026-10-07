<div align="center">

# 🗂️ Creación del Workspace `robot_ws`
### Espacio de trabajo de ROS 2

![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20LTS-orange?style=flat-square&logo=ubuntu)
![ROS2](https://img.shields.io/badge/ROS2-Humble%20Hawksbill-blue?style=flat-square&logo=ros)
![colcon](https://img.shields.io/badge/Build-colcon-lightgrey?style=flat-square)

[← Volver al README principal](../../README.md)

</div>

---

## Tabla de contenidos

- [Requisitos](#requisitos)
- [Crear un workspace de ROS 2](#crear-un-workspace-de-ros-2)
- [Comandos útiles para empezar](#comandos-útiles-para-empezar)
- [Solución de problemas comunes](#solución-de-problemas-comunes)

---

## Requisitos

| Requisito | Detalle |
|---|---|
| 💻 Sistema operativo | Ubuntu **22.04 LTS** (Jammy Jellyfish) |
| 🤖 ROS 2 instalado | [ROS 2 Humble Hawksbill](../installation/ubuntu-deb.md) |
| 🔨 Herramientas de desarrollo | `ros-dev-tools` (incluye `colcon`) |
| 📁 Ruta del workspace | `/home/workspaces/omni3robot_ws` |

Verifica que `colcon` esté disponible:

```bash
colcon --version
```

Si no está instalado:

```bash
sudo apt install ros-dev-tools
```

---

## Crear un workspace de ROS 2

Un **workspace** es el directorio donde organizas y compilas tus paquetes de ROS 2. La convención es tener una carpeta `src/` con el código fuente y usar `colcon` para compilar.

### Estructura del workspace

```
robot_ws/
├── src/          ← código fuente de tus paquetes
├── build/        ← archivos intermedios de compilación (generado por colcon)
├── install/      ← paquetes compilados listos para usar (generado por colcon)
└── log/          ← logs de compilación (generado por colcon)
```

> `build/`, `install/` y `log/` son generados automáticamente por `colcon build` — nunca los edites manualmente.

### Crear el workspace

```bash
# Crear el directorio del workspace y la carpeta src
mkdir -p ~/workspaces/robot_ws/src

# Entrar al workspace
cd ~/workspaces/robot_ws/
```

### Compilar el workspace (vacío por primera vez)

```bash
colcon build
```

Salida esperada al compilar un workspace vacío:

```
Summary: 0 packages finished [0.5s]
```

### Cargar el entorno del workspace

Después de compilar, carga el entorno del workspace para que ROS 2 reconozca tus paquetes:

```bash
source install/setup.bash
```

Para cargarlo automáticamente en cada nueva terminal, agrégalo al `~/.bashrc`:

```bash
echo "source ~/workspaces/robot_ws/install/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

> **Importante:** el `source install/setup.bash` del workspace debe ir **después** del `source /opt/ros/humble/setup.bash` en el `~/.bashrc`.

### Crear un paquete dentro del workspace

```bash
cd ~/workspaces/robot_ws/src

# Paquete en Python
ros2 pkg create --build-type ament_python mi_paquete_py

# Paquete en C++
ros2 pkg create --build-type ament_cmake mi_paquete_cpp
```

Luego vuelve a la raíz del workspace y compila:

```bash
cd ~/workspaces/robot_ws/
colcon build
source install/setup.bash
```

### Compilar solo un paquete específico

```bash
colcon build --packages-select mi_paquete_py
```

---

## Comandos útiles para empezar

```bash
# Ver todos los tópicos activos
ros2 topic list

# Ver todos los nodos activos
ros2 node list

# Ver información de un tópico
ros2 topic info /chatter

# Escuchar mensajes de un tópico en terminal
ros2 topic echo /chatter

# Diagnóstico del entorno ROS 2
ros2 doctor

# Listar paquetes instalados
ros2 pkg list

# Ver servicios disponibles
ros2 service list
```

---

## Solución de problemas comunes

### Error: `Network is unreachable` al ejecutar `apt update`

El mirror regional está caído o tiene problemas de IPv6. Ver [Paso 1](#paso-1--corregir-mirror-de-ubuntu-error-regional).

### Error: `bash: ros2: command not found`

El entorno de ROS 2 no está cargado. Ejecuta:

```bash
source /opt/ros/humble/setup.bash
```

Y verifica que el `echo` del paso 7 quedó guardado en `~/.bashrc`.

### Error al ejecutar `rosdep init`: `default sources list file already exists`

Es un error inofensivo, puedes ignorarlo y continuar con `rosdep update`.

### `ros2 run demo_nodes_cpp talker` no aparece en el listener

Puede ser un problema de DDS y red. Intenta desactivar el firewall temporalmente:

```bash
sudo ufw disable
```

O ajusta el dominio ROS_DOMAIN_ID para que coincida en ambas terminales:

```bash
export ROS_DOMAIN_ID=0
```

### Los nodos en terminales distintas no se ven entre sí

Asegúrate de que ambas terminales tienen el mismo `ROS_DOMAIN_ID`:

```bash
export ROS_DOMAIN_ID=42   # mismo número en ambas terminales
```

### Error: `PermissionError: [Errno 13] Permission denied: 'log'` al ejecutar `colcon build`

```
PermissionError: [Errno 13] Permission denied: 'log'
```

**Causa:** en algún momento se ejecutó `colcon build` con `sudo`, lo que hizo que los directorios `build/`, `install/` y `log/` quedaran con permisos de root. Tu usuario normal ya no puede escribir en ellos.

**Solución 1 — corregir permisos del workspace:**

```bash
sudo chown -R $USER:$USER ~/workspaces/robot_ws/
colcon build
```

**Solución 2 — limpiar y recompilar desde cero:**

```bash
cd ~/workspaces/robot_ws/
sudo rm -rf build install log
colcon build
```

> **Regla de oro:** nunca uses `sudo` con `colcon`. Siempre compila como usuario normal:
>
> ```bash
> # CORRECTO
> colcon build
>
> # INCORRECTO — nunca hacer esto
> sudo colcon build
> ```

---

## Referencias

- [Documentación oficial ROS 2 Humble](https://docs.ros.org/en/humble/)
- [Guía de instalación oficial](https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debians.html)
- [ROS Index — paquetes disponibles](https://index.ros.org/)
- [ROS Discourse — comunidad y soporte](https://discourse.ros.org/)

---

*Probado en Ubuntu 22.04 LTS · ROS 2 Humble Hawksbill · Septiembre 2026*


---

<div align="center">

[← Volver a Verificar la instalación](../../docs/verification/talker-listener.md) &nbsp;|&nbsp; [TurtleBot3 con ROS 2 Humble →](../../docs/turtlebot3/turtlebot3-humble.md)

</div>
