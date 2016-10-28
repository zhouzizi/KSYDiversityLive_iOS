//
//  KSYFUFilter.m
//  faceunitTest
//
//  Created by 孙健 on 16/10/1.
//  Copyright © 2016年 孙健. All rights reserved.
//

#import "KSYFUFilter.h"
#include <sys/mman.h>
#include <sys/stat.h>
#include "funama.h"

@implementation KSYFUFilter

- (id)init{
    intptr_t size = 0;
    void* v2data = mmap_bundle(@"v2.bundle", &size);
    void* ardata = mmap_bundle(@"ar.bundle", &size);
    fuInit(v2data, ardata);
    [self fuReloadItem];
    [GPUImageContext  useImageProcessingContext];
    GLuint itex = [self newTexutre];
    GLuint otex = fuRenderItems(itex, NULL,
                          (int)firstInputFramebuffer.size.width,
                          (int)firstInputFramebuffer.size.height,
                          g_frame_id, g_items, 1);
    NSLog(@"new %d %d", itex, otex);
    glBindTexture(GL_TEXTURE_2D, 0);
    glDeleteTextures(1, &itex);
    if (!(self = [super init])) {
        return nil;
    }
    return self;
}

- (GLuint) newTexutre{
    GLuint _texture;
    glActiveTexture(GL_TEXTURE1);
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    // This is necessary for non-power-of-two textures
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    return _texture;
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    GPUImageFramebufferCache * shareCache = [GPUImageContext sharedFramebufferCache];
    outputFramebuffer = [shareCache fetchFramebufferForSize:[self sizeOfFBO]
                                             textureOptions: self.outputTextureOptions
                                                onlyTexture: NO];
    [outputFramebuffer activateFramebuffer];
    GLuint itex = [firstInputFramebuffer texture];
    GLuint otex = [outputFramebuffer texture];
    CGSize sz   = outputFramebuffer.size;
    fuRenderItemsEx(FU_FORMAT_RGBA_TEXTURE,&otex,
                    FU_FORMAT_RGBA_TEXTURE,&itex,
                    (int)sz.width, (int)sz.height,
                    g_frame_id, g_items, 1);
    
    g_frame_id++;
    NSLog(@"%5d: %d %d",g_frame_id, itex, otex);
    [firstInputFramebuffer unlock];
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

- (void)TrenderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates{
    
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    GLuint itex = [firstInputFramebuffer texture];
    GLuint otex = [firstInputFramebuffer texture];
    
    
    //渲染贴纸纹理
    static int cnt = 0;
    cnt++;
    if (cnt > 0 ){
        //[GPUImageContext useImageProcessingContext];
//        itex = [self newTexutre];
        otex =  fuRenderItems(itex, NULL,
                              (int)firstInputFramebuffer.size.width,
                              (int)firstInputFramebuffer.size.height,
                              g_frame_id, g_items, 1);
        
//        fuRenderItemsEx(FU_FORMAT_GL_CURRENT_FRAMEBUFFER,NULL,
//                        FU_FORMAT_RGBA_TEXTURE,&itex,
//                        (int)firstInputFramebuffer.size.width,
//                        (int)firstInputFramebuffer.size.height,
//                        g_frame_id, g_items, 1);
//        otex = itex;
        g_frame_id++;
        //[GPUImageContext useImageProcessingContext];
        NSLog(@"run %d %d", itex, otex);
//        cnt = -100;
    }
    [GPUImageContext setActiveShaderProgram:filterProgram];
    
    //EAGLContext *imageProcessingContext = [[GPUImageContext sharedImageProcessingContext] context];
    EAGLContext * curctx = [EAGLContext currentContext];
    NSLog(@"ctx %@ in %d  out %d", curctx, itex, otex);
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    
    glBindTexture(GL_TEXTURE_2D, otex);

    glUniform1i(filterInputTextureUniform, 2);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glBindTexture(GL_TEXTURE_2D, 0);

    
    [firstInputFramebuffer unlock];
    
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }

}
//------------faceunity-------------//
// Global variables for Faceunity
//  Global flags
static EAGLContext* g_gl_context = nil;   // GL context to draw item
static int g_frame_id = 0;
static int g_selected_item = 1;
//  Predefined items and maintenance
static NSString* g_item_names[] = {@"kitty.bundle", @"fox.bundle", @"evil.bundle", @"eyeballs.bundle", @"mood.bundle", @"tears.bundle", @"rabbit.bundle", @"cat.bundle"};
static const int g_item_num = sizeof(g_item_names) / sizeof(NSString*);
static void* g_mmap_pointers[g_item_num] = {NULL};
static intptr_t g_mmap_sizes[g_item_num] = {0};
static int g_items[1] = {0};
static NSString* g_item_hints[] = {@"", @"", @"", @"张开嘴巴", @"嘴角向上以及嘴角向下",  @"张开嘴巴", @"", @""};
// Item loading assistant functions
static size_t osal_GetFileSize(int fd){
    struct stat sb;
    sb.st_size = 0;
    fstat(fd, &sb);
    return (size_t)sb.st_size;
}
static void* mmap_bundle(NSString* fn_bundle,intptr_t* psize){
    // Load item from predefined item bundle
    NSString *str = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fn_bundle];
    const char *fn = [str UTF8String];
    int fd = open(fn,O_RDONLY);
    void* g_res_zip = NULL;
    size_t g_res_size = 0;
    if(fd == -1){
        NSLog(@"faceunity: failed to open bundle");
        g_res_size = 0;
    }else{
        g_res_size = osal_GetFileSize(fd);
        g_res_zip = mmap(NULL, g_res_size, PROT_READ, MAP_SHARED, fd, 0);
        NSLog(@"faceunity: %@ mapped %08x %ld\n", str, (unsigned int)g_res_zip, g_res_size);
    }
    *psize = g_res_size;
    return g_res_zip;
}
- (void)fuReloadItem{
    if(g_items[0]){
        NSLog(@"faceunity: destroy item");
        fuDestroyItem(g_items[0]);
    }
    // load selected
    intptr_t size = g_mmap_sizes[g_selected_item];
    void* data = g_mmap_pointers[g_selected_item];
    if(!data){
        // mmap doesn't consume much hard resources, it should be safe to keep all the pointers around
        data = mmap_bundle(g_item_names[g_selected_item], &size);
        g_mmap_pointers[g_selected_item] = data;
        g_mmap_sizes[g_selected_item] = size;
    }
    // key item creation function call
    g_items[0] = fuCreateItemFromPackage(data, (int)size);
    NSLog(@"faceunity: load item #%d, handle=%d", g_selected_item, g_items[0]);
}

@end
