//
//  Character.mm
//  OpenGL_Template_CPLUSPLUS
//
//  Created by Harold Serrano on 7/25/14.
//  Copyright (c) 2015 www.roldie.com. All rights reserved.
//

#include "Character.h"
#include "lodepng.h"
#include <vector>
#include "SmallHouse.h"

static GLubyte shaderText[MAX_SHADER_LENGTH];

Character::Character(float uScreenWidth,float uScreenHeight){
    
    screenWidth=uScreenWidth;
    screenHeight=uScreenHeight;
}

void Character::setupOpenGL(){
    
    //load the shaders, compile them and link them
    
    loadShaders("Shader.vsh", "Shader.fsh");
    
    glEnable(GL_DEPTH_TEST);
    
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
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(smallHouse1_vertices)+sizeof(smallHouse1_normal)+sizeof(smallHouse1_uv), NULL, GL_STATIC_DRAW);
    
    //5a. Load vertex data with glBufferSubData
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(smallHouse1_vertices), smallHouse1_vertices);
    
    //5b. Load normal data with glBufferSubData
    glBufferSubData(GL_ARRAY_BUFFER, sizeof(smallHouse1_vertices), sizeof(smallHouse1_normal), smallHouse1_normal);
    
    //5c. Load UV coordinates with glBufferSubData
    glBufferSubData(GL_ARRAY_BUFFER, sizeof(smallHouse1_vertices)+sizeof(smallHouse1_normal), sizeof(smallHouse1_uv), smallHouse1_uv);
    
    //6. Get the location of the shader attribute called "position"
    
    positionLocation=glGetAttribLocation(programObject, "position");
    
    //7. Get the location of the shader attribute called "normal"
    
    normalLocation=glGetAttribLocation(programObject, "normal");
    
    //8. Get the location of the shader attribute called "texCoords"
    
    uvLocation=glGetAttribLocation(programObject, "texCoord");
    
    //8. Get Location of uniforms
    modelViewProjectionUniformLocation = glGetUniformLocation(programObject,"modelViewProjectionMatrix");
    
    modelViewUniformLocation=glGetUniformLocation(programObject, "modelViewMatrix");
    
    normalMatrixUniformLocation = glGetUniformLocation(programObject,"normalMatrix");
    
    //9. Enable both attribute locations
    
    //9a. Enable the position attribute
    glEnableVertexAttribArray(positionLocation);

    //9b. Enable the normal attribute
    glEnableVertexAttribArray(normalLocation);
    
    //9c. Enable the UV attribute
    glEnableVertexAttribArray(uvLocation);
    
    //10. Link the buffer data to the shader attribute locations
    
    //10a. Link the buffer data to the shader's position location
    glVertexAttribPointer(positionLocation, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid *) 0);

    //10b. Link the buffer data to the shader's normal location
    glVertexAttribPointer(normalLocation, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)sizeof(smallHouse1_vertices));
    
    //10c. Link the buffer data to the shader's UV location
    glVertexAttribPointer(uvLocation, 2, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)(sizeof(smallHouse1_vertices)+sizeof(smallHouse1_normal)));

    
    /*Since we are going to start the rendering process by using glDrawElements
     We are going to create a buffer for the indices. Read "Starting the rendering process in OpenGL"
     if not familiar. http://www.www.roldie.com/blog/starting-the-primitive-rendering-process-in-opengl */
    
    //11. Create a new buffer for the indices
    GLuint elementBuffer;
    glGenBuffers(1, &elementBuffer);
    
    //12. Bind the new buffer to binding point GL_ELEMENT_ARRAY_BUFFER
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementBuffer);
    
    //13. Load the buffer with the indices found in smallHouse1_index array
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(smallHouse1_index), smallHouse1_index, GL_STATIC_DRAW);
    
    
    //14. Activate GL_TEXTURE0
    glActiveTexture(GL_TEXTURE0);
    
    //15.a Generate a texture buffer
    glGenTextures(1, &textureID[0]);
    
    //16 Bind texture0
    glBindTexture(GL_TEXTURE_2D, textureID[0]);
    
    //17. Decode image into its raw image data. "smallhouse1.png" is our formatted image.
    if(convertImageToRawImage("smallhouse1.png")){
    
    //if decompression was successful, set the texture parameters
        
    //17a. set the texture wrapping parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    //17b. set the texture magnification/minification parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    //17c. load the image data into the current bound texture buffer
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageWidth, imageHeight, 0,
                 GL_RGBA, GL_UNSIGNED_BYTE, &image[0]);
    
    }
    
    //18. Get the location of the Uniform Sampler2D
    UVMapUniformLocation=glGetUniformLocation(programObject, "TextureMap");
    
    //19. Unbind the VAO
    glBindVertexArrayOES(0);
    
    //Sets the transformation
    setTransformation();
    
}

