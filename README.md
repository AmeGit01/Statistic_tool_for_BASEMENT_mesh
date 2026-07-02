# BASE_mesh_statistics_tool
Compute quality statistics for any 2D mesh

This tool was developed by Amedeo Repele, for any bug in the code or info please send a message to _amedeo.repele@unitn.it_.  
The BASE_mesh_statistics_tool is a julia script which compute quality metrics of any 2D mesh for hydrodynamical simulation purposes. It was originally developed to deal with BASEMENT 2D mesh [(BASEMENT web site)](https://basement.ethz.ch/), but actually it do not require any specific of BASEMENT, also thanks to the very general framework of BASEMENT itself. The complete list of tools (python scripts) developed by the BASEMENT group within the ETH Zurich can be found at the following link [BASEtools](https://basement.ethz.ch/download/tools/python-scripts.html), but I didn't found the same this julia script is doing.  

It is not required any knowledge about Julia programming language, just use this tool by downloading the complete repository. Everything the used needs is:
- Julia installed (this tool was developed under julia version 1.12.6). Refers to [Intalling Julia](https://julialang.org/downloads/) if not already downloaded;
- The folders ````figures```` and ````reports```` already initialized (done by default when downloading the repository);
- **Optional 1**: The folder ````inputs```` is suggested for a good organization of the repository;
- **Optional 2**: Strongly recommended, add an environment variable to avoid manually activate the project every time the user runs the mesh_stats.jl scrips. 

## Optional 2

### Windows OS
1. Press the **Window key** and type **"environmental variables"**, then press Enter;
2. Click on the **Environmental Variables...** button at the bottom rigth;
3. In the **User variables** section (the top one), click **New...**;
4. Enter the following values:
    - **Variable name**: ````JULIA_PROJECT````;
    - **Variable value**: ````@.````;
5. Click **OK** on all windows to save and apply.

### Linux OS
1. Find the configuration file (````~/.bashrc```` or ````~/.zshrc````)
2. Add at the end of the file: ````export JULIA_PROJECT="@." ````
3. Save and refresh the terminal.

This is telling Julia to look for a project and activate it if found when typing ````julia```` on terminal.  
In case you don't want to set the **optional 2**, remenver to always type ````julia --project=@.```` instead of just type ````julia````.


## Arguments

The mesh_stats.jl julia scripts requires the following arguments:
1. ````input_file.csv````: this file contains the informations of the mesh, must have the following columns (even though some are not used) 
	1.	cell ID
	2.	material ID
	3.	Bed elevation
	4.	Cell area		
	5.	cell minimum edge length	(CFL reference length for BASEMD)	
	6.	cell maximum edge length
	7.	aspect ratio = minimum edge length / maximum edge length	(cells regularity parameter)
	8.	cell minumum angle	(cells regularity parameter)
	9.	cell perimeter
	10.	radius of the inscribed circle	(CFL reference length for BASEHPC)  

    Only columns 4 and 5 (or 10) are plotted so far, but the colums 1, 2 are used. It do not care the columns name, the order do instead. The user, opening the mesh_stats.jl file, has the possibility to also plot the columns 7 and 8 (for Julia users only);

2. ````MatIDfile.txt````: this file contains the list of the matIDs the user wants to plot the statistics for, and the possibility to set a logaritmic scale (base 10) for the vertical coordinate of the specific subplot (for each matID) for a better visualization of Area and Characteristic Size distributions;

3. ````FigureFormat````: This allow the user to specify the format of the output figure, possible inputs are ````png````, ````jpg````, ````pdf````, ````svg````. DO NOT type the dot, as for example ````pdf```` is ok, ````.pdf```` is not ok;

4. ````BASEflow````: this argument specify which BASEMENT model the user is adopting, possible values are ````BASEMD```` or ````BASEHPC````. In case the mesh is not coming from the BASEMENT environment, select one of the two according to the CFL condition specified on the reference manual of the model of interest, or the more appropriate one, according to what specified above.  

## Running mesh_stats.jl
Read **optional 2** first.  

To run the ````mesh_stats.jl```` script just open a terminal, locate it to the repository using the ````cd```` command, and then:

### First run (or when needed, Julia will tell you)


