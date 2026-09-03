using Printf, Plots, Plots.Measures, DelimitedFiles
using StatsPlots, Statistics, StatsBase
using OrderedCollections, Colors
using Infiltrator, DaemonMode

include("Statistic_tool_for_BASEMENT_mesh.jl")
import .Statistic_tool_for_BASEMENT_mesh as mdl

function plot_stats(args)

	# Read inputs
	InputFile = args[1] 
	RegionsFile = args[2]
	BASEflow = args[3]
	OutputFormat = args[4]	
	dosave = true
	dodisplay = false
	# =#

	#= testing
	InputFile = "inputs/test_mesh.csv"
	RegionsFile = "inputs/test_regions.txt"
	BASEflow = "BASEHPC"
	OutputFormat = "pdf"
	dosave = false
	dodisplay = true
	# =#

	# read files and set-up outputs names
	@printf("Reading input file: %s \n", InputFile)
	data, fields = readdlm(InputFile, ',', header=true) # '\t'

	# Extract FileName
	last = collect(findlast("/", InputFile))
	FileName = InputFile[last[begin]+1:end]

	last = collect(findlast(".", FileName))
	FileNameNoFormat = FileName[begin:last[begin]-1]	

	UseRegionsFile, fields_RegionsFile = readdlm(RegionsFile, ',', header=true)
	UseRegions = Int64.(UseRegionsFile[:, 1])
	ylogScale = Bool.(UseRegionsFile[:, 2])
	RegionNames = String.(UseRegionsFile[:, 3])
	RegionNames = chop.(RegionNames, head=1, tail=0)

	ReportFileName = "reports/Report_$(FileNameNoFormat).txt"
	# ReportFileName = "reports/report_PROVA.txt"
	
	# Find all the position of the colums to be used
	positions = zeros(Int64, 5)
	@infiltrate false
	idx = findfirst(==( "fid" ), fields)
	!isnothing(idx) && (positions[1] = idx[2])
	idx = findfirst(==( "matid" ), fields)
	!isnothing(idx) && (positions[2] = idx[2])
	idx = findfirst(==( "area" ), fields)
	!isnothing(idx) && (positions[3] = idx[2])
	idx = findfirst(==( "min_len" ), fields)
	!isnothing(idx) && (positions[4] = idx[2])
	idx = findfirst(==( "ins_rad" ), fields)
	!isnothing(idx) && (positions[5] = idx[2])

	if any(iszero, positions) 
		@printf("\nSome of the required fields are missing in the input file %s. Please check the column names. \n", InputFile)
		@printf("The correct names that are required are: fid, matid, area, min_len, ins_rad \nAny additional (support) column can be present without any issue. \n")
		return
	end

	# create filters by region type
	ndata = length(data[:,positions[1]])
	material_id = Array{Int64}(undef, ndata)
	material_id .= data[:,positions[2]]

	materials_all = Dict( i => findall(==(i), material_id) for i ∈ unique(material_id) )

	# Check the selected regions are actually stored in the csv file
	flag = false
	MissingRegions = Int64[]
	for i ∈ UseRegions
		if !haskey(materials_all, i)
			@printf("matid %d is selected but not found in the input file.\n", i)
			flag = true
			push!(MissingRegions, i)
		end
	end
	if flag
		# @printf("The regions with matid %s are missing in the input file.\nThe only available matids are: %s\n", join(MissingRegions, ", "), join(unique(material_id), ", "))
		@printf("The only available matids are: %s\n", join(sort(unique(material_id)), ", "))
		return
	end

	# Select the desired regions
	materials = OrderedDict(i => materials_all[i] for i in UseRegions)


	# Preallocate vectors
	nID = length(UseRegions)
	plts = Array{Plots.Plot}(undef, nID, 2)

	nquantiles = 4 	# USER DEFINED
	quantiles = Array{Float64}(undef, nquantiles, nID, 2)
	quantiles_intervals = Array{Float64}(undef, nquantiles, 2)
	
	# Define plot colors
	colors = [RGB(
		0.5 + 0.5*sin(2π*i/nID),
    	0.5 + 0.5*sin(2π*(i/nID + 1/3)),
    	0.5 + 0.5*sin(2π*(i/nID + 2/3))
	) for i ∈ 1:nID]

	## Plot area distributions
	@printf("\nBuilding area distribution plots... \n")
	area = data[:,positions[3]]
	title = "Distribuzione Aree - $(FileName)"
	xlabel = "Area cella [m^2]"
	OutputName = "figures/Area_$(FileNameNoFormat).$(OutputFormat)"

	quantiles_intervals[:, 1] .= [0.001, 0.01, 0.05, 0.1]	# USED DEFINED, ACCORDIG TO nquantiles

	for i ∈ 1:nID
		plt_tmp, q1 = mdl.plot_histogram(area, materials, title, xlabel, quantiles_intervals[:, 1], i, UseRegions, colors[i], ylogScale, RegionNames; quantiles_flag = true)
		plts[i, 1] = plt_tmp
		quantiles[:, i, 1] = q1
	end

	ydimension = Int64(300*nID+100)
	plt1 = plot(plts[:, 1]..., layout=(nID, 1), 
		left_margin=5mm, bottom_margin=5mm,
		size=(1000, ydimension)
	)
	dodisplay && display(plt1)

	dosave && savefig(plt1, OutputName)
	dosave && @printf("Area plot saved to file %s\n", OutputName)

	# "figures/prova.png"

	# Plot controlling dimension 
	@printf("\nBuilding characteristic length distribution plots... \n")
	if BASEflow == "BASEMD"
		chrsize = data[:,positions[4]]
		title = "Minimum cell size - $(FileName)"
		xlabel = "edge length [m]"
	elseif BASEflow == "BASEHPC"
		chrsize = data[:, positions[5]]
		title = "Inscribed circle's radius - $(FileName)"
		xlabel = "radius [m]"
	else
		error("BASEflow not defined, select BASEMD or BASEHPC")
	end
	OutputName = "figures/Char_length_$(FileNameNoFormat).$(OutputFormat)"

	quantiles_intervals[:, 2] = [0.001, 0.01, 0.05, 0.1]	# USED DEFINED, ACCORDIG TO nquantiles	

	for i ∈ 1:nID
		plt_tmp, q2 = mdl.plot_histogram(chrsize, materials, title, xlabel, quantiles_intervals[:, 2], i, UseRegions, colors[i], ylogScale, RegionNames; quantiles_flag = true)
		plts[i, 2] = plt_tmp
		quantiles[:, i, 2] = q2
		# @show q1
	end
	ydimension = Int64(300*nID+100)
	plt2 = plot(plts[:, 2]..., layout=(nID, 1), 
		left_margin=5mm, bottom_margin=5mm,
		size=(1000, ydimension)
	)
	dodisplay && display(plt2)

	dosave && savefig(plt2, OutputName) # =#
	dosave && @printf("Characteristic length plot saved to file %s\n", OutputName)

	# build the report
	dosave && mdl.write_report(ReportFileName, FileName, BASEflow, quantiles, quantiles_intervals, materials, UseRegions, area, chrsize, RegionNames)

	return nothing
