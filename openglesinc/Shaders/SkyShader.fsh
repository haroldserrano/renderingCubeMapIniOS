//
//  Shader.fsh
//  openglesinc
//
//  Created by Harold Serrano on 2/9/15.
//  Copyright (c) 2015 www.roldie.com. All rights reserved.
//
precision highp float;

//1. declare a uniform sampler2d that contains the texture data
uniform samplerCube SkyBoxTexture;

//2. declare varying type which will transfer the texture coordinates from the vertex shader
varying mediump vec3 vTexCoordinates;

void main()
{

//3. set the final color to the output of the fragment shader
gl_FragColor = textureCube(SkyBoxTexture,vTexCoordinates);
   
}