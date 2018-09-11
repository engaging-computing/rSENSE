# Douglas Salvati
# Honors Project
# Fall 2017
# This version is designed to be run by a controller,
# not on its own.

import cv2 as cv
import numpy as np
import sys
import json

# Get arguments
if len(sys.argv) != 9:
    print("Usage: tracker.py [path to video] [sampling radius (px)] [tolerance (%)] [units] [x] [y] [outfile] [datafile]")
    sys.exit(1)
video_path = sys.argv[1]
sampling_radius = np.abs(int(sys.argv[2])) # px
tolerance = float(sys.argv[3]) / 100 # percent as fraction
units = int(sys.argv[4]) # How many pixels = 1 unit
if tolerance < 0 or tolerance > 1:
    print("Tolerance can't be " + str(tolerance * 100) + "%.")
    print("Tolerance must be between 0 and 100%.")
    sys.exit(1)
selected_x = int(sys.argv[5])
selected_y = int(sys.argv[6])
outpath = sys.argv[7]
datapath = sys.argv[8]

# Read the video
cap = cv.VideoCapture(video_path)
if not cap.isOpened():
    print("Problem with input file, please check path.")
    sys.exit(1)
fourcc = (int(cap.get(cv.cv.CV_CAP_PROP_FOURCC)))
#fourcc = cv.cv.CV_FOURCC(*'avc1')
size = (int(cap.get(cv.cv.CV_CAP_PROP_FRAME_WIDTH)),
        int(cap.get(cv.cv.CV_CAP_PROP_FRAME_HEIGHT)))
fps = cap.get(cv.cv.CV_CAP_PROP_FPS)
frames = int(cap.get(cv.cv.CV_CAP_PROP_FRAME_COUNT))
out = cv.VideoWriter(outpath, fourcc, fps, size)
if not out.isOpened():
    print("Failed to open writer for " + outpath)
    sys.exit(1)
ret, img = cap.read()
cap.release()

# Get color bounds
# Average colors
mask = np.zeros(img.shape[:2], np.uint8)
cv.circle(mask, (selected_x, selected_y), sampling_radius, (255,255,255), -1)
average_color = cv.mean(img, mask)
# Convert to HSV and get hue, we need it later
hue = cv.cvtColor(np.array([[average_color]], dtype=np.uint8), cv.COLOR_BGR2HSV)[0][0][0]
# All we care about is the hue, sat and val will be fixed to wide range
sv_low = int(255 - (tolerance * 255))
dark = np.array([hue - 10, sv_low, sv_low])
light = np.array([hue + 10, 255, 255])

# Loop over all frames
cap = cv.VideoCapture(video_path)
i = 0
data = []

for i in range(1, frames + 1):
    # Read a frame
    ret, img = cap.read()
    if ret == True:
        
        # Convert to HSV color
        hsv = cv.cvtColor(img, cv.COLOR_BGR2HSV)
            
        # Threshold
        mask = cv.inRange(hsv, dark, light)

        # Border
        contours, _ = cv.findContours(mask, cv.RETR_TREE, cv.CHAIN_APPROX_SIMPLE)
        areas = map(cv.contourArea, contours)
        if len(areas) == 0:
            print("Lost track of object... try improving video quality.<br/>Make sure the object stays in the frame the whole time!")
            sys.exit(1)
        contour = contours[areas.index(max(areas))]
        cv.drawContours(img, contour, -1, (0, 255, 0), 10)

        # Get bounding box of contour
        x, y, w, h = cv.boundingRect(contour)
        bounded_mask = mask[y:y+h, x:x+h]
        
        # Calculate centroid
        moments = cv.moments(bounded_mask)
        centroid_x = int(moments['m10']/moments['m00']) + x
        centroid_y = int(moments['m01']/moments['m00']) + y
        cv.circle(img,(centroid_x, centroid_y),10,(0,0,255),2)

        # Save frame
        out.write(img)
        
        # Print coordinates
        t = i / fps
        trans_x = centroid_x / float(units)
        ymax, _ = img.shape[:2]
        trans_y = (ymax - centroid_y) / float(units)
        data_pt = {"t":t,"x":trans_x,"y":trans_y}
        data.append(data_pt)

    else:
        print("\nUnknown error occurred processing frame " + str(i) + ". Halting...")
        sys.exit(1)

# Clean up & export video
cap.release()
out.release()

# Calculate v, a, and export data
for i, data_pt in enumerate(data):
    if i > 0:
        delta_t = data_pt["t"] - data[i - 1]["t"]
        data_pt["vx"] = (data_pt["x"] - data[i - 1]["x"]) / delta_t
        data_pt["vy"] = (data_pt["y"] - data[i - 1]["y"]) / delta_t
    else:
        data_pt["vx"] = data_pt["vy"] = 0
    if i > 1:
        data_pt["ax"] = (data_pt["vx"] - data[i - 1]["vx"]) / delta_t
        data_pt["ay"] = (data_pt["vy"] - data[i - 1]["vy"]) / delta_t
    else:
        data_pt["ax"] = data_pt["ay"] = 0
        
with open(datapath, 'w') as outfile:
    json.dump(data, outfile)