//
//  Character.h
//  OpenGL_Template_CPLUSPLUS
//
//  Created by Harold Serrano on 7/25/14.
//  Copyright (c) 2015 www.roldie.com. All rights reserved.
//

#ifndef __OpenGL_Template_CPLUSPLUS__Character__
#define __OpenGL_Template_CPLUSPLUS__Character__

#include <iostream>
#include <math.h>
#include <vector>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define MAX_SHADER_LENGTH   8192

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

#define OPENGL_ES

using namespace std;

class Character{
    
private:
    
    GLuint textureID[16];   //Array for textures
    GLuint programObject;   //program object used to link shaders
    GLuint vertexArrayObject; //Vertex Array Object
    GLuint vertexBufferObject; //Vertex Buffer Object
    
    float aspect; //widthDisplay/heightDisplay ratio
    GLint modelViewProjectionUniformLocation;  //OpenGL location for our MVP uniform
    GLint normalMatrixUniformLocation;  //OpenGL location for the normal matrix
    GLint modelViewUniformLocation; //OpenGL location for the Model-View uniform
    GLint UVMapUniformLocation; //OpenGL location for the Texture Map
    
    //Matrices for several transformation
    GLKMatrix4 projectionSpace;
    GLKMatrix4 cameraViewSpace;
    GLKMatrix4 modelSpace;
    GLKMatrix4 worldSpace;
    GLKMatrix4 modelWorldSpace;
    GLKMatrix4 modelWorldViewSpace;
    GLKMatrix4 modelWorldViewProjectionSpace;
    
    GLKMatrix3 normalMatrix;
    
    float screenWidth;  //Width of current device display
    float screenHeight; //Height of current device display
    
    GLuint positionLocation; //attribute "position" location
    GLuint normalLocation;   //attribute "normal" location
    GLuint uvLocation; //attribute "uv"location
    
    vector<unsigned char> image;
    unsigned int imageWidth, imageHeight;
    
public:
    
    //Constructor
    Character(float uScreenWidth,float uScreenHeight);
    ~Character();
    
    void setupOpenGL(); //Initialize the OpenGL
    void teadDownOpenGL(); //Destroys the OpenGL
    
    //loads the shaders
    void loadShaders(const char* uVertexShaderProgram, const char* uFragmentShaderProgram);
    
    //Set the transformation for the object
    void setTransformation();
    
    //updates the mesh
    void update(float dt);
    
    //draws the mesh
    void draw();
    
    //files used to loading the shader
    bool loadShaderFile(const char *szFile, GLuint shader);
    void loadShaderSrc(const char *szShaderSrc, GLuint shader);
    
    //method to decompress image
    bool convertImageToRawImage(const char *uTexture);
    
    //degree to rad
    inline float degreesToRad(float angle){return (angle*M_PI/180);};
};


#endif /* defined(__OpenGL_Template_CPLUSPLUS__Character__) */
