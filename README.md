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
As mentioned earlier, a skybox is simply a cube rendered on a scene. The cube’s vertices are loaded into OpenGL buffers and passed down to shaders...Read more about this repository at http://www.haroldserrano.com/blog/how-to-apply-a-skybox-in-opengl
