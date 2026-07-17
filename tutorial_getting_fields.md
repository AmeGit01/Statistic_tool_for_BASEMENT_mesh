# How to get the necessary fields within QGIS
Ones you have uploaded your basement mesh (2dm format) in QGIS, you can vectorize it opening the processing toolbox and typing ````mesh to faces````. Then you enter the input layer (the mesh.2dm), select the desired dataset groups (I suggest all of them), select the coordinate system and the output layer name and location. Once tou have the vector layer with the mesh you can open the attribute table, enabling the editing mode and open the field calculator and start creating the fields, if not present:

## 1. fid
- Output field name: fid
- Output field type: integer
- Expression: 
````
$id
````

## 2. matid
This must already be present, otherwise something gone wrong vectorizing the mesh.

## 3. area
- Output field name: area
- Output field type: real
- Expression: 
````
$area
````

## 4. min_len
- Output field name: min_lenb
- Output field type: real
- Expression:
````
with_variable('p1', point_n(exterior_ring($geometry),1),
with_variable('p2', point_n(exterior_ring($geometry),2),
with_variable('p3', point_n(exterior_ring($geometry),3),

min(
    distance(@p1,@p2),
    distance(@p2,@p3),
    distance(@p3,@p1)
))))
````

## 5. ins_rad
This requires the calculation of the perimeter, since the radius of the inscribed circle of a triangle is obtained by the formula ````r = A / p / 2 = 2 * A / p ````. My suggetsion is then to compute it in a separate field:
- Output field name: perimeter
- Output field type: real
- Expression: 
````
$perimeter
````

And then, compute the required field:
- Output field name: ins_rad
- Output field type: real
- Expression: 
````
2 * "area" / "perimeter"
````