# How to Apply a Skybox (cube map) to a game using OpenGL ES 2.0

## Introduction
A skybox is a panoramic view representing a sky or any other scenery. It is a simple way to add realism to a game with minimal performance cost.

A skybox is generated from a cube. Each face of the cube contains a texture representing a visible view (up, down, front, back, left, right) of the scenery. 

To implement a skybox is quite simple. We simply unwrap a cube into its *UV Map*. Apply a texture to each face of the cube and render the cube in the middle of the scene.

##### Figure 1. Example of a Skybox
![example of skybox](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/blendCubeMap.png "cube map")

### Objective
In this tutorial you will learn how to implement a skybox in a mobile device using OpenGL ES as shown in figure 2. This is a hands on tutorial. Feel free to download this [template Xcode project](https://dl.dropboxusercontent.com/u/107789379/haroldserrano/MakeOpenGLProject/Applying%20a%20skybox%20to%20games/Template-Skeleton.zip) and code along.

##### Figure 2. A Skybox in an iOS device
![iphone with skybox](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/skyboxiOS.png "skybox iOS") 


### Things to know
In order to get the most out of this tutorial, I suggest to read these tutorials before hand:

* [How to render a 3D model](http://www.haroldserrano.com/blog/how-to-render-a-character-in-ios-devices)
* [How to apply textures to 3D Models](http://www.haroldserrano.com/blog/how-to-apply-textures-to-a-character-in-ios)
* [Using Shaders in Computer Graphics](http://www.haroldserrano.com/blog/what-is-a-shader-in-computer-graphics)

## Implementing a skybox
In order to render a skybox we need to do the following:

* Load the vertices of a cube into OpenGL buffers 
* Load six textures into *texture objects*
* Render the cube in a scene.

> If you have not done so, please read [Loading data into OpenGL Buffers](http://www.haroldserrano.com/blog/loading-vertex-normal-and-uv-data-onto-opengl-buffers) and [Applying textures to a 3D model](http://www.haroldserrano.com/blog/how-to-apply-textures-to-a-character-in-ios). You will need to know these concepts before moving on.

Our project contains a C++ class called *SkyBox*. Open up the project and locate the file *SkyBox.h* and *SkyBox.mm*. In this C++ class, you will implement the methods necessary to render a skybox in the scene.

### Loading the vertices of the cube
As mentioned earlier, a skybox is simply a cube rendered on a scene. The cube’s vertices are loaded into OpenGL buffers and passed down to shaders. 

> The cube’s vertices have been declared in the array *sky_vertices[]* in the *Sky.h* file.

Open up the *SkyBox.mm* file and locate the method *setupOpenGL()*. Lines 1-13 perform the necessary operations to load the cube vertices into the buffer. If these operations are no familiar to you, please read [Loading data into OpenGL Buffers](http://www.haroldserrano.com/blog/loading-vertex-normal-and-uv-data-onto-opengl-buffers).

### Loading the textures into a texture object

Lines 14-18 in the *setupOpenGL()* method is the section which you will implement. It is the section responsible for activating a *texture unit*, creating a *texture object* and loading the textures for the skybox.

Go to the *setupOpenGL()* method. Locate line 14 and copy what is shown in listing 1.

##### Listing 1. Loading the images into texture objects
<pre>
<code class=“language-c”>
void SkyBox::setupOpenGL(){

//…

 //14. Activate GL_TEXTURE0
 glActiveTexture(GL_TEXTURE0);

//15.a Generate a texture buffer
glGenTextures(1, &textureID[0]);

//16. Bind texture0
glBindTexture(GL_TEXTURE_CUBE_MAP, textureID[0]);

//17. Simple For loop to get each image reference

for(int i=0; i&ltcubeMapTextures.size(); i++) {

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
	
//…
}

</code>
</pre>

Our first task is to activate a *texture unit* as shown in line 1. A *texture unit* is the section in the GPU responsible for texturing operations.

Lines 15 & 16 simply create and bind a texture object. However, the texture object’s behavior is set to behave as if it is carrying a cube map image instead of a 2D image (line 16).

Since we have six images to load, we setup a simple *For* loop (line 17). Each image is decompressed into raw-format and their texture parameters set (lines 17a & 17b).

> The reference to each image is stored in a C++ vector as shown in the *SkyBox()* constructor line 1.

The skybox requires an image for each face of the cube. During the loading of these images, how do we link an image to a particular face?

OpenGL provides a set of targets specifically for this purpose. Each face of the cube is represented as follows in OpenGL:

* GL\_TEXTURE\_CUBE\_MAP\_POSITIVE\_X
* GL\_TEXTURE\_CUBE\_MAP\_NEGATIVE\_X
* GL\_TEXTURE\_CUBE\_MAP\_POSITIVE\_Y
* GL\_TEXTURE\_CUBE\_MAP\_NEGATIVE\_Y
* GL\_TEXTURE\_CUBE\_MAP\_POSITIVE\_Z
* GL\_TEXTURE\_CUBE\_MAP\_NEGATIVE\_Z

> Each of these targets is declared in the *cubeMapTarget[]* array in the *SkyBox.h* file.

During the image loading process, we iterate through each of these targets and apply the correct image to a cube face. This is shown in line 17c.

Finally, we get the location of the uniform *Sampler2D* (line 18). This uniform will contain a reference to our texture data in the fragment shader.

### Rendering the skybox

For the skybox to render on the screen, we need to activate the *texture unit*. A *texture unit* holds a reference to our *texture object*. Once the *texture unit* is activated, we bind the *texture object* with the target of *GL\_TEXTURE\_CUBE\_MAP*. Finally we call the *glDrawElements()* function, which will render our skybox.

Open up the *SkyBox.mm* file. Locate the *draw()* method and copy what is shown in lines 3-8 in listing 2.

##### Listing 2. Rendering the skybox
<pre>
<code class=“language-c”>

void SkyBox::draw(){

//…

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

//…

}

</code>
</pre>

The *texture unit* is activated in line 3. The binding of the *texture object* occurs in line 4 and finally we start the rendering in line 7.

A skybox appears to always be rendered behind any other object in a scene. For this to occur we need to compare the incoming pixel-depth with the currently present in the frame buffer. 

In line 6 we use the depth test condition of *GL\_LEQUAL*. This allows the skybox to be render behind any other object in the scene. Line 7 renders the skybox as usual. The depth condition is then set to the default condition of *GL\_LESS*, which allows objects to be render in front of any other in the scene (line 8).

> The depth comparison is performed only if depth testing is enabled. This is set in the constructor method line 3.

### Implementing the vertex shader
We will now implement the vertex shader for the skybox. Open up the *SkyShader.vsh* file and copy what is shown in listing 3.

##### Listing 3. Implementing the Vertex Shader 
<pre>
<code class=“language-c”>

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
</code>
</pre>

You may have noticed that we never loaded *UV* coordinates into our OpenGL buffers in method *setupOpenGL()*. Loading *UV* coordinates is required when applying a texture to a 3D model, but they are not required when implementing a skybox.

Instead of loading *UV* coordinates into OpenGL buffers, we simply generate them in the vertex shader. The *UV* coordinates are simply the normalize vertex locations as shown in line 4.

As state before, one of the characteristics of a skybox is that it always appears to be rendered behind any other object in a scene. This is simply a trick that is performed by setting the *z* component of the vertex shader output, *gl\_Position*, equal to the homogeneous coordinate *w* as shown in line 6.

### Implementing the fragment shader
Implementing the fragment shader is very simple. It is very similar to the fragment shader implemented when a texture is applied to a 3D model.

The only difference is that the texture is sampled using the function *textureCube()* instead of *texture2D()* as shown in line 3.

Open up file *SkyShader.fsh*. Copy what is shown in listing 4.

##### Listing 4. Implementing the Fragment Shader

<pre>
<code class=“language-c”>

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

</code>
</pre>

### Creating an instance of the Skybox
We are almost done. We need to create an instance of the *SkyBox* class and call its *setupOpenGL()* method. 

Open up the *ViewController.mm* file. Locate method *viewDidLoad* and head to line 8. Copy what is shown in listing 5.

##### Listing 5. Create an instance of SkyBox

<pre>
<code class=“language-c”>
(void)viewDidLoad
{

//…

//8. create the Skybox class instance
skyBox=new SkyBox( "LeftImage.png","RightImage.png", "TopImage.png","BottomImage.png", "FrontImage.png", "BackImage.png",self.view.bounds.size.height,self.view.bounds.size.width);

//9. Begin the OpenGL setup for the skybox
skyBox->setupOpenGL();

//…

}
</code>
</pre>

In line 8 we simply create an instance of the *SkyBox* class and provide the name of the images which will be used. Line 9 simply starts the openGL setup operations.

## Final Result

Run the project. You should now see a skybox loaded on your mobile device. Swipe your fingers horizontally across the screen. You should be able to navigate through the skybox.

![iphone with skybox](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/skyboxiOS.png "skybox iOS") 

>Bonus: If you want to see a character rendered in the skybox, simply uncomment line 3 in the *glkView()* method in the *ViewController.mm* file as shown in listing 6.

#####Listing 6. Rendering a 3D model in the skybox
<pre>
<code class=“language-c”>
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
//...

//3. Render the character
character->draw();

//...
}
</code>
</pre>

###Credits
[Harold Serrano](http://www.haroldserrano.com) Author of this repository and post

###Questions
If you have any questions about this repository, feel free to contact me at http://www.haroldserrano.com/contact/

