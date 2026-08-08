# Nexo PyCozmo Documentation

Welcome to the documentation for **Nexo PyCozmo**, a 100% Python library that allows you to control the Digital Dream Labs (Anki) Cozmo robot without going through the official mobile app. 

This library is designed to run with Python 3.13, 3.14, and above.

---

## Installation

You can install the library directly from PyPI:

```bash
pip install nexo-pycozmo
```

Once installed, you must download the necessary resources (animations, etc.) using the provided tool:

```bash
pycozmo_resources.py download
```

---

## 1. Setup and Wi-Fi Connection

Before running any Python script, your computer must be connected to the Cozmo robot via Wi-Fi.

1. Place Cozmo on its charging platform.
2. Manually raise and lower its lift arm: its screen will then display the Wi-Fi network name (SSID) and the password (PSK).
3. Connect your computer's Wi-Fi to Cozmo's network.

> **Important:** As long as you are not connected to Cozmo's Wi-Fi, the Python scripts will not be able to communicate with the robot.

---

## 2. Minimal Script: Connecting

The main API uses a `pycozmo.connect()` context manager which automatically handles creating the client, connecting, waiting for the robot, and cleanly disconnecting at the end of the block.

```python
import time
import pycozmo

# Connect to the robot
with pycozmo.connect() as cli:
    print("Connected to Cozmo!")
    time.sleep(2)
```

---

## 3. Controlling the Motors

You can directly control Cozmo's head, lift, and wheels.

### Head and Lift
```python
import time
import pycozmo

with pycozmo.connect() as cli:
    # Raise the head to the center (angle between MAX and MIN)
    head_angle = (pycozmo.robot.MAX_HEAD_ANGLE.radians - pycozmo.robot.MIN_HEAD_ANGLE.radians) / 2.0
    cli.set_head_angle(head_angle)

    # Raise the lift arm
    cli.set_lift_height(pycozmo.robot.MAX_LIFT_HEIGHT.mm)
    time.sleep(2)
```

### Wheels (Movement)
```python
import time
import pycozmo

with pycozmo.connect() as cli:
    # Move forward (left wheel speed = 50, right wheel speed = 50) for 2 seconds
    cli.drive_wheels(lwheel_speed=50.0, rwheel_speed=50.0, duration=2.0)
    time.sleep(2.5)
```

---

## 4. Playing Animations

Cozmo has a very rich animation system that you can trigger by name. The animations are defined by internal files.

```python
import pycozmo

with pycozmo.connect() as cli:
    # Load the list of animations (only needs to be done once)
    cli.load_anims()

    # Play the wakeup animation
    cli.play_anim("anim_launch_wakeup_01")
    
    # Wait for the animation to finish
    cli.wait_for(pycozmo.event.EvtAnimationCompleted)
```

*Note: You can retrieve the complete list of available animations by calling `cli.get_anim_names()`.*

---

## 5. Using the Camera

You can enable the video stream and retrieve frames (`RawCameraImage`) to analyze them with OpenCV or save them to disk.

```python
import time
import pycozmo

# Function called on every new image received
def on_camera_image(cli, image):
    # Save the first image received and we are done
    image.save("camera.png", "PNG")
    print("Image saved!")

with pycozmo.connect() as cli:
    # Raise the head to get a better view
    cli.set_head_angle((pycozmo.robot.MAX_HEAD_ANGLE.radians - pycozmo.robot.MIN_HEAD_ANGLE.radians) / 2.0)

    # Enable the camera in color mode
    cli.enable_camera(enable=True, color=True)

    # Wait for the image to stabilize
    time.sleep(2.0)

    # Subscribe to the new image event (one_shot=True to trigger it only once)
    cli.add_handler(pycozmo.event.EvtNewRawCameraImage, on_camera_image, one_shot=True)

    # Allow time for the image to arrive
    time.sleep(1)
```

---

## 6. The Event System

PyCozmo is highly event-driven. The client (`cli`) dispatches events when Cozmo sends data (new camera image, cube button pressed, cliff sensor triggered, animation finished, etc.).

You can attach a *handler* (callback) to a specific event using `cli.add_handler(EventClass, callback)`.

Examples of very useful events:
- `pycozmo.event.EvtNewRawCameraImage`: Triggers on a new camera frame.
- `pycozmo.event.EvtAnimationCompleted`: Triggers when an animation finishes.
- `pycozmo.event.EvtRobotStateUpdated`: Called regularly upon state updates (battery, pitch/roll...).
- `pycozmo.event.EvtObjectTapped`: Triggers when a cube is tapped.

---

## More Features

To explore in more detail what `Nexo PyCozmo` allows:
- Explore the `examples/` folder in the source code to see many concrete demonstrations (drawing on the OLED screen, procedural faces, gamepad control...).
- Browse `docs/functions.md` and `docs/offboard_functions.md` for an in-depth look at the software architecture.
