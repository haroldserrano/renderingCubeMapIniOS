//
//  Character.mm
//  OpenGL_Template_CPLUSPLUS
//
//  Created by Harold Serrano on 7/25/14.
//  Copyright (c) 2015 www.roldie.com. All rights reserved.
//

#include "SkyBox.h"
#include "lodepng.h"
#include <vector>
#include "Sky.h"

static GLubyte shaderText[MAX_SHADER_LENGTH];

SkyBox::SkyBox(const char* rightImage,const char* leftImage,const char* topImage,const char* BottomImage,const char* frontImage,const char* backImage,float uScreenWidth,float uScreenHeight){
    
    //1. load each texture image reference into a vector
    cubeMapTextures.push_back(rightImage);
    cubeMapTextures.push_back(leftImage);
    cubeMapTextures.push_back(topImage);
    cubeMapTextures.push_back(BottomImage);
    cubeMapTextures.push_back(frontImage);
    cubeMapTextures.push_back(backImage);
    
    //2. set the width and heigh of the device
    screenWidth=uScreenWidth;
    screenHeight=uScreenHeight;
    
    //3. Enable Depth Testing
    glEnable(GL_DEPTH_TEST);
    
}

void SkyBox::setupOpenGL(){
    
    //load the shaders, compile them and link them
    
    loadShaders("SkyShader.vsh", "SkyShader.fsh");
    
    //1. Generate a Vertex Array Object
    
    glGenVertexArraysOES(1,&vertexArrayObject);
    
    //2. Bind the Vertex Array Object
    
    glBindVertexArrayOES(vertexArrayObject);
    
    //3. Generate a Vertex Buffer Object
    
    glGenBuffers(1, &vertexBufferObject);
    
    //4. Bind the Vertex Buffer Object
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferObject);
    
    //5. Dump the data into the Buffer
    /* Read "Loading data into OpenGL Buffers" if not familiar with loading data
    using glBufferSubData.
    http://www.www.roldie.com/blog/loading-vertex-normal-and-uv-data-onto-opengl-buffers
    */
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(sky_vertices), NULL, GL_STATIC_DRAW);
    
    //5a. Load vertex data with glBufferSubData
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(sky_vertices), sky_vertices);
    
    
    //6. Get the location of the shader attribute called "position"
    
    positionLocation=glGetAttribLocation(programObject, "position");
    
    
    //8. Enable attribute locations
    
    //8a. Enable the position attribute
    glEnableVertexAttribArray(positionLocation);
    
    //9. Link the buffer data to the shader attribute locations
    
    //9a. Link the buffer data to the shader's position location
    glVertexAttribPointer(positionLocation, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid *) 0);

    
    //10. Get Location of uniform
    modelViewProjectionUniformLocation = glGetUniformLocation(programObject,"modelViewProjectionMatrix");
    
    
    /*Since we are going to start the rendering process by using glDrawElements
     We are going to create a buffer for the indices. Read "Starting the rendering process in OpenGL"
     if not familiar. http://www.www.roldie.com/blog/starting-the-primitive-rendering-process-in-opengl */
    
    //11. Create a new buffer for the indices
    GLuint elementBuffer;
    glGenBuffers(1, &elementBuffer);
    
    //12. Bind the new buffer to binding point GL_ELEMENT_ARRAY_BUFFER
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementBuffer);
    
    //13. Load the buffer with the indices found in smallHouse1_index array
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(sky_index), sky_index, GL_STATIC_DRAW);
    
    
    //14. Activate GL_TEXTURE0
    glActiveTexture(GL_TEXTURE0);
    
    //15.a Generate a texture buffer
    glGenTextures(1, &textureID[0]);
    
    //16. Bind texture0
    glBindTexture(GL_TEXTURE_CUBE_MAP, textureID[0]);
    
    //17. Simple For loop to get each image reference
    
    for (int i=0; i<cubeMapTextures.size(); i++) {
        
        //17a.Decode each cube map image into its raw image data.
        if(convertImageToRawImage(cubeMapTextures.at(i))){
        
        //17b. if decompression was successful, set the texture parameters
            
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        //17c. load the image data into the current bound texture buffer
        //cubeMapTarget[] contains the cube map targets
        glTexImage2D(cubeMapTarget[i], 0, GL_RGBA, imageWidth, imageHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, &image[0]);
        
        }
        
        image.clear();
    }
    
    //18. Get the location of the Uniform Sampler2D
    UVMapUniformLocation=glGetUniformLocation(programObject, "SkyBoxTexture");
    
    //19. Unbind the VAO
    glBindVertexArrayOES(0);
    
    setTransformation();
}

