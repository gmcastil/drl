
# `component_base` API Documentation

The `component_base` class is the foundational building block of the verification framework. It defines common properties, methods, and lifecycle hooks, ensuring consistency and reusability across all derived components.

## Overview
The `component_base` class provides:
- **Hierarchy Management**: Establishes parent-child relationships.
- **Lifecycle Phases**: Standardized hooks for building, connecting, running, and finalizing components.
- **Logging**: A flexible logging mechanism integrated with log levels from `common_pkg`.
- **Utilities**: Methods for retrieving hierarchical names and managing the component’s state.

---

## Properties

| **Property**        | **Type**          | **Default Value** | **Description**                                                                 |
|----------------------|-------------------|-------------------|---------------------------------------------------------------------------------|
| `name`              | `string`          | `""`              | Name of the component instance, used for logging and debugging.                |
| `parent`            | `component_base`  | `null`            | Reference to the parent component in the hierarchy.                            |
| `current_log_level` | `log_level_t`     | `LOG_INFO`        | The log level for this component; messages below this level are filtered out.  |

---

## Constructor

| **Method**  | **Arguments**                          | **Description**                                                                 |
|-------------|----------------------------------------|---------------------------------------------------------------------------------|
| `function new(string name, component_base parent = null)` | - `name`: The name of the component.<br> - `parent`: A reference to the parent component (optional). | Initializes the `component_base` instance, setting its name and parent. |

---

## Methods

### Lifecycle Phases

| **Method**             | **Arguments** | **Description**                                                                 |
|------------------------|---------------|---------------------------------------------------------------------------------|
| `virtual task build_phase()` | None          | A hook for instantiating sub-components.                                       |
| `virtual task connect_phase()` | None          | A hook for connecting sub-components or establishing relationships.            |
| `virtual task run_phase()`     | None          | A hook for defining runtime behavior, such as driving stimulus or monitoring.  |
| `virtual task final_phase()` *(Optional)* | None          | A hook for cleanup or reporting after the simulation completes.                |

---

### Logging

| **Method**                          | **Arguments**                            | **Description**                                                                 |
|-------------------------------------|------------------------------------------|---------------------------------------------------------------------------------|
| `function void set_log_level(log_level_t level)` | `level`: The log level to set for the component. | Updates the component’s `current_log_level`, filtering subsequent log messages. |
| `function log_level_t get_log_level()` | None                                     | Returns the current log level of the component.                                |
| `function void log(log_level_t level, string message)` | - `level`: Severity of the log message.<br>- `message`: The log message content. | Logs the message if `level >= current_log_level`.                              |

---

### Utilities

| **Method**                          | **Arguments**                            | **Description**                                                                 |
|-------------------------------------|------------------------------------------|---------------------------------------------------------------------------------|
| `function string get_full_name()`   | None                                     | Returns the full hierarchical name of the component, combining `parent` and `name`. |
| `function bit is_root()`            | None                                     | Returns `true` if the component is the root of the hierarchy (i.e., has no parent). |
| `virtual task print_hierarchy()`    | None                                     | Prints the entire hierarchy of components starting from this instance.         |

---

## Notes for Developers
1. **Log Levels**: The `log_level_t` type and related constants (e.g., `LOG_DEBUG`, `LOG_INFO`) are defined in `common_pkg`. Components inherit their initial log level from the `default_log_level` in `common_pkg`, but this can be overridden at instantiation or runtime.
2. **Extensibility**: The `component_base` class is generic and reusable. Users are expected to extend it for specific use cases.
3. **Logging Flexibility**: Log levels ensure debug information is accessible without overwhelming the output.

---
