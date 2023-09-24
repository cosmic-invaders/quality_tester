import cv2
import numpy as np

def getContours(img,cThr=[100,100],showCanny=False,minArea=1000,filter=0,draw =False):
    imgGray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
    imgBlur = cv2.GaussianBlur(imgGray,(5,5),1)
    imgCanny = cv2.Canny(imgBlur,cThr[0],cThr[1])
    kernel = np.ones((5,5))
    imgDial = cv2.dilate(imgCanny,kernel,iterations=3)
    imgThre = cv2.erode(imgDial,kernel,iterations=2)
    if showCanny:cv2.imshow('Canny',imgThre)
    contours,hiearchy = cv2.findContours(imgThre,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)
    finalCountours = []
    for i in contours:
        area = cv2.contourArea(i)
        if area > minArea:
            peri = cv2.arcLength(i,True)
            approx = cv2.approxPolyDP(i,0.02*peri,True)
            bbox = cv2.boundingRect(approx)
            if filter > 0:
                if len(approx) == filter:
                    finalCountours.append([len(approx),area,approx,bbox,i])
            else:
                finalCountours.append([len(approx),area,approx,bbox,i])
    finalCountours = sorted(finalCountours,key = lambda x:x[1] ,reverse= True)
    if draw:
        for con in finalCountours:
            cv2.drawContours(img,con[4],-1,(0,0,255),3)
    return img, finalCountours

# calculates the ordered vertex points in terms of contours    

def reorder(myPoints):
    #print(myPoints.shape)
    falg = -1
    myPointsNew = np.zeros_like(myPoints)
    try:
        myPoints = myPoints.reshape((4,2))
        add = myPoints.sum(1)
        myPointsNew[0] = myPoints[np.argmin(add)]
        myPointsNew[3] = myPoints[np.argmax(add)]
        diff = np.diff(myPoints,axis=1)
        myPointsNew[1]= myPoints[np.argmin(diff)]
        myPointsNew[2] = myPoints[np.argmax(diff)]
        flag = 4
    except Exception:
        #### for triangle detection
        # Simple fix for traingles -- subject to change
        myPoints = myPoints.reshape((3,2))
        myPointsNew[0] = myPoints[2]
        myPointsNew[1] = myPoints[1]
        myPointsNew[2] = myPoints[0]
        flag = 3
        # print(myPointsNew)
    return myPointsNew, flag

# changes the persepective of the image and zooms in

def warpImg (img,points,w,h,pad=20):
    #print(points)
    points, flag =reorder(points)
    pts1 = np.float32(points)
    pts2 = np.float32([[0,0],[w,0],[0,h],[w,h]])
    matrix = cv2.getPerspectiveTransform(pts1,pts2)
    imgWarp = cv2.warpPerspective(img,matrix,(w,h))
    imgWarp = imgWarp[pad:imgWarp.shape[0]-pad,pad:imgWarp.shape[1]-pad]
    return imgWarp

def findDis(pts1,pts2):
    return ((pts2[0]-pts1[0])**2 + (pts2[1]-pts1[1])**2)**0.5

#to detect circles only (filter value = 0)

def detectCircles(img, showCanny=False, px_to_cm=0.03389):

    flag = 0

    imgGray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    imgBlur = cv2.GaussianBlur(imgGray, (5, 5), 1)
    imgCanny = cv2.Canny(imgBlur, 50, 150)

    if showCanny:
        cv2.imshow('Canny', imgCanny)
        
    # Apply Hough Circle Transform
    circles = cv2.HoughCircles(imgCanny, cv2.HOUGH_GRADIENT, dp=1, minDist=80, param1=30, param2=45, minRadius=0, maxRadius=0)

    diameters_cm = []
    if circles is not None:
        # Convert the (x, y) coordinates and radius of the circles to integers
        circles = np.round(circles[0, :]).astype("int")

        # Draw the detected circles on the original image and calculate diameter for each
        for (x, y, r) in circles:
            cv2.circle(img, (x, y), r, (0, 255, 0), 2)
            diameter_px = r * 2
            diameter_cm = diameter_px * px_to_cm
            diameters_cm.append(diameter_cm)
            
            # Highlight the diameter span of the circle
            cv2.line(img, (x - r, y), (x + r, y), (0, 0, 255), 2)

            # Write the diameter on the original image
            font = cv2.FONT_HERSHEY_SIMPLEX
            text = f'{diameter_cm:.2f} cm'
            text_size, _ = cv2.getTextSize(text, font, 0.6, 2)
            cv2.putText(img, text, (x - int(r/2), y-20), font, 0.6, (0, 0, 255), 2)

    return img, circles, diameters_cm, flag