void Character::update(float dt){
    
    //1. Rotate the model space by "dt" degrees about the vertical axis
    modelSpace=GLKMatrix4Rotate(modelSpace, dt, 0.0f, 0.0f, 1.0f);
    
    
    //2. Transform the model space to the world space
    modelWorldSpace=GLKMatrix4Multiply(worldSpace,modelSpace);
    
    
    //3. Transform the model-World Space by the View space
    modelWorldViewSpace = GLKMatrix4Multiply(cameraViewSpace, modelWorldSpace);
    
    
    //4. Transform the model-world-view space to the projection space
    modelWorldViewProjectionSpace = GLKMatrix4Multiply(projectionSpace, modelWorldViewSpace);
    
    //5. extract the 3x3 normal matrix from the model-world-view space for shading(light) purposes
    normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelWorldViewSpace), NULL);
    
    
    //6. Assign the model-world-view-projection matrix data to the uniform location:modelviewProjectionUniformLocation
    glUniformMatrix4fv(modelViewProjectionUniformLocation, 1, 0, modelWorldViewProjectionSpace.m);
    
    //7. Assign the normalMatrix data to the uniform location:normalMatrixUniformLocation
    glUniformMatrix3fv(normalMatrixUniformLocation, 1, 0, normalMatrix.m);
    
    
}

void Character::draw(){
    
    //1. Set the shader program
    glUseProgram(programObject);
    
    //2. Bind the VAO
    glBindVertexArrayOES(vertexArrayObject);
   
    //3. Activate the texture unit
    glActiveTexture(GL_TEXTURE0);
    
    //4 Bind the texture object
    glBindTexture(GL_TEXTURE_2D, textureID[0]);
    
    //5. Specify the value of the UV Map uniform
    glUniform1i(UVMapUniformLocation, 0);
    
    //6. Start the rendering process
    glDrawElements(GL_TRIANGLES, sizeof(smallHouse1_index)/4, GL_UNSIGNED_INT,(void*)0);
    
    //7. Disable the VAO
    glBindVertexArrayOES(0);
    
}



void Character::setTransformation(){
    
    //1. Set up the model space
    modelSpace=GLKMatrix4MakeTranslation(0.0f, 5.0f, -1.5f);
    
    //Since we are importing the model from Blender, we need to change the axis of the model
    //else the model will not show properly. x-axis is left-right, y-axis is coming out the screen, z-axis is up and
    //down
    
    GLKMatrix4 blenderSpace=GLKMatrix4MakeAndTranspose(1,0,0,0,
                                                        0,0,1,0,
                                                        0,-1,0,0,
                                                        0,0,0,1);
    
    //2. Transform the model space by Blender Space
    modelSpace=GLKMatrix4Multiply(blenderSpace, modelSpace);
    
    
    //3. Rotate the model 30 degrees about the z-axis
    modelSpace=GLKMatrix4Rotate(modelSpace, GLKMathDegreesToRadians(30.0f), 0.0f, 0.0f, 1.0f);
    
    //4. Set up the world space
    worldSpace=GLKMatrix4Identity;
    
    //5. Transform the model space to the world space
    modelWorldSpace=GLKMatrix4Multiply(worldSpace,modelSpace);
    
    //6. Set up the view space. We are translating the view space 0 unit down and 5 units out of the screen.
    cameraViewSpace = GLKMatrix4MakeTranslation(0.0f, -0.5f, -8.0f);
    
    
    //7. Transform the model-World Space by the View space
    modelWorldViewSpace = GLKMatrix4Multiply(cameraViewSpace, modelWorldSpace);
    
    
    //8. set the Projection-Perspective space with a 45 degree field of view and an aspect ratio
    //of width/heigh. The near a far clipping planes are set to 0.1 and 100.0 respectively
    projectionSpace = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0f), fabsf(screenWidth/screenHeight), 0.1f, 100.0f);
    
    
    //9. Transform the model-world-view space to the projection space
    modelWorldViewProjectionSpace = GLKMatrix4Multiply(projectionSpace, modelWorldViewSpace);
    
    //10. extract the 3x3 normal matrix from the model-world-view space for shading(light) purposes
    normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelWorldViewSpace), NULL);

    
    //11. Assign the model-world-view-projection matrix data to the uniform location:modelviewProjectionUniformLocation
    glUniformMatrix4fv(modelViewProjectionUniformLocation, 1, 0, modelWorldViewProjectionSpace.m);
    
    //12. Assign the normalMatrix data to the uniform location:normalMatrixUniformLocation
    glUniformMatrix3fv(normalMatrixUniformLocation, 1, 0, normalMatrix.m);
    
    //13. Assign the model-view matrix data to the uniform location:modelViewMatrixUniform
    glUniformMatrix4fv(modelViewUniformLocation, 1, 0, modelWorldViewSpace.m);
    
    
}

bool Character::convertImageToRawImage(const char *uTexture){
    
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



void Character::loadShaders(const char* uVertexShaderProgram, const char* uFragmentShaderProgram){
    
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

bool Character::loadShaderFile(const char *szFile, GLuint shader)
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
void Character::loadShaderSrc(const char *szShaderSrc, GLuint shader)
{
    GLchar *fsStringPtr[1];
    
    fsStringPtr[0] = (GLchar *)szShaderSrc;
    glShaderSource(shader, 1, (const GLchar **)fsStringPtr, NULL);
}

#pragma mark - Tear down of OpenGL
void Character::teadDownOpenGL(){
    
    glDeleteBuffers(1, &vertexBufferObject);
    glDeleteVertexArraysOES(1, &vertexArrayObject);
    
    
    if (programObject) {
        glDeleteProgram(programObject);
        programObject = 0;
        
    }
    
}