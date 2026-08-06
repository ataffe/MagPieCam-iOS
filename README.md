# ScoutCamiOS
iOS Application for the Scout camera system.

# System Diagram
![Scout Cam System Diagram](https://github.com/ataffe/ScoutCamAssets/blob/main/system_diagram/scout-cam-system-diagram-iOS.png?raw=true)

### Brief Overview

[Scout Cam Camera Client](https://github.com/ataffe/GuardianCamCameraClient) - Detects Motion and filters images using object detection and then sends the image to the 
event processor if an object is detected.

[Scout Cam Web Service](https://github.com/ataffe/ScoutCamEventProcessor) - Handles CRUD operations for Users, Cameras, and Rules. Also handles streaming coordination between users and cameras.


