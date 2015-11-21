//
//  Shader.vsh
//  openglesinc
//
//  Created by Harold Serrano on 2/9/15.
//  Copyright (c) 2015 www.roldie.com. All rights reserved.
//

//1. declare attributes
attribute vec4 position;

//2. declare varying type which will transfer the texture coordinates to the fragment shader
varying mediump vec3 vTexCoordinates;

//3. declare a uniform that contains the model-View-projection
uniform mat4 modelViewProjectionMatrix;


void main()
{

//4. Generate the UV coordinates

vTexCoordinates=normalize(position.xyz);

//5. transform every position vertex by the model-view-projection matrix

gl_Position=modelViewProjectionMatrix * position;
   
//6. Trick to place the skybox behind any other 3D model
    
gl_Position=gl_Position.xyww;

}
