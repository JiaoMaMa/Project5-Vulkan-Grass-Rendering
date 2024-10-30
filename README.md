Vulkan Grass Rendering
==================================

**University of Pennsylvania, CIS 565: GPU Programming and Architecture, Project 5**

* Christine Kneer
  * https://www.linkedin.com/in/christine-kneer/
  * https://www.christinekneer.com/
* Tested on: Windows 11, i7-13700HX @ 2.1GHz 32GB, RTX 4060 8GB (Personal Laptop)

## Part 1: Introduction

In this project, I used Vulkan to implement a grass simulator and renderer based on the paper [Responsive Real-Time Grass Grass Rendering for General 3D Scenes](https://www.cg.tuwien.ac.at/research/publications/2017/JAHRMANN-2017-RRTG/JAHRMANN-2017-RRTG-draft.pdf). The paper leverages compute shaders and tesselation to render and simulate physically accurate grass in real time.

<p align="center">
<img width="600" src = "https://github.com/user-attachments/assets/7d5edb52-b6e3-462f-84ae-7de291d6aeb4">
</p>

### Part 1.1: The Grass Blade Model

Based on the paper, grass is represented as Bezier Curve with 3 control points. 

<p align="center">
<img width="350" alt="image" src="https://github.com/user-attachments/assets/af06d0dd-f42e-40b6-97c0-ce662c0169a1">
</p>

Each Bezier curve has three control points.
* `v0`: the position of the grass blade on the geomtry
* `v1`: a Bezier curve guide that is always "above" `v0` with respect to the grass blade's up vector (explained soon)
* `v2`: a physical guide for which we simulate forces on

We also need to store per-blade characteristics that will help us simulate and tessellate our grass blades correctly.
* `up`: the blade's up vector, which corresponds to the normal of the geometry that the grass blade resides on at `v0`
* Orientation: the orientation of the grass blade's face
* Height: the height of the grass blade
* Width: the width of the grass blade's face
* Stiffness coefficient: the stiffness of our grass blade, which will affect the force computations on our blade


### Part 1.2: Simulating Forces

Forces (gravity, recovery, and wind) are applied to Bezier Curve represented grass blades.

|![without](https://github.com/user-attachments/assets/11b952b6-9810-440f-8e23-23e25d61e814)|![with](https://github.com/user-attachments/assets/8cd90295-49af-443b-9b64-cb8183d82b0c)|
|:--:|:--:|
|*Without Physics*|*With Physics*|

### Part 1.3: Culling

In order to further optimize our simulator for real time, we need to cull glass blades that do not need to be rendered due to a variety of reasons.
* **Orientation Culling**: Cull grass blades whose front face direction is perpendicular to the camera's view vector, in which case the blade does not have width.
* **View-Frustrum Culling**: Cull grass blades that are outside of the view-frustum, effectively cannot be seen by the camera.
* **Distance Culling**: Cull grass blades that are far enough that end up smaller than a pixel.

|![ori_cull](https://github.com/user-attachments/assets/3a91c1f4-1ee8-41e2-a8ba-362de6151707)|![view_cull](https://github.com/user-attachments/assets/379cff28-624f-42b5-973f-4bf8c623eb3e)|![dist_cull](https://github.com/user-attachments/assets/a6800bb9-f259-447c-b91f-505b2f5ec2bb)|
|:--:|:--:|:--:|
|*Orientation Culling*|*View Frustrum Culling*|*Distance Culling*|

**Note**: The above demos were produced with enhanced parameters to better showcase the features.

### Part 1.4: Tesselation

Finally, Bezier Curves need to be tesselated into polygons to be processed by the grass graphics pipeline. In this simulator, I chose to tesselate into trangles. The tesselation level is a function of how far the grass blade is from the camera, because further objects require fewer details to be represented accurately.

|![LOD](https://github.com/user-attachments/assets/1feb473a-29e5-44d5-bdd9-89951feea74a)|
|:--:|
|*Dynamic LOD*|

**Note**: The above demo was produced with enhanced parameters to better showcase the feature.

## Part 2: Performance Analysis

In this part, we discuss the performance of our simulator under different performance improvement techiniques.

### Part 2.1: Culling vs # of Grass Blades

|![chart (4)](https://github.com/user-attachments/assets/3b0d9f37-a470-40d6-8a67-9e8e8d784420)|
|:--:|
|*Hardcoded Tesselation Level = 8*|

As the number of grass blades increases, the FPS of both with & without culling significantly drops. This is expected since more blades equates to more computational workload in the compute shader. However, it can be seen from the digram above that there is a consistent performance boost associated with using culling. Culling effectively reduces the amount of work.

It is also interesting to note that the performance benifit introduced by culling is more significant as the number of grass blades increases. This may not be straightforward from the graph itself. 

At **2^10** number of blades, culling increases the FPS from 2300 to 2850. At **2^18** number of blades, culling inreases the FPS from 26 to 48. At first glance, a 550 FPS increase looks more prominent than a 22 FPS increase. However, the relative impact of the FPS gain is more meaningful in lower FPS scenarios.

Here's the math to clarify:
* At 2300 FPS, the frame time is approximately 1/2300 = 0.435 ms.
* At 2850 FPS, the frame time is approximately 1/2850 = 0.351 ms.
* **The difference in frame time is 0.435 − 0.351 = 0.084 ms, which is very small.**

Now, consider the case of **lower FPS**:
* At 26 FPS, the frame time is approaximately 1/26 = 38.46 ms.
* At 48 FPS, the frame time is approximately 1/48 = 20.83 ms.
* **The difference in frame time is a whopping 38.46 - 20.83 = 17.63 ms, which is MUCH larger.**

This means that culling is more substantial as the number of grass blades increases, which is also expected since more blades means that we will probably cull more blades as well.

### Part 2.2: Culling Methods

As discussed in part 2.2, culling is more substantial at hight number of grass blades, so let us now compare the three different culling methods at 2^18 grass blades.

|![chart (5)](https://github.com/user-attachments/assets/b6006729-b663-4c6e-823a-df1b60456c39)|
|:--:|
|*2^18 Grass Blades, Hardcoded Tesselation Level = 8*|

As seen from the graph above, all three culling methods introduces some performance boost, to different extent. View-frustrum culling seems to have less of an impact compared to orientation and distance culling, but the three combined results in the best performance. This is also expected since each culling method culls blades according to different criteria, and the three combined would cull the most blades. 

However, it should be noted that the above test is not sound since each culling method has tunable parameters. Admittedly, these parameters and the camera position & orientation would definitely have an impact on how much performance is increased.
