import cv2
import utlis

flag = -1       # default is -1, 0 for circle, 3 for triangle and so on

def cal_dim():
    ###################################
    path = "com/request.jpg"
    scale = 3
    wP = 210 *scale
    hP= 297 *scale
    ###################################
    
    img = cv2.imread(path)
    imgContours , conts = utlis.getContours(img,minArea=50000,filter=4)
    if len(conts) != 0:
        biggest = conts[0][2]
        #print(biggest)
        imgWarp = utlis.warpImg(img, biggest, wP,hP)

        # to detect the largest contour that is the A4 and the embedded rectangular object

        imgContours2, conts2 = utlis.getContours(imgWarp, 
                                                minArea=2000, filter=4,
                                                cThr=[50,50],draw = False)

        # Becomes true when the embedded object is not a rectangle

        if(len(conts2)==0):

            # To detect triangle

            imgContours2, conts2 = utlis.getContours(imgWarp,
                                                minArea=2000, filter=3,
                                                cThr=[50,50],draw = False)
            
            # To detect circle if not a triangle

            if(len(conts2)==0):
                img, circles, diameters_cm,flag = utlis.detectCircles(imgWarp,False)
                cv2.imwrite('com/result.jpg', img)
                return  diameters_cm
                

        # if(imgContours2):
        # print('imgContours2',imgContours2)
        # print('conts2',conts2)
        if len(conts) != 0  :
            for obj in conts2:
                cv2.polylines(imgContours2,[obj[2]],True,(0,255,0),2)
                cv2.waitKey(0)
                cv2.destroyAllWindows()
                nPoints,flag = utlis.reorder(obj[2])

                if(flag==4):

                    # print("rectangle")
                    nW = round((utlis.findDis(nPoints[0][0]//scale,nPoints[1][0]//scale)/10),1)
                    nH = round((utlis.findDis(nPoints[0][0]//scale,nPoints[2][0]//scale)/10),1)
                    n3 = round((utlis.findDis(nPoints[1][0]//scale,nPoints[2][0]//scale)/10),1)
                    # print(nW,nH,n3)
                    # print('nPoints',nPoints[0][0][0], nPoints[0][0][1],nPoints[1][0][0], nPoints[1][0][1],nPoints[0][0][0], nPoints[0][0][1],nPoints[2][0][0], nPoints[2][0][1],nPoints[1][0][0], nPoints[1][0][1],nPoints[2][0][0], nPoints[2][0][1])
                    cv2.arrowedLine(imgContours2, (nPoints[0][0][0], nPoints[0][0][1]), (nPoints[1][0][0], nPoints[1][0][1]),
                                    (255, 0, 0), 3, 8, 0, 0.05)
                    cv2.arrowedLine(imgContours2, (nPoints[0][0][0], nPoints[0][0][1]), (nPoints[2][0][0], nPoints[2][0][1]),
                                    (0,0,0), 3, 8, 0, 0.05)
                    cv2.arrowedLine(imgContours2, (nPoints[1][0][0], nPoints[1][0][1]), (nPoints[2][0][0], nPoints[2][0][1]),
                                    (0, 0, 255), 3, 8, 0, 0.05)

                    x, y, w, h = obj[3]
                    # print('obj',obj[3])
                    cv2.putText(imgContours2, '{}cm'.format(nW), (x + 30, y - 10), cv2.FONT_HERSHEY_COMPLEX_SMALL, 1.5,
                            (255, 0,0), 2)
                    cv2.putText(imgContours2, '{}cm'.format(nH), (x - 70, y + h // 2), cv2.FONT_HERSHEY_COMPLEX_SMALL, 1.5,
                            (0,0,0), 2)
                    cv2.putText(imgContours2, '{}cm'.format(n3), (x +30 , y+h  ), cv2.FONT_HERSHEY_COMPLEX_SMALL, 1.5,
                            (0, 0, 255), 2)
                    

                elif(flag==3):

                    # print("triangle")
                    nW = round((utlis.findDis(nPoints[0][0]//scale,nPoints[1][0]//scale)/10),1)
                    nH = round((utlis.findDis(nPoints[0][0]//scale,nPoints[2][0]//scale)/10),1)
                    n3 = round((utlis.findDis(nPoints[1][0]//scale,nPoints[2][0]//scale)/10),1)
                    # print(nW,nH,n3)
                    cv2.arrowedLine(imgContours2, (nPoints[0][0][0], nPoints[0][0][1]), (nPoints[1][0][0], nPoints[1][0][1]),
                                    (255, 0, 0), 3, 8, 0, 0.05)
                    cv2.arrowedLine(imgContours2, (nPoints[0][0][0], nPoints[0][0][1]), (nPoints[2][0][0], nPoints[2][0][1]),
                                    (0,0,0), 3, 8, 0, 0.05)
                    cv2.arrowedLine(imgContours2, (nPoints[1][0][0], nPoints[1][0][1]), (nPoints[2][0][0], nPoints[2][0][1]),
                                    (0, 0, 255), 3, 8, 0, 0.05)


                    ax = round((nPoints[0][0][0] + nPoints[1][0][0])/2)
                    ay = round((nPoints[0][0][1] + nPoints[1][0][1])/2)
                    bx = round((nPoints[0][0][0] + nPoints[2][0][0])/2)
                    by = round((nPoints[0][0][1] + nPoints[2][0][1])/2)
                    cx = round((nPoints[1][0][0] + nPoints[2][0][0])/2)
                    cy = round((nPoints[1][0][1] + nPoints[2][0][1])/2)
                    
                    
                    # print('obj',obj[3])
                    cv2.putText(imgContours2, '{}cm'.format(nW), (ax, ay), cv2.FONT_HERSHEY_COMPLEX_SMALL, 1.5,
                                (255, 0,0), 2)
                    cv2.putText(imgContours2, '{}cm'.format(nH), (bx, by), cv2.FONT_HERSHEY_COMPLEX_SMALL, 1.5,
                                (0,0,0), 2)
                    cv2.putText(imgContours2, '{}cm'.format(n3), (cx ,cy), cv2.FONT_HERSHEY_COMPLEX_SMALL, 1.5,
                                (0, 0, 255), 2)
                    
                else:
                    print("error in flag")
                    

            dim = [nW,nH,n3]
        cv2.imwrite(
            'com/result.jpg', imgContours2)
        return dim
    




if __name__ == '__main__':
    dim = cal_dim()  # for local development
    print(dim)