end

function compute_stats(args)
	ElementFile = args[1]
	NodeFile = args[2]
	BASEflow = args[3] 
	Outputformat = ".csv"
	dosave = true
	dodisplay = false

	# read files and set-up outputs names
	@printf("Reading element file: %s \n", ElementFile)
	ele, fields = readdlm(ElementFile, header=true) # , '\t')
	# elememnts contains: fid, node1, node2, node3, matid
	eleID = ele[:, 1]
	Nele = length(eleID)-1


	# Extract FileName
	last = collect(findlast("/", ElementFile))
	FileName = ElementFile[last[begin]+1:end]
	last = collect(findlast(".", FileName))
	FileNameNoFormat = FileName[begin:last[begin]-1]	

	@printf("Reading element file: %s \n", NodeFile)
	nod, fields = readdlm(NodeFile, header=true) # , '\t')
	nodID = nod[:, 1]
	Nnod = length(nodID)-1

	open("inputs/ID.sol", "w") do io

		write(io, "DATASET\n")
        write(io, "OBJTYPE \"mesh2d\"\n")
		write(io, "RT_JU8LIAN 2433282.500000\n")
		write(io, "BEGSCL\n")
        write(io, "ND $Nnod\n")
        write(io, "NC $Nele\n")
        write(io, "NAME \"ID\"\n")
		write(io, "TIMEUNITS seconds\n")
        write(io, "TS 0 0.0\n")
        # write(io, "CC\n") # Dati legati alle facce

		for n ∈ 1:Nele
			write(io, Float64(eleID[n]))
		end
	end

	return 
end

#= use:
# push!(ARGS, "inputs/test_mesh.csv", "inputs/test_regions.txt", "BASEHPC", "png")
if length(Base.ARGS) < 4
	error("Select an input file typing: julia src/mesh_stats.jl inputs/InputFile.csv inputs/RegionsFile.txt BASEMD/BASEHPC FigureFormat \n")
end # =#

# use:
# push!(ARGS, "inputs/test_mesh.csv", "inputs/test_regions.txt", "BASEHPC", "png")
if length(Base.ARGS) < 2
	error("Missing argumens \n")
end # =#


compute_stats(Base.ARGS)

# plot_stats(Base.ARGS)