void SkyBox::update(float dt){
    
    //1. Rotate the model space by "dt" degrees about the vertical axis
    modelSpace=GLKMatrix4Rotate(modelSpace, dt, 0.0, 1.0, 0.0);
    
    
    //2. Transform the model space to the world space
    modelWorldSpace=GLKMatrix4Multiply(worldSpace,modelSpace);
    
    
    //3. Transform the model-World Space by the View space
    modelWorldViewSpace = GLKMatrix4Multiply(cameraViewSpace, modelWorldSpace);
    
    
    //4. Transform the model-world-view space to the projection space
    modelWorldViewProjectionSpace = GLKMatrix4Multiply(projectionSpace, modelWorldViewSpace);
    
    
    //5. Assign the model-world-view-projection matrix data to the uniform location:modelviewProjectionUniformLocation
    glUniformMatrix4fv(modelViewProjectionUniformLocation, 1, 0, modelWorldViewProjectionSpace.m);
    
    
}

void SkyBox::draw(){
    
    //1. Set the shader program
    glUseProgram(programObject);
    
    //2. Bind the VAO
    glBindVertexArrayOES(vertexArrayObject);
   
    //3. Activate the texture unit
    glActiveTexture(GL_TEXTURE0);
    
    //4 Bind the texture object
    glBindTexture(GL_TEXTURE_CUBE_MAP, textureID[0]);
    
    //5. Specify the value of the UV Map uniform
    glUniform1i(UVMapUniformLocation, 0);
    
    //6. draw the pixels if the incoming depth value is less than or equal to the stored depth value.
    glDepthFunc(GL_LEQUAL);
    
    //7. Start the rendering process
    glDrawElements(GL_TRIANGLES, sizeof(sky_index)/4, GL_UNSIGNED_INT,(void*)0);

    
    //8. draw the pixels if the incoming depth value is less than the stored depth value
    glDepthFunc(GL_LESS);
    
    //9. Disable the VAO
    glBindVertexArrayOES(0);
    
}



void SkyBox::setTransformation(){
    
    //1. Set up the model space
    modelSpace=GLKMatrix4Identity;
    
    
    //4. Set up the world space
    worldSpace=GLKMatrix4Identity;
    
    //5. Transform the model space to the world space
    modelWorldSpace=GLKMatrix4Multiply(worldSpace,modelSpace);
    
    
    //6. Set up the view space. We are translating the view space 0 unit down and 5 units out of the screen.
    cameraViewSpace =GLKMatrix4MakeTranslation(0.0f, 0.5f, -0.5f);
    
    //cameraViewSpace=GLKMatrix4RotateX(cameraViewSpace, GLKMathDegreesToRadians(30.0f));
    //7. Transform the model-World Space by the View space
    modelWorldViewSpace = GLKMatrix4Multiply(cameraViewSpace, modelWorldSpace);
    
    
    //8. set the Projection-Perspective space with a 45 degree field of view and an aspect ratio
    //of width/heigh. The near a far clipping planes are set to 0.1 and 100.0 respectively
    projectionSpace = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(80.0f), fabsf(screenWidth/screenHeight), 0.1f, 1000.0f);
    
    
    //9. Transform the model-world-view space to the projection space
    modelWorldViewProjectionSpace = GLKMatrix4Multiply(projectionSpace, modelWorldViewSpace);
    
    
    //10. Assign the model-world-view-projection matrix data to the uniform location:modelviewProjectionUniformLocation
    glUniformMatrix4fv(modelViewProjectionUniformLocation, 1, 0, modelWorldViewProjectionSpace.m);
    
    
}

bool SkyBox::convertImageToRawImage(const char *uTexture){
    
    bool success=false;
    
    //The method decode() is the method rensponsible for decompressing the formated image.
    //The result is stored in "image".
    
    unsigned error = lodepng::decode(image, imageWidth, imageHeight,uTexture);
    
    //if there's an error, display it
    if(error){
        
        cout << "Couldn't decode the image. decoder error " << error << ": " << lodepng_error_text(error) << std::endl;
        
    }else{
        
        //Flip and invert the image
        unsigned char* imagePtr=&image[0];
        
        int halfTheHeightInPixels=imageHeight/2;
        int heightInPixels=imageHeight;
        
        
        //Assume RGBA for 4 components per pixel
        int numColorComponents=4;
        
        //Assuming each color component is an unsigned char
        int widthInChars=imageWidth*numColorComponents;
        
        unsigned char *top=NULL;
        unsigned char *bottom=NULL;
        unsigned char temp=0;
        
        for( int h = 0; h < halfTheHeightInPixels; ++h )
        {
            top = imagePtr + h * widthInChars;
            bottom = imagePtr + (heightInPixels - h - 1) * widthInChars;
            
            for( int w = 0; w < widthInChars; ++w )
            {
                // Swap the chars around.
                temp = *top;
                *top = *bottom;
                *bottom = temp;
                
                ++top;
                ++bottom;
            }
        }
        
        success=true;
    }
    
    return success;
}



