# MagPieCam-iOS
An iOS app that enables users to receive smart notifications based on rules that they set, and video live video from a MagPieCam.

<table>
<tr>
<td><img src="https://github.com/ataffe/MagPieCam-Assets/blob/main/images/screenshots/login.PNG?raw=true" width="201"></td>
<td><img src="https://github.com/ataffe/MagPieCam-Assets/blob/main/images/screenshots/camera-detail.PNG?raw=true" width="201"></td>
<td><img src="https://github.com/ataffe/MagPieCam-Assets/blob/main/images/screenshots/notifications.PNG?raw=true" width="201"></td>
<td><img src="https://github.com/ataffe/MagPieCam-Assets/blob/main/images/screenshots/rules.PNG?raw=true" width="201"></td>
</tr>
</table>






# System Diagram
![Scout Cam System Diagram](https://github.com/ataffe/MagPieCam-Assets/blob/main/system_diagram/magpie-cam-system-diagram-iOS.png?raw=true)

### Brief Overview
[MagPieCam Edge Agent](https://github.com/ataffe/MagPieCamEdgeAgent) - An agent that runs on the camera. It tracks movement and sends images and video to the MagPieCam-Core backend for processing.

[MagPieCam-Core](https://github.com/ataffe/MagPieCam-Core) - The backend for the MagPieCam system. MagPieCam-Core Handles CRUD operations for Users, Cameras, Rules, and notifications. MagPieCam-Core also facilitates streaming coordination between users and cameras using a MedaMTX server. The core also contains workers that handle rules evaluation and trigger push notifications when a rules is fired.

# Setup

The app reads its backend addresses from an xcconfig file that is not checked in,
so you need to create one pointing at your own [MagPieCam-Core](https://github.com/ataffe/MagPieCam-Core) instance:

```sh
cd MagPieCam/MagPieCam/Config
cp Debug.xcconfig.example Debug.xcconfig
cp Release.xcconfig.example Release.xcconfig
```

Then edit both files and replace `YOUR_BACKEND_HOST` with the host running
MagPieCam-Core. `API_BASE_URL` points at the Core API and `WHEP_URL` at its
MediaMTX WHEP endpoint.

These two files are gitignored. Without them the build still compiles, but
`API_BASE_URL` resolves to an empty string and the app traps at launch.


