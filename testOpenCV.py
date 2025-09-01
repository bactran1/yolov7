import cv2

# Open the camera using the V4L2 backend
cap = cv2.VideoCapture(0, cv2.CAP_V4L2)

# Check if the camera was opened successfully
if not cap.isOpened():
    print("Error: Could not open camera with V4L2 backend.")
    exit()

# Optionally, set desired V4L2 specific properties like format (FOURCC), resolution, and FPS
# For example, to set MJPG format, 1280x720 resolution, and 30 FPS:
cap.set(cv2.CAP_PROP_FOURCC, cv2.VideoWriter_fourcc('M', 'J', 'P', 'G'))
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 2560)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 1440)
cap.set(cv2.CAP_PROP_FPS, 30.0)

# Read and display frames (example)
while True:
    ret, frame = cap.read()
    if not ret:
        print("Error: Could not read frame.")
        break

    cv2.imshow('V4L2 Camera Feed', frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release the camera and destroy windows
cap.release()
cv2.destroyAllWindows()