# ⚠ This is a WIP and I am still learning.

# godot-biome-generator
Generate Biomes for your games in a few clicks

## How is Terrain Generation working?
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
  `indices_array.length = length x breadth * 6`
    - For a 1x1 quad, there will be 6 indices.
    - Pseudo code for creating the indices array:
      - `vertex_index` is nothing but the indices in the range of `len(vertices_array)`
      - `triangle_index` is the index at which the vertex_index will be stored in the indices array
      - `width` is nothing but len(length)
        ```
        triangle_point = 0
        vertex_index = 0

        for z in len(breadth):
            for x in len(length):

                # create quad using 2 triangles (6 vertices, 3 for each triangle)
                # 1st △
                indices[triangle_point+0] = vertex_index
                indices[triangle_point+1] = vertex_index + 1
                indices[triangle_point+2] = vertex_index + width + 1
                # 2nd △
                indices[triangle_point+4] = vertex_index + width + 2
                indices[triangle_point+3] = vertex_index + 1
                indices[triangle_point+5] = vertex_index + width + 1

                # increment triangle point by 6, to generate the next quad.
                triangle_point += 6
                # increment the vertex_index in order to do all the above operations starting from the next vertex
                vertex_index += 1 

            # before going to the next row increment the vertex again in order to avoid
            # back face culling between the ending vertex of the current row with the next row.
            vertex_index += 1
        ```
        ```
        (i + width + 1) (i + width + 2)
                    • --- •  
                    |  \  |     
                    • --- •
                   (i)  (i+1)
        ```
  - Hence, when the engine will be building the mesh, it may follow something along these lines of instructions:
      ```
      for index in indices/triangles:
          vertex_to_render = vertices[index]
          render_vertex(vertex_to_render)
      ```

## How is LOD system working?
1. A chunk_size is selected, which will makeup the terrain size by substituting `length` and `breadth` as `chunk_size`.
    - Hence, `terrain_size = length x breadth = (chunk_size)²`
    
2. The `chunk_size` is selected such that certain numbers of factors for `chunk_size-1` can be obtained,
    - E.G. The `chunk_size=9`, then `chunk_size-1=8`
    - The numbers, 1,2,4,8 are factors of 8
    - Hence we can have  4 `LODs` for this `chunk_size=9`
    - `LOD_1=1`, `LOD_2=2`, `LOD_3=4`, `LOD_4=8`

3. How can this LOD_n help us?
    - It helps to choose how many vertices and which vertices to consider while building the mesh.
    - For each `LOD_n=x`, we can add every xth vertex to the vertices array of the mesh.
    - E.G. if `LOD_1=2`, we take every 2nd vertex and add it to the vertices array.
    - Pseudo code for `LOD_1=2`
        ```
        for x in (length_of_the_map, increment=x+LOD_1):
            for z in (width_of_the_map, increment=x+LOD_1):
                add_to_mesh_array(Vector3(x,0,z))
        ```
    - For LOD_n > 0 (take 1 if LOD_n = 0)
        - This means the total number of vertices to be rendered per line (row) can be given my `(chunk_size - 1 /LOD_n) + 1`
        - we can call this `mesh_simplification_increment`
    - ![LOD_explanation](https://github.com/1MochaChan1/godot-biome-generator/assets/74943095/ff1f35de-e8d1-4569-8656-cd486b66d430)


4. What after we get the vertices? How do we make the indices/triangles array?
    - The process will be the exact same except, instead of using the `width` (i.e. length, supposing we're iterating through breadth first.) we can make use of `mesh_simplification_increment`
