//
//  Shader.fsh
//  openglesinc
//
//  Created by Harold Serrano on 2/9/15.
//  Copyright (c) 2015 www.roldie.com. All rights reserved.
//
precision highp float;

//1. declare a uniform sampler2d that contains the texture data
uniform sampler2D TextureMap;

//2. declare varying type which will transfer the texture coordinates from the vertex shader
varying mediump vec2 vTexCoordinates;

//3. declare the ambient material color - dark gray
mediump vec4 AmbientMaterialColor=vec4(0.1,0.1,0.1,1.0);

//4. declare the diffuse material color-gray
mediump vec4 DiffuseMaterialColor=vec4(0.5,0.5,0.5,1.0);

//5. declare the specular material color- white
mediump vec4 SpecularMaterialColor=vec4(1.0,1.0,1.0,1.0);

//6. Shininess factor
mediump float Shininess=5.0;

//7. declare varying variable of the light
varying mediump vec4 lightPosition;

//8. declare varying variables that will provide the vertex position in model-view space
varying mediump vec4 positionInViewSpace;

//9. declare varying variables that will provide the normal position in model-view space
varying mediump vec3 normalInViewSpace;

//10. declare a light structure
struct Lights{
    mediump vec3 L; // light direction vector
    lowp float iL; //light illuminance
    float pointLightIntensity; //light intensity
    vec3 pointLightAttenuation; //light attenuation
    vec3 lightColor; //color of the light
    vec4 lightPosition; //position of the light
};

Lights light;

//11. declare the function to compute the light direction vector, illuminance and attenuation
void computePointLightValues(in mediump vec4 surfacePosition);

//12. declare the function to add the ambient+diffuse+specular lights
mediump vec3 addAmbientDiffuseSpecularLights(in mediump vec4 surfacePosition,in mediump vec3 surfaceNormal);

//13. declare the function to compute the light ambient component
mediump vec3 computeAmbientComponent();

//14. declare the function to compute the light diffuse component
mediump vec3 computeDiffuseComponent(in mediump vec3 surfaceNormal);

//15. declare the function to compute the light specular component
mediump vec3 computeSpecularComponent(in mediump vec3 surfaceNormal,in mediump vec4 surfacePosition);


//16. define the function to compute the light direction vector, illuminance and attenuation
void computePointLightValues(in mediump vec4 surfacePosition){
    
    //Compute equation 3.

    //17. compute the light direction vector L
    light.L=light.lightPosition.xyz-surfacePosition.xyz;

    //18. compute the length of the light direction vector
    mediump float dist=length(light.L);

    light.L=light.L/dist;

    //19. compute the attenuation factor. Equation 5.
    //Dot computes the 3-term attenuation in one operation
    //k_c*1.0+K_1*dist+K_q*dist*dist

    mediump float distAtten=dot(light.pointLightAttenuation,vec3(1.0,dist,dist*dist));

    //20. compute the light illuminance
    light.iL=light.pointLightIntensity/distAtten;
    
}

//21. define the function to add the ambient+diffuse+specular lights
mediump vec3 addAmbientDiffuseSpecularLights(in mediump
                               vec4 surfacePosition,in mediump vec3 surfaceNormal){
    
    //22. add all the light components
    return computeAmbientComponent()+computeDiffuseComponent(surfaceNormal)+computeSpecularComponent(surfaceNormal,surfacePosition);

}

//23. define the function to compute the light ambient component
mediump vec3 computeAmbientComponent(){
    
    //24. Compute equation 6.
    //CA=iL*LightAmbientColor*MaterialAmbientColor

    return light.iL*(light.lightColor)*AmbientMaterialColor.xyz;
    
}

//25. define the function to compute the light diffuse component
mediump vec3 computeDiffuseComponent(in mediump vec3 surfaceNormal){
    
    //26. compute equation 7.
    //CD=iL*max(0,dot(LightDirection,SurfanceNormal))*LightDiffuseColor*diffuseMaterial
    return light.iL*max(0.0,dot(surfaceNormal,light.L))*(light.lightColor)*DiffuseMaterialColor.rgb;
    
}

//27. define the function to compute the light specular component
mediump vec3 computeSpecularComponent(in mediump vec3 surfaceNormal,in mediump vec4 surfacePosition){
    
    //28. compute view vector
    mediump vec3 viewVector=normalize(-surfacePosition.xyz);

    //29. compute reflection vector as shown in equation 9
    //r=2*dot(L,n)*n-L
    mediump vec3 reflectionVector=2.0*dot(light.L,surfaceNormal)*surfaceNormal-light.L;

    //30. compute equation 8
    //CS=iL*(max(0,dot(r,v))^m)*LightSpecularColor*specularMaterial
    return (dot(surfaceNormal,light.L)<=0.0)?vec3(0.0,0.0,0.0):(light.iL*(light.lightColor)*SpecularMaterialColor.rgb*pow(max(0.0,dot(reflectionVector,viewVector)),Shininess));
    
}


void main()
{
//31. set point light position
light.lightPosition=lightPosition;

//32. set point light intensity
light.pointLightIntensity=0.2;

//33. set point light attenuation
light.pointLightAttenuation=vec3(1.0,0.0,0.0);

//34. set point light color
light.lightColor=vec3(1.0,1.0,1.0);

//35. initialize color to black
mediump vec4 finalLightColor=vec4(0.0);

finalLightColor.a=1.0;

//36. compute the light direction vector, illuminance and attenuation
computePointLightValues(positionInViewSpace);

//37. compute the ambient, diffuse and specular lights components
finalLightColor.rgb+=vec3(addAmbientDiffuseSpecularLights(positionInViewSpace,normalInViewSpace));

//38. Sample the texture using the Texture map and the texture coordinates
mediump vec4 textureColor=texture2D(TextureMap,vTexCoordinates.st);

//39. Mix the texture color and fragmentColor
mediump vec4 finalMixedColor=mix(textureColor,finalLightColor,0.5);

//40. set the final color to the output of the fragment shader
gl_FragColor = textureColor;
    
}