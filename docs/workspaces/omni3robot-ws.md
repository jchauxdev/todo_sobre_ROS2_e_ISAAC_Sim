<div align="center">

# 🗂️ Creación del Workspace `omni3robot_ws`
### Espacio de trabajo de ROS 2

![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20LTS-orange?style=flat-square&logo=ubuntu)
![ROS2](https://img.shields.io/badge/ROS2-Humble%20Hawksbill-blue?style=flat-square&logo=ros)
![colcon](https://img.shields.io/badge/Build-colcon-lightgrey?style=flat-square)

[← Volver al README principal](../../README.md)

</div>

---

## Tabla de contenidos

- [Requisitos](#requisitos)
- [Paso 1 — Crear la estructura del workspace](#paso-1--crear-la-estructura-del-workspace)
- [Paso 2 — Compilar el workspace](#paso-2--compilar-el-workspace)
- [Paso 3 — Agregar al `.bashrc`](#paso-3--agregar-al-bashrc)
- [Verificar la configuración](#verificar-la-configuración)

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
colcon version-check
```

> `colcon` **no tiene** la opción `--version` (da error de argumento no reconocido aunque esté instalado). Para ver la versión usa `pip3 show colcon-core` o `apt show python3-colcon-core`. Si `colcon version-check` imprime la lista de paquetes sin error, está instalado correctamente.

Si no está instalado:

```bash
sudo apt install ros-dev-tools
```

---

## Paso 1 — Crear la estructura del workspace

Un workspace de ROS 2 requiere una carpeta `src/` en su interior, donde se colocan los paquetes.

Crea el directorio del workspace junto con la carpeta `src/`:

```bash
mkdir -p /home/workspaces/omni3robot_ws/src
```

Verifica la estructura creada:

```bash
ls /home/workspaces/omni3robot_ws/
```

Deberías ver:

```
src/
```

---

## Paso 2 — Compilar el workspace

Aunque el workspace esté vacío (sin paquetes en `src/`), es necesario compilarlo al menos una vez para que `colcon` genere los archivos de configuración del entorno.

Accede al directorio raíz del workspace:

```bash
cd /home/workspaces/omni3robot_ws
```

Ejecuta la compilación:

```bash
colcon build
```

Al finalizar, `colcon` habrá creado las siguientes carpetas dentro del workspace:

```
omni3robot_ws/
├── build/       # Archivos intermedios de compilación
├── install/     # Archivos instalados (setup.bash y paquetes)
├── log/         # Registros de compilación
└── src/         # Código fuente de los paquetes
```

> **Nota:** El archivo `install/setup.bash` es el que debes cargar para usar los paquetes de este workspace.

### Opciones útiles de `colcon build`

| Opción | Descripción |
|---|---|
| `--symlink-install` | Crea enlaces simbólicos en lugar de copiar archivos. Útil durante el desarrollo para no recompilar al editar scripts Python o archivos de configuración. |
| `--packages-select <pkg>` | Compila solo el paquete especificado. |
| `--packages-up-to <pkg>` | Compila el paquete y todas sus dependencias. |

Ejemplo con `--symlink-install` (recomendado para desarrollo):

```bash
colcon build --symlink-install
```

---

## Paso 3 — Agregar al `.bashrc`

Para que el workspace esté disponible automáticamente en cada nueva terminal, agrega su script de configuración al archivo `~/.bashrc`.

Ejecuta el siguiente comando:

```bash
echo "source /home/workspaces/omni3robot_ws/install/setup.bash" >> ~/.bashrc
```

Recarga el `.bashrc` en la terminal actual:

```bash
source ~/.bashrc
```

> **Importante:** El script `install/setup.bash` del workspace **extiende** el entorno de ROS 2 base. Para que funcione correctamente, el source de ROS 2 base debe estar declarado **antes** en el `.bashrc`.
>
> El orden correcto en `~/.bashrc` es:
>
> ```bash
> source /opt/ros/humble/setup.bash
> source /home/workspaces/omni3robot_ws/install/setup.bash
> ```

---

## Verificar la configuración

Comprueba que el workspace esté correctamente cargado verificando la variable `AMENT_PREFIX_PATH`:

```bash
echo $AMENT_PREFIX_PATH
```

Deberías ver la ruta del workspace al inicio de la lista:

```
/home/workspaces/omni3robot_ws/install/omni3robot_ws:/opt/ros/humble
```

También puedes listar todos los paquetes disponibles en el workspace activo con:

```bash
ros2 pkg list
```

---

<div align="center">

[← Volver a Verificar la instalación](../../docs/verification/talker-listener.md)

</div>
