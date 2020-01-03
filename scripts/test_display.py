import sys
import os
import cv2

file_path = "images/hello-world.jpg"

if not os.path.isfile(file_path):
    print("Testing image does not exist, exiting")
    sys.exit(0)

img = cv2.imread(file_path)
cv2.imshow("Testing", img)
key = cv2.waitKey(5000)
print("Testing finished")
