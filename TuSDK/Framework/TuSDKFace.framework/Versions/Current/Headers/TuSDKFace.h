//
//  TuSDKFace.h
//  TuSDKFace
//
//  Created by Clear Hu on 16/3/10.
//  Copyright © 2016年 tusdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <CoreMedia/CoreMedia.h>
#import "TuSDKFaceImport.h"

#pragma mark - FaceAligment
/** 人脸对齐信息 (归一百分比) */
@interface TuSDKFaceAligment : NSObject
/** 人脸区域 */
@property (nonatomic) CGRect rect;
/** 对齐信息 */
@property (nonatomic, retain) NSArray<NSValue *> *marks;
@end


#pragma mark - TuSDKFace
/**
 *  人脸检测
 */
@interface TuSDKFace : NSObject
/**
 *  检测人脸并识别
 *
 *  @param image 输入图片 输出图片
 *
 *  @return 返回查找到的人脸
 */
+ (NSArray<TuSDKFaceAligment *> *) markFaceWithImage:(UIImage *)image;

/**
 *  对检测到的人脸进行识别
 *
 *  @param sampleBuffer CMSampleBufferRef
 *  @param rotation     旋转角度
 *  @param faceFeature  人脸位置信息
 *  @param angle        设备旋转角度
 *
 *  @return 返回查找到的人脸
 */
+ (NSArray<TuSDKFaceAligment *> *)markFaceWithSampleBuffer:(CMSampleBufferRef)sampleBuffer
                                                  rotation:(UIImageOrientation)rotation
                                              faceFeatures:(NSArray<TuSDKTSFaceFeature *> *)faceFeatures
                                                     angle:(float)angle;
@end
