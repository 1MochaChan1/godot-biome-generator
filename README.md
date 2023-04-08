# ⚠ This is still WIP and I am still learning.

# godot-biome-generator
Generate Biomes for your games in a few clicks

Before we dive in
My system takes in `map_length` and `map_width` as integers.
When I loop through it I use `map_length+1` anad `map_width+1` iterations, this is done because for `length x width` quads to be formed, one extra vertex is required in both dimensions.

For example:
  - length = 1 (1 Quad in x direction)
  - width = 1 (1 Quad in z direction)
  - length x breadth = 1
  - but the number of vertices in the x and the z direction are 2 as per the figure.
  - Hence, it can be derived that:
      1. Number of vertices in x direction is `length+1`
      2. Number of vertices in z directions is `breadth+1`
  ```
    ↑  • --- •  
    |  |     | 
    z  • --- •  
       x ---- →
  ```
  - And for indices/triangles.
      - Each triangle is made up of 3 vertices, and each quad is made up of 2 triangles
      - Hence, each quad is made up of 6 vertices.
      - So we can say that if `total_quads = length x breadth`, then total number of indices required can be given by
          - `total_number_of_indices = total_quads x 6`

  - Why do we need these indices/triangles?
      - Firstly indices array stores the index positions of the vertices that are present in the vertices array in a defined **order**.
      - This order dictates which vertices should be rendered first.
      - For example:

          2     3
          •     •  

          •     •
          0     1
          `vertices_array = [0,1,2,3]`

          - In order to make a quad out of these vertices we will need to create triangles
          - If I connect the points:
              - 0,2,1 △
              - 1,2,3 △
              - I can create two triangles
```
2     3
• --- •  
|  \  |     
• --- •
0     1
```
  - Now the triangles △ 0,2,1 and △ 1,2,3 can be added to the indices/triangles array
  `indices_array = [0,2,1, 1,2,3]`
  - Hence, when the engine will be building the mesh, it may follow something along these lines of instructions:
      ```
      for index in indices/triangles:
          vertex_to_render = vertices[index]
          render_vertex(vertex_to_render)
      ```
            