void SkyBox::loadShaders(const char* uVertexShaderProgram, const char* uFragmentShaderProgram){
    
    // Temporary Shader objects
    GLuint VertexShader;
    GLuint FragmentShader;
    
    //1. Create shader objects
    VertexShader = glCreateShader(GL_VERTEX_SHADER);
    FragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
	
    
    //2. Load both vertex & fragment shader files
    
    //2a. Usually you want to check the return value of the loadShaderFile function, if
    //it returns true, then the shaders were found, else there was an error.
    
    
    if(loadShaderFile(uVertexShaderProgram, VertexShader)==false){
        
        glDeleteShader(VertexShader);
        glDeleteShader(FragmentShader);
        fprintf(stderr, "The shader at %s could not be found.\n", uVertexShaderProgram);
        
    }else{
        
        fprintf(stderr,"Vertex Shader was loaded successfully\n");
        
    }
    
    if(loadShaderFile(uFragmentShaderProgram, FragmentShader)==false){
        
        glDeleteShader(VertexShader);
        glDeleteShader(FragmentShader);
        fprintf(stderr, "The shader at %s could not be found.\n", uFragmentShaderProgram);
    }else{
        
        fprintf(stderr,"Fragment Shader was loaded successfully\n");
        
    }
    
    //3. Compile both shader objects
    glCompileShader(VertexShader);
    glCompileShader(FragmentShader);
    
    //3a. Check for errors in the compilation
    GLint testVal;
    
    //3b. Check if vertex shader object compiled successfully
    glGetShaderiv(VertexShader, GL_COMPILE_STATUS, &testVal);
    if(testVal == GL_FALSE)
    {
        char infoLog[1024];
        glGetShaderInfoLog(VertexShader, 1024, NULL, infoLog);
        fprintf(stderr, "The shader at %s failed to compile with the following error:\n%s\n", uVertexShaderProgram, infoLog);
        glDeleteShader(VertexShader);
        glDeleteShader(FragmentShader);
        
    }else{
        fprintf(stderr,"Vertex Shader compiled successfully\n");
    }
    
    //3c. Check if fragment shader object compiled successfully
    glGetShaderiv(FragmentShader, GL_COMPILE_STATUS, &testVal);
    if(testVal == GL_FALSE)
    {
        char infoLog[1024];
        glGetShaderInfoLog(FragmentShader, 1024, NULL, infoLog);
        fprintf(stderr, "The shader at %s failed to compile with the following error:\n%s\n", uFragmentShaderProgram, infoLog);
        glDeleteShader(VertexShader);
        glDeleteShader(FragmentShader);
        
    }else{
        fprintf(stderr,"Fragment Shader compiled successfully\n");
    }

    
    //4. Create a shader program object
    programObject = glCreateProgram();
    
    //5. Attach the shader objects to the shader program object
    glAttachShader(programObject, VertexShader);
    glAttachShader(programObject, FragmentShader);
    
    //6. Link both shader objects to the program object
    glLinkProgram(programObject);
    
    //6a. Make sure link had no errors
    glGetProgramiv(programObject, GL_LINK_STATUS, &testVal);
    if(testVal == GL_FALSE)
    {
        char infoLog[1024];
        glGetProgramInfoLog(programObject, 1024, NULL, infoLog);
        fprintf(stderr,"The programs %s and %s failed to link with the following errors:\n%s\n",
                uVertexShaderProgram, uFragmentShaderProgram, infoLog);
        glDeleteProgram(programObject);
        
    }else{
        fprintf(stderr,"Shaders linked successfully\n");
    }
    
	
    // These are no longer needed
    glDeleteShader(VertexShader);
    glDeleteShader(FragmentShader);
    
    //7. Use the program
    glUseProgram(programObject);
}


#pragma mark - Load, compile and link shaders to program

bool SkyBox::loadShaderFile(const char *szFile, GLuint shader)
{
    GLint shaderLength = 0;
    FILE *fp;
	
    // Open the shader file
    fp = fopen(szFile, "r");
    if(fp != NULL)
    {
        // See how long the file is
        while (fgetc(fp) != EOF)
            shaderLength++;
		
        // Allocate a block of memory to send in the shader
        //assert(shaderLength < MAX_SHADER_LENGTH);   // make me bigger!
        if(shaderLength > MAX_SHADER_LENGTH)
        {
            fclose(fp);
            return false;
        }
		
        // Go back to beginning of file
        rewind(fp);
		
        // Read the whole file in
        if (shaderText != NULL)
            fread(shaderText, 1, shaderLength, fp);
		
        // Make sure it is null terminated and close the file
        shaderText[shaderLength] = '\0';
        fclose(fp);
    }
    else
        return false;
	
    // Load the string
    loadShaderSrc((const char *)shaderText, shader);
    
    return true;
}

// Load the shader from the source text
void SkyBox::loadShaderSrc(const char *szShaderSrc, GLuint shader)
{
    GLchar *fsStringPtr[1];
    
    fsStringPtr[0] = (GLchar *)szShaderSrc;
    glShaderSource(shader, 1, (const GLchar **)fsStringPtr, NULL);
}

#pragma mark - Tear down of OpenGL
void SkyBox::teadDownOpenGL(){
    
    glDeleteBuffers(1, &vertexBufferObject);
    glDeleteVertexArraysOES(1, &vertexArrayObject);
    
    
    if (programObject) {
        glDeleteProgram(programObject);
        programObject = 0;
        
    }
    
}