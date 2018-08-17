# ---------- dotnet support using SWIG ----------
.PHONY: help_dotnet # Generate list of dotnet targets with descriptions.
help_dotnet:
	@echo Use one of the following dotnet targets:
ifeq ($(SYSTEM),win)
	@$(GREP) "^.PHONY: .* #" $(CURDIR)/makefiles/Makefile.dotnet.mk | $(SED) "s/\.PHONY: \(.*\) # \(.*\)/\1\t\2/"
	@echo off & echo(
else
	@$(GREP) "^.PHONY: .* #" $(CURDIR)/makefiles/Makefile.dotnet.mk | $(SED) "s/\.PHONY: \(.*\) # \(.*\)/\1\t\2/" | expand -t20
	@echo
endif

# Check for required build tools
DOTNET = dotnet
ifeq ($(SYSTEM),win)
DOTNET_BIN := $(shell $(WHICH) $(DOTNET) 2> NUL)
else # UNIX
DOTNET_BIN := $(shell command -v $(DOTNET) 2> /dev/null)
endif
NUGET_BIN = "$(DOTNET_BIN)" nuget

HAS_DOTNET = true
ifndef DOTNET_BIN
HAS_DOTNET =
endif

# Detect RuntimeIDentifier
ifeq ($(OS),Windows)
RUNTIME_IDENTIFIER=win-x64
else ifeq ($(OS),Linux)
RUNTIME_IDENTIFIER=linux-x64
else ifeq ($(OS),Darwin)
RUNTIME_IDENTIFIER=osx-x64
else
$(error OS unknown !)
endif

# Main target
.PHONY: dotnet # Build OrTools for .NET
.PHONY: test_dotnet # Test dotnet version of OR-Tools
ifndef HAS_DOTNET
dotnet:
	@echo DOTNET_BIN = $(DOTNET_BIN)
	$(warning Cannot find '$@' command which is needed for build. Please make sure it is installed and in system path.)

test_dotnet: dotnet
else
dotnet: \
 ortoolslibs \
 csharp_dotnet \
 fsharp_dotnet \
 $(DOTNET_EXAMPLES)

test_dotnet: test_dotnet_examples
BUILT_LANGUAGES +=, dotnet \(netstandard2.0\)
endif

DOTNET_EXAMPLES = \
$(BIN_DIR)/a_puzzle$D \
$(BIN_DIR)/tsp$D \
$(BIN_DIR)/Program$D

# All libraries and dependecies
DOTNET_ORTOOLS_SNK := $(BIN_DIR)/or-tools.snk
DOTNET_ORTOOLS_SNK_PATH := $(subst /,$S,$(DOTNET_ORTOOLS_SNK))
OR_TOOLS_ASSEMBLY_NAME := Google.OrTools
OR_TOOLS_NATIVE_ASSEMBLY_NAME := runtime.$(RUNTIME_IDENTIFIER).$(OR_TOOLS_ASSEMBLY_NAME)
OR_TOOLS_FSHARP_ASSEMBLY_NAME := $(OR_TOOLS_ASSEMBLY_NAME).FSharp
DOTNET_ORTOOLS_LIBS := $(BIN_DIR)/$(OR_TOOLS_ASSEMBLY_NAME)$D
DOTNET_ORTOOLS_NATIVE_LIBS := $(BIN_DIR)/$(OR_TOOLS_NATIVE_ASSEMBLY_NAME)$D
DOTNET_ORTOOLS_FSHARP_LIBS := $(BIN_DIR)/$(OR_TOOLS_FSHARP_ASSEMBLY_NAME)$D

PROTOBUF_ASSEMBLY_NAME := Google.Protobuf
DOTNET_PROTOBUF_LIBS = $(BIN_DIR)/$(PROTOBUF_ASSEMBLY_NAME)$D

.PHONY: csharp_dotnet # Build C# OR-Tools
csharp_dotnet: $(DOTNET_ORTOOLS_LIBS)

# Auto-generated rid dependent source code
$(GEN_DIR)/ortools/linear_solver/linear_solver_csharp_wrap.cc: \
 $(SRC_DIR)/ortools/linear_solver/dotnet/linear_solver.i \
 $(SRC_DIR)/ortools/base/base.i \
 $(SRC_DIR)/ortools/util/dotnet/proto.i \
 $(GLOP_DEPS) \
 $(LP_DEPS) \
 | $(GEN_DIR)/ortools/linear_solver
	$(SWIG_BINARY) $(SWIG_INC) -I$(INC_DIR) -c++ -csharp \
 -o $(GEN_PATH)$Sortools$Slinear_solver$Slinear_solver_csharp_wrap.cc \
 -module operations_research_linear_solver \
 -namespace $(OR_TOOLS_ASSEMBLY_NAME).LinearSolver \
 -dllimport "$(OR_TOOLS_NATIVE_ASSEMBLY_NAME).$(SWIG_DOTNET_LIB_SUFFIX)" \
 -outdir $(GEN_PATH)$Sortools$Slinear_solver \
 $(SRC_DIR)$Sortools$Slinear_solver$Scsharp$Slinear_solver.i

$(OBJ_DIR)/swig/linear_solver_csharp_wrap.$O: \
 $(GEN_DIR)/ortools/linear_solver/linear_solver_csharp_wrap.cc \
 | $(OBJ_DIR)/swig
	$(CCC) $(CFLAGS) \
 -c $(GEN_PATH)$Sortools$Slinear_solver$Slinear_solver_csharp_wrap.cc \
 $(OBJ_OUT)$(OBJ_DIR)$Sswig$Slinear_solver_csharp_wrap.$O

$(GEN_DIR)/ortools/constraint_solver/constraint_solver_csharp_wrap.cc: \
 $(SRC_DIR)/ortools/constraint_solver/dotnet/routing.i \
 $(SRC_DIR)/ortools/constraint_solver/dotnet/constraint_solver.i \
 $(SRC_DIR)/ortools/base/base.i \
 $(SRC_DIR)/ortools/util/dotnet/proto.i \
 $(SRC_DIR)/ortools/util/dotnet/functions.i \
 $(CP_DEPS) \
 | $(GEN_DIR)/ortools/constraint_solver
	$(SWIG_BINARY) $(SWIG_INC) -I$(INC_DIR) -c++ -csharp \
 -o $(GEN_PATH)$Sortools$Sconstraint_solver$Sconstraint_solver_csharp_wrap.cc \
 -module operations_research_constraint_solver \
 -namespace $(OR_TOOLS_ASSEMBLY_NAME).ConstraintSolver \
 -dllimport "$(OR_TOOLS_NATIVE_ASSEMBLY_NAME).$(SWIG_DOTNET_LIB_SUFFIX)" \
 -outdir $(GEN_PATH)$Sortools$Sconstraint_solver \
 $(SRC_DIR)$Sortools$Sconstraint_solver$Scsharp$Srouting.i
	$(SED) -i -e 's/CSharp_new_Solver/CSharp_new_CpSolver/g' \
 $(GEN_PATH)$Sortools$Sconstraint_solver$S*cs \
 $(GEN_PATH)$Sortools$Sconstraint_solver$Sconstraint_solver_csharp_wrap.*
	$(SED) -i -e 's/CSharp_delete_Solver/CSharp_delete_CpSolver/g' \
 $(GEN_PATH)$Sortools$Sconstraint_solver$S*cs \
 $(GEN_PATH)$Sortools$Sconstraint_solver$Sconstraint_solver_csharp_wrap.*
	$(SED) -i -e 's/CSharp_Solver/CSharp_CpSolver/g' \
 $(GEN_PATH)$Sortools$Sconstraint_solver$S*cs \
 $(GEN_PATH)$Sortools$Sconstraint_solver$Sconstraint_solver_csharp_wrap.*
	$(SED) -i -e 's/CSharp_new_Constraint/CSharp_new_CpConstraint/g' \
 $(GEN_PATH)$Sortools$Sconstraint_solver$S*cs \
 $(GEN_PATH)$Sortools$Sconstraint_solver$Sconstraint_solver_csharp_wrap.*
	$(SED) -i -e 's/CSharp_delete_Constraint/CSharp_delete_CpConstraint/g' \
 $(GEN_PATH)$Sortools$Sconstraint_solver$S*cs \
 $(GEN_PATH)$Sortools$Sconstraint_solver$Sconstraint_solver_csharp_wrap.*
	$(SED) -i -e 's/CSharp_Constraint/CSharp_CpConstraint/g' \
 $(GEN_PATH)$Sortools$Sconstraint_solver$S*cs \
 $(GEN_PATH)$Sortools$Sconstraint_solver$Sconstraint_solver_csharp_wrap.*

$(OBJ_DIR)/swig/constraint_solver_csharp_wrap.$O: \
 $(GEN_DIR)/ortools/constraint_solver/constraint_solver_csharp_wrap.cc \
 | $(OBJ_DIR)/swig
	$(CCC) $(CFLAGS) \
 -c $(GEN_PATH)$Sortools$Sconstraint_solver$Sconstraint_solver_csharp_wrap.cc \
 $(OBJ_OUT)$(OBJ_DIR)$Sswig$Sconstraint_solver_csharp_wrap.$O

$(GEN_DIR)/ortools/algorithms/knapsack_solver_csharp_wrap.cc: \
 $(SRC_DIR)/ortools/algorithms/dotnet/knapsack_solver.i \
 $(SRC_DIR)/ortools/base/base.i \
 $(SRC_DIR)/ortools/util/dotnet/proto.i \
 $(SRC_DIR)/ortools/algorithms/knapsack_solver.h \
 | $(GEN_DIR)/ortools/algorithms
	$(SWIG_BINARY) $(SWIG_INC) -I$(INC_DIR) -c++ -csharp \
 -o $(GEN_PATH)$Sortools$Salgorithms$Sknapsack_solver_csharp_wrap.cc \
 -module operations_research_algorithms \
 -namespace $(OR_TOOLS_ASSEMBLY_NAME).Algorithms \
 -dllimport "$(OR_TOOLS_NATIVE_ASSEMBLY_NAME).$(SWIG_DOTNET_LIB_SUFFIX)" \
 -outdir $(GEN_PATH)$Sortools$Salgorithms \
 $(SRC_DIR)$Sortools$Salgorithms$Scsharp$Sknapsack_solver.i

$(OBJ_DIR)/swig/knapsack_solver_csharp_wrap.$O: \
 $(GEN_DIR)/ortools/algorithms/knapsack_solver_csharp_wrap.cc \
 | $(OBJ_DIR)/swig
	$(CCC) $(CFLAGS) \
 -c $(GEN_PATH)$Sortools$Salgorithms$Sknapsack_solver_csharp_wrap.cc \
 $(OBJ_OUT)$(OBJ_DIR)$Sswig$Sknapsack_solver_csharp_wrap.$O

$(GEN_DIR)/ortools/graph/graph_csharp_wrap.cc: \
 $(SRC_DIR)/ortools/graph/dotnet/graph.i \
 $(SRC_DIR)/ortools/base/base.i \
 $(SRC_DIR)/ortools/util/dotnet/proto.i \
 $(GRAPH_DEPS) \
 | $(GEN_DIR)/ortools/graph $(GEN_DIR)/ortools/graph
	$(SWIG_BINARY) $(SWIG_INC) -I$(INC_DIR) -c++ -csharp \
 -o $(GEN_PATH)$Sortools$Sgraph$Sgraph_csharp_wrap.cc \
 -module operations_research_graph \
 -namespace $(OR_TOOLS_ASSEMBLY_NAME).Graph \
 -dllimport "$(OR_TOOLS_NATIVE_ASSEMBLY_NAME).$(SWIG_DOTNET_LIB_SUFFIX)" \
 -outdir $(GEN_PATH)$Sortools$Sgraph \
 $(SRC_DIR)$Sortools$Sgraph$Scsharp$Sgraph.i

$(OBJ_DIR)/swig/graph_csharp_wrap.$O: \
 $(GEN_DIR)/ortools/graph/graph_csharp_wrap.cc \
 | $(OBJ_DIR)/swig
	$(CCC) $(CFLAGS) \
 -c $(GEN_PATH)$Sortools$Sgraph$Sgraph_csharp_wrap.cc \
 $(OBJ_OUT)$(OBJ_DIR)$Sswig$Sgraph_csharp_wrap.$O

$(GEN_DIR)/ortools/sat/sat_csharp_wrap.cc: \
 $(SRC_DIR)/ortools/base/base.i \
 $(SRC_DIR)/ortools/sat/dotnet/sat.i \
 $(SRC_DIR)/ortools/sat/swig_helper.h \
 $(SRC_DIR)/ortools/util/dotnet/proto.i \
 $(SAT_DEPS) \
 | $(GEN_DIR)/ortools/sat $(GEN_DIR)/ortools/sat
	$(SWIG_BINARY) $(SWIG_INC) -I$(INC_DIR) -c++ -csharp \
 -o $(GEN_PATH)$Sortools$Ssat$Ssat_csharp_wrap.cc \
 -module operations_research_sat \
 -namespace $(OR_TOOLS_ASSEMBLY_NAME).Sat \
 -dllimport "$(OR_TOOLS_NATIVE_ASSEMBLY_NAME).$(SWIG_DOTNET_LIB_SUFFIX)" \
 -outdir $(GEN_PATH)$Sortools$Ssat \
 $(SRC_DIR)$Sortools$Ssat$Scsharp$Ssat.i

$(OBJ_DIR)/swig/sat_csharp_wrap.$O: \
 $(GEN_DIR)/ortools/sat/sat_csharp_wrap.cc \
 | $(OBJ_DIR)/swig
	$(CCC) $(CFLAGS) \
 -c $(GEN_PATH)$Sortools$Ssat$Ssat_csharp_wrap.cc \
 $(OBJ_OUT)$(OBJ_DIR)$Sswig$Ssat_csharp_wrap.$O

$(DOTNET_ORTOOLS_SNK): $(SRC_DIR)/tools/dotnet/CreateSigningKey/CreateSigningKey.csproj | $(BIN_DIR)
	"$(DOTNET_BIN)" run --project tools$Sdotnet$SCreateSigningKey$SCreateSigningKey.csproj $S$(DOTNET_ORTOOLS_SNK_PATH)

$(BIN_DIR)/$(OR_TOOLS_NATIVE_ASSEMBLY_NAME).$(SWIG_DOTNET_LIB_SUFFIX): \
 $(OR_TOOLS_LIBS) \
 $(OBJ_DIR)/swig/linear_solver_csharp_wrap.$O \
 $(OBJ_DIR)/swig/sat_csharp_wrap.$O \
 $(OBJ_DIR)/swig/constraint_solver_csharp_wrap.$O \
 $(OBJ_DIR)/swig/knapsack_solver_csharp_wrap.$O \
 $(OBJ_DIR)/swig/graph_csharp_wrap.$O \
 | $(BIN_DIR)
	$(DYNAMIC_LD) \
 $(LD_OUT)$(BIN_DIR)$S$(OR_TOOLS_NATIVE_ASSEMBLY_NAME).$(SWIG_DOTNET_LIB_SUFFIX) \
 $(OBJ_DIR)$Sswig$Slinear_solver_csharp_wrap.$O \
 $(OBJ_DIR)$Sswig$Ssat_csharp_wrap.$O \
 $(OBJ_DIR)$Sswig$Sconstraint_solver_csharp_wrap.$O \
 $(OBJ_DIR)$Sswig$Sknapsack_solver_csharp_wrap.$O \
 $(OBJ_DIR)$Sswig$Sgraph_csharp_wrap.$O \
 $(OR_TOOLS_LNK) \
 $(OR_TOOLS_LDFLAGS)

$(DOTNET_ORTOOLS_NATIVE_LIBS): \
 $(DOTNET_ORTOOLS_SNK) \
 $(BIN_DIR)/$(OR_TOOLS_NATIVE_ASSEMBLY_NAME).$(SWIG_DOTNET_LIB_SUFFIX) \
 $(SRC_DIR)/ortools/dotnet/$(OR_TOOLS_NATIVE_ASSEMBLY_NAME)/$(OR_TOOLS_NATIVE_ASSEMBLY_NAME).csproj \
 $(SRC_DIR)/ortools/algorithms/dotnet/IntArrayHelper.cs \
 $(SRC_DIR)/ortools/constraint_solver/dotnet/IntVarArrayHelper.cs \
 $(SRC_DIR)/ortools/constraint_solver/dotnet/IntervalVarArrayHelper.cs \
 $(SRC_DIR)/ortools/constraint_solver/dotnet/IntArrayHelper.cs \
 $(SRC_DIR)/ortools/constraint_solver/dotnet/NetDecisionBuilder.cs \
 $(SRC_DIR)/ortools/constraint_solver/dotnet/SolverHelper.cs \
 $(SRC_DIR)/ortools/constraint_solver/dotnet/ValCstPair.cs \
 $(SRC_DIR)/ortools/linear_solver/dotnet/DoubleArrayHelper.cs \
 $(SRC_DIR)/ortools/linear_solver/dotnet/LinearExpr.cs \
 $(SRC_DIR)/ortools/linear_solver/dotnet/LinearConstraint.cs \
 $(SRC_DIR)/ortools/linear_solver/dotnet/SolverHelper.cs \
 $(SRC_DIR)/ortools/linear_solver/dotnet/VariableHelper.cs \
 $(SRC_DIR)/ortools/sat/dotnet/CpModel.cs \
 $(SRC_DIR)/ortools/util/dotnet/NestedArrayHelper.cs \
 $(SRC_DIR)/ortools/util/dotnet/ProtoHelper.cs \
 | $(BIN_DIR)
	"$(DOTNET_BIN)" build -r $(RUNTIME_IDENTIFIER) ortools$Sdotnet$S$(OR_TOOLS_ASSEMBLY_NAME)$S$(OR_TOOLS_ASSEMBLY_NAME).csproj
ifeq ($(SYSTEM),win)
	$(COPY) ortools$Sdotnet$S$(OR_TOOLS_ASSEMBLY_NAME)$Sbin$Sx64$SDebug$Snetstandard2.0$S$(RUNTIME_IDENTIFIER)$S*.* $(BIN_DIR)
else
	$(COPY) ortools$Sdotnet$S$(OR_TOOLS_ASSEMBLY_NAME)$Sbin$SDebug$Snetstandard2.0$S$(RUNTIME_IDENTIFIER)$S*.* $(BIN_DIR)
endif

# Protobufs generated code
$(DOTNET_PROTOBUF_LIBS): tools/dotnet/$(PROTOBUF_ASSEMBLY_NAME)$D | $(BIN_DIR)
	$(COPY) tools$Sdotnet$S$(PROTOBUF_ASSEMBLY_NAME)$D $(BIN_DIR)

$(GEN_DIR)/ortools/constraint_solver/SearchLimit.pb.cs: \
 $(SRC_DIR)/ortools/constraint_solver/search_limit.proto \
 | $(GEN_DIR)/ortools/constraint_solver
	$(PROTOC) --proto_path=$(SRC_DIR) \
 --csharp_out=$(GEN_PATH)$Sortools$Sconstraint_solver \
 --csharp_opt=file_extension=.pb.cs \
 $(SRC_DIR)$Sortools$Sconstraint_solver$Ssearch_limit.proto

$(GEN_DIR)/ortools/constraint_solver/SolverParameters.pb.cs: \
 $(SRC_DIR)/ortools/constraint_solver/solver_parameters.proto \
 | $(GEN_DIR)/ortools/constraint_solver
	$(PROTOC) --proto_path=$(SRC_DIR) \
 --csharp_out=$(GEN_PATH)$Sortools$Sconstraint_solver \
 --csharp_opt=file_extension=.pb.cs \
 $(SRC_DIR)$Sortools$Sconstraint_solver$Ssolver_parameters.proto

$(GEN_DIR)/ortools/constraint_solver/Model.pb.cs: \
 $(SRC_DIR)/ortools/constraint_solver/solver_parameters.proto \
 | $(GEN_DIR)/ortools/constraint_solver
	$(PROTOC) --proto_path=$(SRC_DIR) \
 --csharp_out=$(GEN_PATH)$Sortools$Sconstraint_solver \
 --csharp_opt=file_extension=.pb.cs \
 $(SRC_DIR)$Sortools$Sconstraint_solver$Smodel.proto

$(GEN_DIR)/ortools/constraint_solver/RoutingParameters.pb.cs: \
 $(SRC_DIR)/ortools/constraint_solver/routing_parameters.proto \
 | $(GEN_DIR)/ortools/constraint_solver
	$(PROTOC) --proto_path=$(SRC_DIR) \
 --csharp_out=$(GEN_PATH)$Sortools$Sconstraint_solver \
 --csharp_opt=file_extension=.pb.cs \
 $(SRC_DIR)$Sortools$Sconstraint_solver$Srouting_parameters.proto

$(GEN_DIR)/ortools/constraint_solver/RoutingEnums.pb.cs: \
 $(SRC_DIR)/ortools/constraint_solver/routing_enums.proto \
 | $(GEN_DIR)/ortools/constraint_solver
	$(PROTOC) --proto_path=$(SRC_DIR) \
 --csharp_out=$(GEN_PATH)$Sortools$Sconstraint_solver \
 --csharp_opt=file_extension=.pb.cs \
 $(SRC_DIR)$Sortools$Sconstraint_solver$Srouting_enums.proto

$(GEN_DIR)/ortools/sat/CpModel.pb.cs: \
 $(SRC_DIR)/ortools/sat/cp_model.proto \
 | $(GEN_DIR)/ortools/sat
	$(PROTOC) --proto_path=$(SRC_DIR) \
 --csharp_out=$(GEN_PATH)$Sortools$Ssat \
 --csharp_opt=file_extension=.pb.cs \
 $(SRC_DIR)$Sortools$Ssat$Scp_model.proto

$(GEN_DIR)/ortools/sat/SatParameters.pb.cs: \
 $(SRC_DIR)/ortools/sat/sat_parameters.proto \
 | $(GEN_DIR)/ortools/sat
	$(PROTOC) --proto_path=$(SRC_DIR) \
 --csharp_out=$(GEN_PATH)$Sortools$Ssat \
 --csharp_opt=file_extension=.pb.cs \
 $(SRC_DIR)$Sortools$Ssat$Ssat_parameters.proto

$(SRC_DIR)/ortools/dotnet/$(OR_TOOLS_NATIVE_ASSEMBLY_NAME)/$(OR_TOOLS_NATIVE_ASSEMBLY_NAME).csproj: \
 $(SRC_DIR)/ortools/dotnet/$(OR_TOOLS_NATIVE_ASSEMBLY_NAME)/$(OR_TOOLS_NATIVE_ASSEMBLY_NAME).csproj.in
	$(SED) -e "s/@PROJECT_VERSION@/$(OR_TOOLS_VERSION)/" \
 ortools$Sdotnet$S$(OR_TOOLS_NATIVE_ASSEMBLY_NAME)$S$(OR_TOOLS_NATIVE_ASSEMBLY_NAME).csproj.in \
 > ortools$Sdotnet$S$(OR_TOOLS_NATIVE_ASSEMBLY_NAME)$S$(OR_TOOLS_NATIVE_ASSEMBLY_NAME).csproj

$(DOTNET_ORTOOLS_LIBS): \
 $(DOTNET_ORTOOLS_NATIVE_LIBS) \
 $(DOTNET_PROTOBUF_LIBS) \
 $(SRC_DIR)/ortools/dotnet/$(OR_TOOLS_ASSEMBLY_NAME)/$(OR_TOOLS_ASSEMBLY_NAME).csproj \
 $(GEN_DIR)/ortools/constraint_solver/Model.pb.cs \
 $(GEN_DIR)/ortools/constraint_solver/SearchLimit.pb.cs \
 $(GEN_DIR)/ortools/constraint_solver/SolverParameters.pb.cs \
 $(GEN_DIR)/ortools/constraint_solver/RoutingParameters.pb.cs \
 $(GEN_DIR)/ortools/constraint_solver/RoutingEnums.pb.cs \
 $(GEN_DIR)/ortools/sat/CpModel.pb.cs \
 | $(BIN_DIR)
	"$(DOTNET_BIN)" build -r $(RUNTIME_IDENTIFIER) ortools$Sdotnet$S$(OR_TOOLS_ASSEMBLY_NAME)$S$(OR_TOOLS_ASSEMBLY_NAME).csproj
ifeq ($(SYSTEM),win)
	$(COPY) ortools$Sdotnet$S$(OR_TOOLS_ASSEMBLY_NAME)$Sbin$Sx64$SDebug$Snetstandard2.0$S$(RUNTIME_IDENTIFIER)$S*.* $(BIN_DIR)
else
	$(COPY) ortools$Sdotnet$S$(OR_TOOLS_ASSEMBLY_NAME)$Sbin$SDebug$Snetstandard2.0$S$(RUNTIME_IDENTIFIER)$S*.* $(BIN_DIR)
endif

$(SRC_DIR)/ortools/dotnet/$(OR_TOOLS_ASSEMBLY_NAME)/$(OR_TOOLS_ASSEMBLY_NAME).csproj: \
 $(SRC_DIR)/ortools/dotnet/$(OR_TOOLS_ASSEMBLY_NAME)/$(OR_TOOLS_ASSEMBLY_NAME).csproj.in
	$(SED) -e "s/@PROJECT_VERSION@/$(OR_TOOLS_VERSION)/" \
 ortools$Sdotnet$S$(OR_TOOLS_ASSEMBLY_NAME)$S$(OR_TOOLS_ASSEMBLY_NAME).csproj.in \
 > ortools$Sdotnet$S$(OR_TOOLS_ASSEMBLY_NAME)$S$(OR_TOOLS_ASSEMBLY_NAME).csproj

##############
##  FSHARP  ##
##############
.PHONY: fsharp_dotnet # Build F# OR-Tools
fsharp_dotnet: $(DOTNET_ORTOOLS_FSHARP_LIBS)

$(DOTNET_ORTOOLS_FSHARP_LIBS): \
 $(DOTNET_ORTOOLS_LIBS) \
 $(SRC_DIR)/ortools/dotnet/$(ORTOOLS_FSHARP_DLL_NAME)/$(ORTOOLS_FSHARP_DLL_NAME).fsproj \
 | $(BIN_DIR)
	"$(DOTNET_BIN)" build -c Debug ortools$Sdotnet$S$(ORTOOLS_FSHARP_DLL_NAME)$S$(ORTOOLS_FSHARP_DLL_NAME).fsproj
ifeq ($(SYSTEM),win)
	$(COPY) ortools$Sdotnet$S$(ORTOOLS_FSHARP_DLL_NAME)$Sbin$Sx64$SDebug$Snetstandard2.0$S*.* $(BIN_DIR)
else
	$(COPY) ortools$Sdotnet$S$(ORTOOLS_FSHARP_DLL_NAME)$Sbin$SDebug$Snetstandard2.0$S*.* $(BIN_DIR)
endif

$(SRC_DIR)/ortools/dotnet/$(ORTOOLS_FSHARP_DLL_NAME)/$(ORTOOLS_FSHARP_DLL_NAME).fsproj: \
 $(SRC_DIR)/ortools/dotnet/$(ORTOOLS_FSHARP_DLL_NAME)/$(ORTOOLS_FSHARP_DLL_NAME).fsproj.in
	$(SED) -e "s/@PROJECT_VERSION@/$(OR_TOOLS_VERSION)/" \
 ortools$Sdotnet$S$(ORTOOLS_FSHARP_DLL_NAME)$S$(ORTOOLS_FSHARP_DLL_NAME).fsproj.in \
 >ortools$Sdotnet$S$(ORTOOLS_FSHARP_DLL_NAME)$S$(ORTOOLS_FSHARP_DLL_NAME).fsproj

#####################
##  .NET Examples  ##
#####################
ifeq ($(EX),) # Those rules will be used if EX variable is not set
.PHONY: rdotnet cdotnet
rdotnet cdotnet:
	@echo No .Net file was provided, the $@ target must be used like so: \
 make $@ EX=examples/dotnet/csharp/example.csproj
else # This generic rule will be used if EX variable is set
EX_NAME = $(basename $(notdir $(EX)))

.PHONY: cdotnet
cdotnet: $(BIN_DIR)/$(EX_NAME)$D

.PHONY: rdotnet
rdotnet: $(BIN_DIR)/$(EX_NAME)$D
	@echo running $<
	"$(DOTNET_BIN)" $(BIN_DIR)$S$(EX_NAME)$D
endif # ifeq ($(EX),)

$(BIN_DIR)/%$D: $(DOTNET_EX_DIR)/csharp/%.csproj $(DOTNET_EX_DIR)/csharp/%.cs \
 $(BIN_DIR)/$(OR_TOOLS_ASSEMBLY_NAME)$D | $(BIN_DIR)
	"$(DOTNET_BIN)" build -o "..$S..$S..$S$(BIN_DIR)" \
 $(DOTNET_EX_PATH)$Scsharp$S$*.csproj

$(BIN_DIR)/%$D: $(DOTNET_EX_DIR)/fsharp/%.fsproj $(DOTNET_EX_DIR)/fsharp/%.fs \
 $(BIN_DIR)/$(OR_TOOLS_FSHARP_ASSEMBLY_NAME)$D  | $(BIN_DIR)
	"$(DOTNET_BIN)" build -o "..$S..$S..$S$(BIN_DIR)" \
 $(DOTNET_EX_PATH)$Sfsharp$S$*.fsproj

################
##  Cleaning  ##
################
.PHONY: clean_dotnet # Clean files
clean_dotnet:
	-$(DELREC) tools$Sdotnet$SCreateSigningKey$Sbin
	-$(DELREC) tools$Sdotnet$SCreateSigningKey$Sobj
	-$(DEL) $(DOTNET_ORTOOLS_SNK_PATH)
	-$(DELREC) ortools$Sdotnet$S$(OR_TOOLS_NATIVE_ASSEMBLY_NAME)$S$(OR_TOOLS_ASSEMBLY_NAME).csproj
	-$(DELREC) ortools$Sdotnet$S$(OR_TOOLS_NATIVE_ASSEMBLY_NAME)$Sbin
	-$(DELREC) ortools$Sdotnet$S$(OR_TOOLS_NATIVE_ASSEMBLY_NAME)$Sobj
	-$(DELREC) ortools$Sdotnet$S$(OR_TOOLS_ASSEMBLY_NAME)$S$(OR_TOOLS_ASSEMBLY_NAME).csproj
	-$(DELREC) ortools$Sdotnet$S$(OR_TOOLS_ASSEMBLY_NAME)$Sbin
	-$(DELREC) ortools$Sdotnet$S$(OR_TOOLS_ASSEMBLY_NAME)$Sobj
	-$(DELREC) ortools$Sdotnet$S$(OR_TOOLS_FSHARP_ASSEMBLY_NAME)$S$(OR_TOOLS_FSHARP_ASSEMBLY_NAME).csproj
	-$(DELREC) ortools$Sdotnet$S$(OR_TOOLS_FSHARP_ASSEMBLY_NAME)$Sbin
	-$(DELREC) ortools$Sdotnet$S$(OR_TOOLS_FSHARP_ASSEMBLY_NAME)$Sobj
	-$(DELREC) ortools$Sdotnet$Spackages
	-$(DELREC) $(EX_PATH)$Sdotnet$Scsharp$Sbin
	-$(DELREC) $(EX_PATH)$Sdotnet$Scsharp$Sobj
	-$(DELREC) $(EX_PATH)$Sdotnet$Sfsharp$Sobj
	-$(DEL) $(GEN_PATH)$Sortools$Salgorithms$S*.cs
	-$(DEL) $(GEN_PATH)$Sortools$Salgorithms$S*csharp_wrap*
	-$(DEL) $(GEN_PATH)$Sortools$Sgraph$S*.cs
	-$(DEL) $(GEN_PATH)$Sortools$Sgraph$S*csharp_wrap*
	-$(DEL) $(GEN_PATH)$Sortools$Sconstraint_solver$S*.cs
	-$(DEL) $(GEN_PATH)$Sortools$Sconstraint_solver$S*csharp_wrap*
	-$(DEL) $(GEN_PATH)$Sortools$Slinear_solver$S*.cs
	-$(DEL) $(GEN_PATH)$Sortools$Slinear_solver$S*csharp_wrap*
	-$(DEL) $(GEN_PATH)$Sortools$Ssat$S*.cs
	-$(DEL) $(GEN_PATH)$Sortools$Ssat$S*csharp_wrap*
	-$(DEL) $(OBJ_DIR)$Sswig$S*_csharp_wrap.$O
	-$(DEL) $(BIN_DIR)$S$(PROTOBUF_ASSEMBLY_NAME).*
	-$(DEL) $(BIN_DIR)$S$(OR_TOOLS_NATIVE_ASSEMBLY_NAME).*
	-$(DEL) $(BIN_DIR)$S$(OR_TOOLS_ASSEMBLY_NAME).*
	-$(DEL) $(BIN_DIR)$S$(OR_TOOLS_FSHARP_ASSEMBLY_NAME).*
	-$(DELREC) $(TEMP_DOTNET_DIR)
	-$(DELREC) $(TEMP_DOTNET_TEST_DIR)

######################
##  Nuget artifact  ##
######################
TEMP_DOTNET_DIR=temp_dotnet

$(TEMP_DOTNET_DIR):
	$(MKDIR_P) $(TEMP_DOTNET_DIR)

.PHONY: nuget_archive # Build .Net "Google.OrTools" Nuget Package
nuget_archive: dotnet | $(TEMP_DOTNET_DIR)
	"$(DOTNET_BIN)" publish -c Release --no-dependencies --no-restore -f netstandard2.0 \
 -o "..$S..$S..$S$(TEMP_DOTNET_DIR)" \
 ortools$Sdotnet$S$(OR_TOOLS_ASSEMBLY_NAME)$S$(OR_TOOLS_ASSEMBLY_NAME).csproj
	"$(DOTNET_BIN)" publish -c Release --no-dependencies --no-restore -f netstandard2.0 \
 -o "..$S..$S..$S$(TEMP_DOTNET_DIR)" \
 ortools$Sdotnet$S$(ORTOOLS_FSHARP_DLL_NAME)$S$(ORTOOLS_FSHARP_DLL_NAME).fsproj
	"$(DOTNET_BIN)" pack -c Release \
 -o "..$S..$S..$S$(BIN_DIR)" \
 ortools$Sdotnet

.PHONY: nuget_upload # Upload Nuget Package
nuget_upload: nuget_archive
	@echo Uploading Nuget package for "netstandard2.0".
	$(warning Not Implemented)

#############
##  DEBUG  ##
#############
.PHONY: detect_dotnet # Show variables used to build dotnet OR-Tools.
detect_dotnet:
	@echo Relevant info for the dotnet build:
	@echo DOTNET_BIN = $(DOTNET_BIN)
	@echo NUGET_BIN = $(NUGET_BIN)
	@echo PROTOC = $(PROTOC)
	@echo PROTOBUF_ASSEMBLY_NAME = $(PROTOBUF_ASSEMBLY_NAME)
	@echo DOTNET_PROTOBUF_LIBS = $(DOTNET_PROTOBUF_LIBS)
	@echo DOTNET_ORTOOLS_SNK = $(DOTNET_ORTOOLS_SNK)
	@echo SWIG_DOTNET_LIB_SUFFIX = $(SWIG_DOTNET_LIB_SUFFIX)
	@echo OR_TOOLS_NATIVE_ASSEMBLY_NAME = $(OR_TOOLS_NATIVE_ASSEMBLY_NAME)
	@echo DOTNET_ORTOOLS_NATIVE_LIBS = $(DOTNET_ORTOOLS_NATIVE_LIBS)
	@echo OR_TOOLS_ASSEMBLY_NAME = $(OR_TOOLS_ASSEMBLY_NAME)
	@echo DOTNET_ORTOOLS_LIBS = $(DOTNET_ORTOOLS_LIBS)
	@echo OR_TOOLS_FSHARP_ASSEMBLY_NAME = $(OR_TOOLS_FSHARP_ASSEMBLY_NAME)
	@echo DOTNET_ORTOOLS_FSHARP_LIBS = $(DOTNET_ORTOOLS_FSHARP_LIBS)
ifeq ($(SYSTEM),win)
	@echo off & echo(
else
	@echo
endif
