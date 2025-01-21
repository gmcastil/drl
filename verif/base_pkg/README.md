# Base API Documentation

## `component_base`
The `component_base` class is the foundational building block of the
verification framework. It defines common properties, methods, and
lifecycle hooks, ensuring consistency and reusability across all derived
components.

### Overview
The `component_base` class:
- Serves as the root class for all verification componetns (e.g., `env_base`,
  `driver_base`).
- Provides shared functionality and structure including
  - Hierarchical organization (e.g., `name`, and `parent`)
  - Lifecycle phases (`build_phase`, `connect_phase`, etc.)
  - Utility methods (e.g., logging and hierarchical names)
It is not directly used in the verification environment but is inherited by
specialized base classes

### Properties

| **Property**        | **Type**          | **Default Value** | **Description**                                                                |
|---------------------|-------------------|-------------------|--------------------------------------------------------------------------------|
| `name`              | `string`          | `""`              | Name of the component instance, used for logging and debugging.                |
| `parent`            | `component_base`  | `null`            | Reference to the parent component in the hierarchy.                            |
| `current_log_level` | `log_level_t`     | `LOG_INFO`        | The log level for this component; messages below this level are filtered out.  |
| `children`          | `component_base[]` | `[]`             | List of all child components instantiated by this instance                     |

### Constructor

| **Method**  | **Arguments**                          | **Description**                                                                 |
|-------------|----------------------------------------|---------------------------------------------------------------------------------|
| `function new(string name, component_base parent = null)` | - `name`: The name of the component.<br> - `parent`: A reference to the parent component (optional). | Initializes the `component_base` instance, setting its name and parent. |

### Methods

#### Lifecycle Phases

| **Method**             | **Arguments** | **Description**                                                                 |
|------------------------|---------------|---------------------------------------------------------------------------------|
| `virtual task build_phase()` | None          | A hook for instantiating sub-components.                                       |
| `virtual task connect_phase()` | None          | A hook for connecting sub-components or establishing relationships.            |
| `virtual task run_phase()`     | None          | A hook for defining runtime behavior, such as driving stimulus or monitoring.  |
| `virtual task final_phase()` *(Optional)* | None          | A hook for cleanup or reporting after the simulation completes.                |

The `final_phase` is optional and provides a hook for cleanup tasks or
generating reports after all activity is completed.

#### Children Management
| **Method**                          | **Arguments**                   | **Description**                                                                 |
|-------------------------------------|---------------------------------|---------------------------------------------------------------------------------|
| `function void add_child(component_base child)` | `child`: The child component to add. | Adds a child component to the `children` array.                                |
| `function component_base[] get_children()` | None                          | Returns the list of child components.                                          |

Child components must be called explicitly when instantiating sub-components in
the `build_phase`

#### Logging

| **Method**                          | **Arguments**                            | **Description**                                                                 |
|-------------------------------------|------------------------------------------|---------------------------------------------------------------------------------|
| `function void set_log_level(log_level_t level)` | `level`: The log level to set for the component. | Updates the component’s `current_log_level`, filtering subsequent log messages. |
| `function log_level_t get_log_level()` | None                                     | Returns the current log level of the component.                                |
| `function void log(log_level_t level, string message)` | - `level`: Severity of the log message.<br>- `message`: The log message content. | Logs the message if `level >= current_log_level`.                              |

#### Utilities

| **Method**                          | **Arguments**                            | **Description**                                                                 |
|-------------------------------------|------------------------------------------|---------------------------------------------------------------------------------|
| `function string get_full_name()`   | None                                     | Returns the full hierarchical name of the component, combining `parent` and `name`. |
| `function bit is_root()`            | None                                     | Returns `true` if the component is the root of the hierarchy (i.e., has no parent). |
| `virtual task print_hierarchy()`    | None                                     | Prints the entire hierarchy of components starting from this instance.         |

### Notes for Developers
1. The `log_level_t` type and related constants (e.g., `LOG_DEBUG`, `LOG_INFO`) are defined in `common_pkg`. Components inherit their initial log level from the `default_log_level` in `common_pkg`, but this can be overridden at instantiation or runtime.
2. The `component_base` class is generic and reusable. Users are expected to extend it for specific use cases.
3. Log levels ensure debug information is accessible without overwhelming the output.
---
## `env_base`

The `env_base` class is the foundational class for building verification
environments. It extends the `component_base` class and provides shared
functionality and structure for all derived verification environments.

## Overview
The `env_base` class:
- Provides standardized lifecycle phases (e.g., `build_phase`, `connect_phase`).
- Acts as a container for sub-components (e.g., drivers, monitors, scoreboards).
- Does not assume any specific components, allowing derived classes to define the necessary elements.

This class is not intended to be used directly in the verification
environment but should be inherited by specialized environment classes (e.g.,
`uart_env` or `codec_env`).

## Properties
The `env_base` class does not define additional properties beyond those
inherited from `component_base`. Derived classes are expected to define
environment-specific properties as needed.

## Constructor

| **Method**  | **Arguments**                          | **Description**                                                                 |
|-------------|----------------------------------------|---------------------------------------------------------------------------------|
| `function new(string name, component_base parent = null)` | - `name`: The name of the environment.<br> - `parent`: A reference to the parent component (optional). | Initializes the environment instance, setting its name and parent. |

## Methods

### Lifecycle Phases

| **Method**             | **Arguments** | **Description**                                                                 |
|------------------------|---------------|---------------------------------------------------------------------------------|
| `virtual task build_phase()` | None          | A hook for instantiating sub-components in derived environments.                |
| `virtual task connect_phase()` | None          | A hook for connecting sub-components in derived environments.                   |
| `virtual task run_phase()`     | None          | A hook for defining runtime behavior.                                           |
| `virtual task final_phase()` *(Optional)* | None          | A hook for cleanup or reporting after the simulation completes.                 |

## Notes for Developers

1. The `env_base` class is designed to be extended by environment-specific classes (e.g., `uart_env`, `codec_env`). Derived classes should define and manage their own components (e.g., drivers, monitors, scoreboards).
2. Derived classes are responsible for implementing the lifecycle phases to instantiate, connect, and manage their sub-components.
3. The `env_base` class inherits child management functionality from `component_base`, allowing derived environments to register sub-components dynamically using `add_child`.
---

